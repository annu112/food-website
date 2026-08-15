<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="../dbconnection.jsp" %>

<%
request.setCharacterEncoding("UTF-8");
String username = request.getParameter("username");
String password = request.getParameter("password");
String error = null;

if(username != null && password != null){
    String inputUser = username.trim();
    String passHash = hashPassword(password);
    boolean authenticated = false;
    String adminName = "Administrator";
    String adminEmail = "admin@zkitchen.com";
    int adminId = 0;

    String envAdminUser = getSmtpConfig("ADMIN_USERNAME");
    String envAdminPass = getSmtpConfig("ADMIN_PASSWORD");

    if (envAdminUser != null && !envAdminUser.trim().isEmpty() && envAdminPass != null && !envAdminPass.trim().isEmpty()) {
        if (inputUser.equalsIgnoreCase(envAdminUser.trim()) && password.equals(envAdminPass.trim())) {
            authenticated = true;
            adminEmail = envAdminUser;
        }
    }

    if (!authenticated) {
        Connection con = getDbConnection();
        if (con != null) {
            try {
                PreparedStatement ps = con.prepareStatement("SELECT * FROM users WHERE (LOWER(email) = ? OR phone_number = ? OR LOWER(full_name) = ?) AND role = 'ADMIN' AND password_hash = ?");
                ps.setString(1, inputUser.toLowerCase());
                ps.setString(2, inputUser);
                ps.setString(3, inputUser.toLowerCase());
                ps.setString(4, passHash);

                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    authenticated = true;
                    adminId = rs.getInt("user_id");
                    adminName = rs.getString("full_name");
                    if (rs.getString("email") != null) adminEmail = rs.getString("email");
                }
                rs.close();
                ps.close();
                con.close();
            } catch (Exception ex) {
                error = "Database authentication error.";
            }
        }
    }

    if (authenticated) {
        session.setAttribute("adminUser", adminEmail);
        session.setAttribute("userRole", "ADMIN");

        Map<String, Object> adminLoggedUser = new HashMap<String, Object>();
        adminLoggedUser.put("user_id", adminId);
        adminLoggedUser.put("full_name", adminName);
        adminLoggedUser.put("email", adminEmail);
        adminLoggedUser.put("role", "ADMIN");
        session.setAttribute("loggedUser", adminLoggedUser);

        response.sendRedirect("dashbord.jsp");
        return;
    } else {
        if (error == null) error = "Invalid Admin Credentials";
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