<%@ page import="java.sql.*" %>
<%@ include file="db.jsp" %>

<%
    String name = request.getParameter("name");
    String email = request.getParameter("email");

    PreparedStatement ps = conn.prepareStatement(
        "INSERT INTO users (name, email) VALUES (?, ?)"
    );

    ps.setString(1, name);
    ps.setString(2, email);
    ps.executeUpdate();

    conn.close();

    response.sendRedirect("list-users.jsp");
%>
