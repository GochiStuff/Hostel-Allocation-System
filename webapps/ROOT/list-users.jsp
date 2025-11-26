<%@ page import="java.sql.*" %>
<%@ include file="db.jsp" %>

<html>
<body>
<h2>All Users</h2>

<a href="add-user.jsp">Add New User</a>
<br><br>

<table border="1" cellpadding="10">
<tr>
    <th>ID</th>
    <th>Name</th>
    <th>Email</th>
    <th>Actions</th>
</tr>

<%
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("SELECT * FROM users");

    while (rs.next()) {
%>
<tr>
    <td><%= rs.getInt("id") %></td>
    <td><%= rs.getString("name") %></td>
    <td><%= rs.getString("email") %></td>
    <td>
        <a href="edit-user.jsp?id=<%= rs.getInt("id") %>">Edit</a> |
        <a href="delete-user.jsp?id=<%= rs.getInt("id") %>">Delete</a>
    </td>
</tr>
<%
    }
    conn.close();
%>

</table>

</body>
</html>
