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
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login Activity Log - Z Kitchen Admin</title>
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
            <li><a href="login_activity.jsp" class="active"><i class="fa-solid fa-clock-rotate-left"></i> Login Activity</a></li>
            <li><a href="reg_activity.jsp"><i class="fa-solid fa-user-plus"></i> Registration Log</a></li>
            <li><a href="contect.jsp"><i class="fa-solid fa-envelope"></i> Contact Messages</a></li>
            <li class="sidebar-logout"><a href="../index.jsp"><i class="fa-solid fa-right-from-bracket"></i> Logout</a></li>
        </ul>
    </div>

    <div class="main">
        <div class="top-bar">
            <h1>User Login Activity Log</h1>
            <div style="font-weight:600; color:#64748b;">Monitor 2-Step OTP authentication & security</div>
        </div>

        <div class="content-container">
            <div class="container-header">
                <h2>Real-Time Login Audits</h2>
                <input type="text" id="loginLogSearch" class="search-input" placeholder="Search by user or status...">
            </div>

            <table id="loginLogTable">
                <thead>
                    <tr>
                        <th>Log ID</th>
                        <th>User / Identifier</th>
                        <th>Login Timestamp</th>
                        <th>OTP Verified</th>
                        <th>Login Status</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Connection con = getDbConnection();
                    if(con != null) {
                        try {
                            PreparedStatement st = con.prepareStatement("SELECT l.*, u.full_name FROM login_activity l LEFT JOIN users u ON l.user_id = u.user_id ORDER BY l.login_id DESC");
                            ResultSet rs = st.executeQuery();
                            while(rs.next()) {
                                int logId = rs.getInt("login_id");
                                String name = rs.getString("full_name");
                                String identifier = rs.getString("user_identifier");
                                String loginTime = rs.getString("login_time");
                                int otpVer = rs.getInt("otp_verified");
                                String status = rs.getString("login_status");

                                String statusColor = "#eab308"; // pending
                                if("SUCCESS".equalsIgnoreCase(status) || "SUCCESS_GOOGLE".equalsIgnoreCase(status)) statusColor = "#16a34a";
                                else if(status.contains("FAILED")) statusColor = "#dc2626";
                    %>
                    <tr>
                        <td><strong>#LOG-<%= logId %></strong></td>
                        <td>
                            <div style="font-weight:700;"><%= name != null ? name : "Guest / Login Attempt" %></div>
                            <small style="color:#64748b;"><%= identifier %></small>
                        </td>
                        <td style="font-size:14px; color:#475569;"><i class="fa-regular fa-clock me-1"></i> <%= loginTime %></td>
                        <td>
                            <% if(otpVer == 1) { %>
                                <span style="color:#16a34a; font-weight:700;"><i class="fa-solid fa-shield-check"></i> Verified ✔️</span>
                            <% } else { %>
                                <span style="color:#dc2626; font-weight:600;"><i class="fa-solid fa-shield-xmark"></i> Unverified ❌</span>
                            <% } %>
                        </td>
                        <td>
                            <span class="badge-status" style="background:<%= statusColor %>15; color:<%= statusColor %>; border:1px solid <%= statusColor %>40;">
                                <%= status.toUpperCase() %>
                            </span>
                        </td>
                    </tr>
                    <%
                            }
                            rs.close();
                            st.close();
                            con.close();
                        } catch(Exception e) {
                            out.println("<tr><td colspan='5'>Error loading logs: " + e.getMessage() + "</td></tr>");
                        }
                    }
                    %>
                </tbody>
            </table>
        </div>
    </div>

<script>
  document.getElementById("loginLogSearch").addEventListener("keyup", function() {
    const q = this.value.toLowerCase();
    document.querySelectorAll("#loginLogTable tbody tr").forEach(r => {
      r.style.display = r.innerText.toLowerCase().includes(q) ? "" : "none";
    });
  });
</script>
</body>
</html>
