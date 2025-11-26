<%@ page import="java.sql.*" %>
<html>
<body>
<h2>JDBC Connection Test</h2>

<%
    String url = "jdbc:mysql://localhost:3306/test";
    String user = "jspuser";
    String pass = "mypassword";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(url, user, pass);
        out.println("<p>✅ Connection successful!</p>");

        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM users");
        rs.next();
        out.println("<p>Total users: " + rs.getInt(1) + "</p>");
        conn.close();

    } catch (Exception e) {
        out.println("<p>❌ Error: " + e + "</p>");
    }
%>

</body>
</html>

