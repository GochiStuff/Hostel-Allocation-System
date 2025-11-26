<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%!
    // --- 1. DATA MODELS (Classes) ---
    public static class Room {
        String id;
        String number;
        int capacity;
        int currentOccupancy;

        public Room(String id, String number, int capacity) {
            this.id = id;
            this.number = number;
            this.capacity = capacity;
            this.currentOccupancy = 0;
        }
    }

    public static class Student {
        String id;
        String name;
        String gender;
        String assignedRoomId; // Null if not allocated

        public Student(String id, String name, String gender) {
            this.id = id;
            this.name = name;
            this.gender = gender;
            this.assignedRoomId = null;
        }
    }

    // --- 2. HELPER METHODS ---
    public Room findRoom(List<Room> rooms, String id) {
        if(rooms == null) return null;
        for(Room r : rooms) if(r.id.equals(id)) return r;
        return null;
    }

    public Student findStudent(List<Student> students, String id) {
        if(students == null) return null;
        for(Student s : students) if(s.id.equals(id)) return s;
        return null;
    }
%>

<%
    // --- 3. INITIALIZATION (Application Scope acts as Database) ---
    List<Room> rooms = (List<Room>) application.getAttribute("rooms");
    List<Student> students = (List<Student>) application.getAttribute("students");
    String message = "";
    String msgType = ""; // "success" or "error"

    if (rooms == null) {
        rooms = new ArrayList<>();
        rooms.add(new Room("101", "101-A", 2));
        rooms.add(new Room("102", "102-B", 4));
        rooms.add(new Room("103", "VIP-1", 1));
        application.setAttribute("rooms", rooms);
    }
    if (students == null) {
        students = new ArrayList<>();
        students.add(new Student("s1", "John Doe", "Male"));
        students.add(new Student("s2", "Jane Smith", "Female"));
        students.add(new Student("s3", "Alice Johnson", "Female"));
        application.setAttribute("students", students);
    }

    // --- 4. ACTION HANDLING (Controller Logic) ---
    String action = request.getParameter("action");

    if ("addStudent".equals(action)) {
        String name = request.getParameter("name");
        String gender = request.getParameter("gender");
        if (name != null && !name.isEmpty()) {
            students.add(new Student(UUID.randomUUID().toString(), name, gender));
            message = "Student added successfully.";
            msgType = "success";
        }
    } else if ("addRoom".equals(action)) {
        String num = request.getParameter("number");
        int cap = Integer.parseInt(request.getParameter("capacity"));
        rooms.add(new Room(UUID.randomUUID().toString(), num, cap));
        message = "Room added successfully.";
        msgType = "success";
    } else if ("allocate".equals(action)) {
        String sId = request.getParameter("studentId");
        String rId = request.getParameter("roomId");
        Student s = findStudent(students, sId);
        Room r = findRoom(rooms, rId);

        if (s != null && r != null) {
            if (s.assignedRoomId != null) {
                message = "Error: Student already has a room.";
                msgType = "error";
            } else if (r.currentOccupancy >= r.capacity) {
                message = "Error: Room is full.";
                msgType = "error";
            } else {
                s.assignedRoomId = r.id;
                r.currentOccupancy++;
                message = "Allocated " + s.name + " to Room " + r.number;
                msgType = "success";
            }
        }
    } else if ("deallocate".equals(action)) {
        String sId = request.getParameter("studentId");
        Student s = findStudent(students, sId);
        if (s != null && s.assignedRoomId != null) {
            Room r = findRoom(rooms, s.assignedRoomId);
            if (r != null) r.currentOccupancy--;
            s.assignedRoomId = null;
            message = "De-allocated successfully.";
            msgType = "success";
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Dorm Manager Pro</title>
    <style>
        /* Minimal Aesthetic Art Styles */
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f0f2f5; margin: 0; padding: 20px; color: #333; }
        
        .container {
            max-width: 1000px; margin: auto; background: white;
            border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); overflow: hidden;
        }

        .header { background: #007bff; color: white; padding: 20px; text-align: center; }
        .header h1 { margin: 0; font-weight: 300; letter-spacing: 1px; }

        .content { padding: 30px; }

        .alert {
            padding: 15px; margin-bottom: 20px; border-radius: 6px; font-size: 14px;
        }
        .success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }

        /* Grid Layout for Forms */
        .grid-row { display: flex; gap: 20px; margin-bottom: 30px; }
        .card { flex: 1; background: #fafafa; padding: 20px; border-radius: 8px; border: 1px solid #eee; }
        .card h3 { margin-top: 0; color: #555; border-bottom: 2px solid #ddd; padding-bottom: 10px; font-size: 16px; }

        /* Form Elements */
        form { display: flex; flex-direction: column; gap: 10px; }
        input, select { padding: 10px; border: 1px solid #ccc; border-radius: 4px; font-size: 14px; }
        button {
            padding: 10px; border: none; border-radius: 4px; cursor: pointer;
            background: #007bff; color: white; font-weight: bold; transition: 0.2s;
        }
        button:hover { background: #0056b3; }
        button.danger { background: #dc3545; }
        button.danger:hover { background: #a71d2a; }

        /* Tables */
        table { width: 100%; border-collapse: collapse; margin-top: 10px; font-size: 14px; }
        th, td { padding: 12px 15px; border-bottom: 1px solid #eee; text-align: left; }
        th { background: #f8f9fa; color: #666; font-weight: 600; }
        tr:hover { background: #f1f1f1; }
        
        .badge { padding: 4px 8px; border-radius: 12px; font-size: 11px; font-weight: bold; }
        .badge-avail { background: #d4edda; color: #155724; }
        .badge-full { background: #f8d7da; color: #721c24; }
    </style>
</head>
<body>

<div class="container">
    <div class="header">
        <h1>Hostel Allocation System</h1>
    </div>

    <div class="content">
        
        <% if (!message.isEmpty()) { %>
            <div class="alert <%= msgType %>">
                <%= message %>
            </div>
        <% } %>

        <div class="grid-row">
            <div class="card">
                <h3>+ Add Student</h3>
                <form method="post">
                    <input type="hidden" name="action" value="addStudent">
                    <input type="text" name="name" placeholder="Student Name" required>
                    <select name="gender">
                        <option value="Male">Male</option>
                        <option value="Female">Female</option>
                    </select>
                    <button type="submit">Create Student</button>
                </form>
            </div>

            <div class="card">
                <h3>+ Add Room</h3>
                <form method="post">
                    <input type="hidden" name="action" value="addRoom">
                    <input type="text" name="number" placeholder="Room Number (e.g. 101-A)" required>
                    <input type="number" name="capacity" placeholder="Capacity (e.g. 2)" required min="1">
                    <button type="submit" style="background: #28a745;">Create Room</button>
                </form>
            </div>
            
            <div class="card">
                <h3>⚡ Assign Room</h3>
                <form method="post">
                    <input type="hidden" name="action" value="allocate">
                    <select name="studentId" required>
                        <option value="" disabled selected>Select Student...</option>
                        <% for(Student s : students) { 
                             if(s.assignedRoomId == null) { %>
                                <option value="<%= s.id %>"><%= s.name %></option>
                        <%   } 
                           } %>
                    </select>
                    <select name="roomId" required>
                        <option value="" disabled selected>Select Room...</option>
                        <% for(Room r : rooms) { 
                             if(r.currentOccupancy < r.capacity) { %>
                                <option value="<%= r.id %>"><%= r.number %> (Aval: <%= r.capacity - r.currentOccupancy %>)</option>
                        <%   } 
                           } %>
                    </select>
                    <button type="submit" style="background: #6610f2;">Allocate</button>
                </form>
            </div>
        </div>

        <hr style="border: 0; border-top: 1px solid #eee; margin: 30px 0;">

        <div class="grid-row">
            
            <div class="card" style="flex: 1;">
                <h3>🏠 Room Status</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Room No</th>
                            <th>Cap</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for(Room r : rooms) { %>
                        <tr>
                            <td><%= r.number %></td>
                            <td><%= r.currentOccupancy %> / <%= r.capacity %></td>
                            <td>
                                <% if(r.currentOccupancy >= r.capacity) { %>
                                    <span class="badge badge-full">FULL</span>
                                <% } else { %>
                                    <span class="badge badge-avail">AVAILABLE</span>
                                <% } %>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <div class="card" style="flex: 2;">
                <h3>🎓 Student Roster</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Gender</th>
                            <th>Assigned Room</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for(Student s : students) { 
                            Room assignedRoom = findRoom(rooms, s.assignedRoomId);
                        %>
                        <tr>
                            <td><%= s.name %></td>
                            <td><%= s.gender %></td>
                            <td>
                                <% if(assignedRoom != null) { %>
                                    <b><%= assignedRoom.number %></b>
                                <% } else { %>
                                    <span style="color: #999;">-- Unassigned --</span>
                                <% } %>
                            </td>
                            <td>
                                <% if(assignedRoom != null) { %>
                                    <form method="post" style="margin:0;">
                                        <input type="hidden" name="action" value="deallocate">
                                        <input type="hidden" name="studentId" value="<%= s.id %>">
                                        <button type="submit" class="danger" style="padding: 5px 10px; font-size: 12px;">Vacate</button>
                                    </form>
                                <% } %>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

        </div>

    </div>
</div>

</body>
</html>