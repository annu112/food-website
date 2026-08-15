<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="../dbconnection.jsp" %>

<%
request.setCharacterEncoding("UTF-8");

// ROLE-BASED ADMIN AUTHORIZATION CHECK
Map<String, Object> adminLoggedUser = (Map<String, Object>) session.getAttribute("loggedUser");
String adminUserRole = session.getAttribute("userRole") != null ? session.getAttribute("userRole").toString() : "";
boolean isAdminSession = (session.getAttribute("adminUser") != null) || (adminLoggedUser != null && "ADMIN".equalsIgnoreCase(adminUserRole));

if(!isAdminSession) {
    response.sendRedirect("../index.jsp?error=" + java.net.URLEncoder.encode("Unauthorized access. Admin privileges required.", "UTF-8"));
    return;
}

Connection con = getDbConnection();

int totalMessages = 0;
try {
    Statement stCount = con.createStatement();
    ResultSet rsCount = stCount.executeQuery("SELECT COUNT(*) FROM contact");
    if(rsCount.next()) totalMessages = rsCount.getInt(1);
    stCount.close();
} catch(Exception e){}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contact Messages - Z Kitchen Admin</title>
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
</head>
<body>

    <div class="sidebar">
        <div class="sidebar-brand">
            <img src="../images/z kitchen.jpeg" alt="Logo">
            <h2>Food Admin</h2>
        </div>
        <ul class="sidebar-menu">
            <li><a href="dashbord.jsp"><i class="fa-solid fa-chart-line"></i> Dashboard</a></li>
            <li><a href="products.jsp"><i class="fa-solid fa-burger"></i> Products</a></li>
            <li><a href="orders.jsp"><i class="fa-solid fa-cart-shopping"></i> Orders</a></li>
            <li><a href="users.jsp"><i class="fa-solid fa-users"></i> Users Management</a></li>
            <li><a href="login_activity.jsp"><i class="fa-solid fa-clock-rotate-left"></i> Login Activity</a></li>
            <li><a href="reg_activity.jsp"><i class="fa-solid fa-user-plus"></i> Registration Log</a></li>
            <li><a href="contect.jsp" class="active"><i class="fa-solid fa-envelope"></i> Contact Messages</a></li>
            <li class="sidebar-logout"><a href="../index.jsp"><i class="fa-solid fa-right-from-bracket"></i> Logout</a></li>
        </ul>
    </div>

    <div class="main">
        <div class="top-bar">
            <h1>Contact Inquiries</h1>
            <div style="background:#ff385c; color:#ffffff; padding:6px 16px; border-radius:20px; font-weight:700; font-size:14px;">
                Total Messages: <%= totalMessages %>
            </div>
        </div>

        <div class="content-container">
            <div class="container-header">
                <h2>All Inquiries</h2>
                <input type="text" id="adminTableSearch" class="search-input" placeholder="Search inquiries...">
            </div>

            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>User Name</th>
                        <th>Email Address</th>
                        <th>Phone Number</th>
                        <th>Message / Inquiry</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    try {
                        Statement st = con.createStatement();
                        ResultSet rs = st.executeQuery("SELECT * FROM contact ORDER BY id DESC");
                        while(rs.next()) {
                            int id = rs.getInt("id");
                            String name = sanitizeHtml(rs.getString("nam"));
                            String email = sanitizeHtml(rs.getString("email"));
                            String phone = sanitizeHtml(rs.getString("number"));
                            String comment = sanitizeHtml(rs.getString("comment"));
                    %>
                    <tr>
                        <td><strong>#<%= id %></strong></td>
                        <td><strong><%= name %></strong></td>
                        <td><%= email %></td>
                        <td><i class="fa-solid fa-phone me-1 text-muted"></i><%= phone %></td>
                        <td>
                            <div style="background:#f8fafc; padding:10px 14px; border-radius:8px; border-left:3px solid #ff385c; font-size:13px; color:#334155;">
                                <%= comment %>
                            </div>
                        </td>
                    </tr>
                    <%
                        }
                        con.close();
                    } catch(Exception e){
                        out.println("<tr><td colspan='5' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
                    }
                    %>
                </tbody>
            </table>
        </div>
    </div>

    <script src="js/admin.js"></script>
</body>
</html>