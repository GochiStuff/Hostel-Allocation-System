<%
    String url = "jdbc:mysql://localhost:3306/test";
    String user = "jspuser";
    String pass = "mypassword";

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(url, user, pass);
%>
