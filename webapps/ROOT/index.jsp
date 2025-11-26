<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%!
    // --- 1. DATA CLASSES ---
    public static class Room {
        String id;
        String number;
        int capacity;
        int currentOccupancy;
        public Room(String id, String number, int capacity, int currentOccupancy) {
            this.id = id;
            this.number = number;
            this.capacity = capacity;
            this.currentOccupancy = currentOccupancy;
        }
    }

    public static class Student {
        String id;
        String name;
        String gender;
        String assignedRoomId;
        public Student(String id, String name, String gender, String assignedRoomId) {
            this.id = id;
            this.name = name;
            this.gender = gender;
            this.assignedRoomId = assignedRoomId;
        }
    }
%>

<%
    // --- 2. DATABASE CONFIGURATION (Matching your working script) ---
    String DB_URL = "jdbc:mysql://localhost:3306/test";
    String DB_USER = "jspuser";     // <--- Updated to match your working script
    String DB_PASS = "mypassword";  // <--- Updated to match your working script
    
    Connection conn = null;
    String message = "";
    String msgType = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
    } catch (Exception e) {
        message = "DB Connection Failed: " + e.getMessage();
        msgType = "error";
    }

    // --- 3. AUTO-CREATE TABLES (Run Once) ---
    if (conn != null) {
        try {
            Statement stmt = conn.createStatement();
            stmt.executeUpdate("CREATE TABLE IF NOT EXISTS rooms (id VARCHAR(50) PRIMARY KEY, room_number VARCHAR(50), capacity INT)");
            stmt.executeUpdate("CREATE TABLE IF NOT EXISTS students (id VARCHAR(50) PRIMARY KEY, name VARCHAR(100), gender VARCHAR(20), assigned_room_id VARCHAR(50))");
            stmt.close();
        } catch (SQLException e) {
            message = "Table Init Error: " + e.getMessage();
            msgType = "error";
        }
    }

    // --- 4. ACTION CONTROLLER ---
    String action = request.getParameter("action");
    if (conn != null && action != null) {
        try {
            if ("addStudent".equals(action)) {
                String name = request.getParameter("name");
                String gender = request.getParameter("gender");
                PreparedStatement ps = conn.prepareStatement("INSERT INTO students (id, name, gender) VALUES (?, ?, ?)");
                ps.setString(1, UUID.randomUUID().toString());
                ps.setString(2, name);
                ps.setString(3, gender);
                ps.executeUpdate();
                message = "Student added!";
                msgType = "success";

            } else if ("addRoom".equals(action)) {
                String num = request.getParameter("number");
                int cap = Integer.parseInt(request.getParameter("capacity"));
                PreparedStatement ps = conn.prepareStatement("INSERT INTO rooms (id, room_number, capacity) VALUES (?, ?, ?)");
                ps.setString(1, UUID.randomUUID().toString());
                ps.setString(2, num);
                ps.setInt(3, cap);
                ps.executeUpdate();
                message = "Room added!";
                msgType = "success";

            } else if ("allocate".equals(action)) {
                String sId = request.getParameter("studentId");
                String rId = request.getParameter("roomId");
                // Check capacity
                PreparedStatement checkPs = conn.prepareStatement("SELECT capacity, (SELECT COUNT(*) FROM students WHERE assigned_room_id = rooms.id) as occ FROM rooms WHERE id = ?");
                checkPs.setString(1, rId);
                ResultSet rs = checkPs.executeQuery();
                if (rs.next()) {
                    if (rs.getInt("occ") >= rs.getInt("capacity")) {
                        message = "Room is full!";
                        msgType = "error";
                    } else {
                        PreparedStatement up = conn.prepareStatement("UPDATE students SET assigned_room_id = ? WHERE id = ?");
                        up.setString(1, rId);
                        up.setString(2, sId);
                        up.executeUpdate();
                        message = "Allocated!";
                        msgType = "success";
                    }
                }
                rs.close();

            } else if ("deallocate".equals(action)) {
                String sId = request.getParameter("studentId");
                PreparedStatement ps = conn.prepareStatement("UPDATE students SET assigned_room_id = NULL WHERE id = ?");
                ps.setString(1, sId);
                ps.executeUpdate();
                message = "De-allocated!";
                msgType = "success";
            }
        } catch (Exception e) {
            message = "Action Error: " + e.getMessage();
            msgType = "error";
        }
    }

    // --- 5. FETCH DATA FOR UI ---
    List<Room> rooms = new ArrayList<>();
    List<Student> students = new ArrayList<>();

    if (conn != null) {
        try {
            Statement s1 = conn.createStatement();
            ResultSet r1 = s1.executeQuery("SELECT id, room_number, capacity, (SELECT COUNT(*) FROM students WHERE assigned_room_id = rooms.id) as occ FROM rooms ORDER BY room_number");
            while(r1.next()) {
                rooms.add(new Room(r1.getString("id"), r1.getString("room_number"), r1.getInt("capacity"), r1.getInt("occ")));
            }
            
            Statement s2 = conn.createStatement();
            ResultSet r2 = s2.executeQuery("SELECT * FROM students ORDER BY name");
            while(r2.next()) {
                students.add(new Student(r2.getString("id"), r2.getString("name"), r2.getString("gender"), r2.getString("assigned_room_id")));
            }
            conn.close(); // Close connection
        } catch(Exception e) { out.println("Fetch Error: " + e); }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Hostel Manager (JDBC)</title>
    <style>
        body { font-family: sans-serif; background: #f4f4f9; padding: 20px; }
        .container { max-width: 900px; margin: auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { text-align: center; color: #333; }
        .alert { padding: 10px; margin-bottom: 15px; border-radius: 4px; }
        .success { background: #d4edda; color: #155724; }
        .error { background: #f8d7da; color: #721c24; }
        .forms { display: flex; gap: 20px; flex-wrap: wrap; }
        .card { flex: 1; background: #fafafa; padding: 15px; border: 1px solid #ddd; border-radius: 6px; min-width: 250px; }
        input, select, button { width: 100%; padding: 8px; margin-top: 5px; box-sizing: border-box; }
        button { background: #007bff; color: white; border: none; cursor: pointer; margin-top: 10px; }
        button:hover { background: #0056b3; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { padding: 10px; border-bottom: 1px solid #eee; text-align: left; }
        th { background: #f1f1f1; }
        .badge { padding: 3px 8px; border-radius: 10px; font-size: 12px; color: white; }
        .bg-green { background: #28a745; }
        .bg-red { background: #dc3545; }
    </style>
</head>
<body>
<div class="container">
    <h1>Hostel Allocation System</h1>
    
    <% if (!message.isEmpty()) { %>
        <div class="alert <%= msgType %>"><%= message %></div>
    <% } %>

    <div class="forms">
        <div class="card">
            <h3>Add Student</h3>
            <form method="post">
                <input type="hidden" name="action" value="addStudent">
                <input type="text" name="name" placeholder="Name" required>
                <select name="gender">
                    <option value="Male">Male</option>
                    <option value="Female">Female</option>
                </select>
                <button type="submit">Add Student</button>
            </form>
        </div>

        <div class="card">
            <h3>Add Room</h3>
            <form method="post">
                <input type="hidden" name="action" value="addRoom">
                <input type="text" name="number" placeholder="Room No (e.g. 101)" required>
                <input type="number" name="capacity" placeholder="Capacity" required>
                <button type="submit" style="background:#28a745">Add Room</button>
            </form>
        </div>

        <div class="card">
            <h3>Allocate</h3>
            <form method="post">
                <input type="hidden" name="action" value="allocate">
                <select name="studentId">
                    <option disabled selected>Select Student...</option>
                    <% for(Student s : students) { if(s.assignedRoomId == null) { %>
                        <option value="<%= s.id %>"><%= s.name %></option>
                    <% }} %>
                </select>
                <select name="roomId">
                    <option disabled selected>Select Room...</option>
                    <% for(Room r : rooms) { if(r.currentOccupancy < r.capacity) { %>
                        <option value="<%= r.id %>"><%= r.number %> (Free: <%= r.capacity - r.currentOccupancy %>)</option>
                    <% }} %>
                </select>
                <button type="submit" style="background:#6610f2">Assign</button>
            </form>
        </div>
    </div>

    <hr>

    <h3>Room Status</h3>
    <table>
        <tr><th>Room</th><th>Occupancy</th><th>Status</th></tr>
        <% for(Room r : rooms) { %>
        <tr>
            <td><%= r.number %></td>
            <td><%= r.currentOccupancy %> / <%= r.capacity %></td>
            <td>
                <% if(r.currentOccupancy >= r.capacity) { %>
                    <span class="badge bg-red">FULL</span>
                <% } else { %>
                    <span class="badge bg-green">AVAILABLE</span>
                <% } %>
            </td>
        </tr>
        <% } %>
    </table>

    <h3>Student List</h3>
    <table>
        <tr><th>Name</th><th>Room</th><th>Action</th></tr>
        <% for(Student s : students) { 
             String rNum = "Unassigned";
             if(s.assignedRoomId != null) {
                 for(Room r : rooms) if(r.id.equals(s.assignedRoomId)) rNum = r.number;
             }
        %>
        <tr>
            <td><%= s.name %></td>
            <td><b><%= rNum %></b></td>
            <td>
                <% if(s.assignedRoomId != null) { %>
                <form method="post" style="display:inline;">
                    <input type="hidden" name="action" value="deallocate">
                    <input type="hidden" name="studentId" value="<%= s.id %>">
                    <button type="submit" style="background:#dc3545; width:auto; padding:5px 10px; font-size:12px; margin:0;">Vacate</button>
                </form>
                <% } %>
            </td>
        </tr>
        <% } %>
    </table>
</div>
</body>
</html>