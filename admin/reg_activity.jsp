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
    <title>Registration Activity Log - Z Kitchen Admin</title>
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
            <li><a href="reg_activity.jsp" class="active"><i class="fa-solid fa-user-plus"></i> Registration Log</a></li>
            <li><a href="contect.jsp"><i class="fa-solid fa-envelope"></i> Contact Messages</a></li>
            <li class="sidebar-logout"><a href="../index.jsp"><i class="fa-solid fa-right-from-bracket"></i> Logout</a></li>
        </ul>
    </div>

    <div class="main">
        <div class="top-bar">
            <h1>User Registration Activity Log</h1>
            <div style="font-weight:600; color:#64748b;">Track how users sign up and verify accounts</div>
        </div>

        <div class="content-container">
            <div class="container-header">
                <h2>Registration History & Methods</h2>
                <input type="text" id="regLogSearch" class="search-input" placeholder="Search by name, email, method...">
            </div>

            <table id="regLogTable">
                <thead>
                    <tr>
                        <th>User ID</th>
                        <th>Full Name</th>
                        <th>Contact Email / Phone</th>
                        <th>Reg Method</th>
                        <th>Reg Date & Time</th>
                        <th>Verification Status</th>
                        <th>Account Status</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Connection con = getDbConnection();
                    if(con != null) {
                        try {
                            Statement st = con.createStatement();
                            ResultSet rs = st.executeQuery("SELECT * FROM users ORDER BY user_id DESC");
                            while(rs.next()) {
                                int uId = rs.getInt("user_id");
                                String name = rs.getString("full_name");
                                String email = rs.getString("email");
                                String phone = rs.getString("phone_number");
                                String method = rs.getString("registration_method");
                                if(method == null) method = "EMAIL";
                                int eVer = rs.getInt("email_verified");
                                int pVer = rs.getInt("phone_verified");
                                String status = rs.getString("account_status");
                                if(status == null) status = "ACTIVE";
                                String createdAt = rs.getString("created_at");

                                String methodColor = "#0284c7"; // Google
                                if("EMAIL".equalsIgnoreCase(method)) methodColor = "#d97706";
                                else if("PHONE".equalsIgnoreCase(method)) methodColor = "#7c3aed";
                    %>
                    <tr>
                        <td><strong>#<%= uId %></strong></td>
                        <td>
                            <a href="user_detail.jsp?id=<%= uId %>" style="font-weight:700; color:#0f172a; text-decoration:none;"><%= name %></a>
                        </td>
                        <td>
                            <div style="font-weight:600;"><%= email != null ? email : "—" %></div>
                            <small style="color:#64748b;"><%= phone != null ? phone : "—" %></small>
                        </td>
                        <td>
                            <span class="badge-status" style="background:<%= methodColor %>15; color:<%= methodColor %>; border:1px solid <%= methodColor %>40;">
                                <%= method.toUpperCase() %>
                            </span>
                        </td>
                        <td style="font-size:14px; color:#475569;"><i class="fa-regular fa-calendar-days me-1"></i> <%= createdAt %></td>
                        <td>
                            <% if(eVer == 1 || pVer == 1) { %>
                                <span style="color:#16a34a; font-weight:700;"><i class="fa-solid fa-circle-check"></i> Verified</span>
                            <% } else { %>
                                <span style="color:#dc2626; font-weight:600;"><i class="fa-solid fa-circle-xmark"></i> Pending</span>
                            <% } %>
                        </td>
                        <td>
                            <% if("ACTIVE".equalsIgnoreCase(status)) { %>
                              <span class="badge-status" style="background:#dcfce7; color:#15803d;">ACTIVE</span>
                            <% } else { %>
                              <span class="badge-status" style="background:#fee2e2; color:#b91c1c;">BLOCKED</span>
                            <% } %>
                        </td>
                    </tr>
                    <%
                            }
                            rs.close();
                            st.close();
                            con.close();
                        } catch(Exception e) {
                            out.println("<tr><td colspan='7'>Error loading registration log: " + e.getMessage() + "</td></tr>");
                        }
                    }
                    %>
                </tbody>
            </table>
        </div>
    </div>

<script>
  document.getElementById("regLogSearch").addEventListener("keyup", function() {
    const q = this.value.toLowerCase();
    document.querySelectorAll("#regLogTable tbody tr").forEach(r => {
      r.style.display = r.innerText.toLowerCase().includes(q) ? "" : "none";
    });
  });
</script>
</body>
</html>
