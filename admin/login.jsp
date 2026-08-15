<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="../dbconnection.jsp" %>

<%
request.setCharacterEncoding("UTF-8");
String username = request.getParameter("username");
String password = request.getParameter("password");
String error = null;

if(username != null && password != null){
    if(username.equals("admin") && password.equals("123")){
        session.setAttribute("adminUser", "admin");
        session.setAttribute("userRole", "ADMIN");

        Map<String, Object> adminLoggedUser = new HashMap<String, Object>();
        adminLoggedUser.put("user_id", 0);
        adminLoggedUser.put("full_name", "Administrator");
        adminLoggedUser.put("email", "admin@zkitchen.com");
        adminLoggedUser.put("role", "ADMIN");
        session.setAttribute("loggedUser", adminLoggedUser);

        response.sendRedirect("dashbord.jsp");
        return;
    } else {
        error = "Invalid Username or Password";
    }
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - Z Kitchen</title>
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
</head>
<body class="login-body">

<div class="login-card">
    <div class="mb-4">
        <i class="fa-solid fa-user-shield text-danger display-4 mb-2"></i>
        <h2>Z Kitchen Admin Portal</h2>
    </div>

    <% if(error != null) { %>
    <div style="background:#fee2e2; color:#dc2626; padding:10px; border-radius:8px; margin-bottom:15px; font-size:14px; font-weight:600;">
        <i class="fa-solid fa-circle-exclamation me-1"></i> <%= error %>
    </div>
    <% } %>

    <form method="post" action="login.jsp">
        <input type="text" name="username" placeholder="Username (admin)" required>
        <input type="password" name="password" placeholder="Password (123)" required>
        <button type="submit"><i class="fa-solid fa-right-to-bracket me-2"></i> Login to Dashboard</button>
    </form>
    
    <div style="margin-top: 20px;">
        <a href="../index.jsp" style="color:#64748b; text-decoration:none; font-size:14px;"><i class="fa-solid fa-arrow-left me-1"></i> Return to Main Website</a>
    </div>
</div>

</body>
</html>