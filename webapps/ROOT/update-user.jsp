<%@ page import="java.sql.*" %>
<%@ include file="db.jsp" %>

<%
    int id = Integer.parseInt(request.getParameter("id"));
    String name = request.getParameter("name");
    String email = request.getParameter("email");

    PreparedStatement ps = conn.prepareStatement(
        "UPDATE users SET name=?, email=? WHERE id=?"
    );

    ps.setString(1, name);
    ps.setString(2, email);
    ps.setInt(3, id);

    ps.executeUpdate();
    conn.close();

    response.sendRedirect("list-users.jsp");
%>
