<%@ page import="java.sql.*" %>
<%@ include file="db.jsp" %>

<%
    int id = Integer.parseInt(request.getParameter("id"));

    PreparedStatement ps = conn.prepareStatement("DELETE FROM users WHERE id=?");
    ps.setInt(1, id);
    ps.executeUpdate();

    conn.close();

    response.sendRedirect("list-users.jsp");
%>


