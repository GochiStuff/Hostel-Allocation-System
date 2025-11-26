<%@ page import="java.sql.*" %>
<%@ include file="db.jsp" %>

<%
    int id = Integer.parseInt(request.getParameter("id"));
    PreparedStatement ps = conn.prepareStatement("SELECT * FROM users WHERE id=?");
    ps.setInt(1, id);

    ResultSet rs = ps.executeQuery();
    rs.next();
%>

<html>
<body>
<h2>Edit User</h2>

<form action="update-user.jsp" method="post">
    <input type="hidden" name="id" value="<%= rs.getInt("id") %>">

    Name: <input type="text" name="name" value="<%= rs.getString("name") %>"><br><br>
    Email: <input type="text" name="email" value="<%= rs.getString("email") %>"><br><br>

    <input type="submit" value="Update">
</form>

</body>
</html>
