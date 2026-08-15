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

// Toggle Status (Block / Unblock User)
String toggleId = request.getParameter("toggleId");
String newStatus = request.getParameter("status");
if(toggleId != null && newStatus != null && con != null) {
    try {
        PreparedStatement ps = con.prepareStatement("UPDATE users SET account_status = ? WHERE user_id = ?");
        ps.setString(1, newStatus);
        ps.setInt(2, Integer.parseInt(toggleId));
        ps.executeUpdate();
        ps.close();
        con.close();
        response.sendRedirect("users.jsp");
        return;
    } catch(Exception e){}
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Users Management - Z Kitchen Admin</title>
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <style>
      .search-filter-bar {
        display: flex;
        gap: 15px;
        flex-wrap: wrap;
        margin-bottom: 20px;
      }
      .filter-select {
        padding: 8px 14px;
        border-radius: 8px;
        border: 1px solid #cbd5e1;
        outline: none;
      }
      .badge-method {
        padding: 4px 10px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 700;
      }
      .badge-google { background: #e0f2fe; color: #0369a1; }
      .badge-email { background: #fef3c7; color: #92400e; }
      .badge-phone { background: #f3e8ff; color: #6b21a8; }
    </style>
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
            <li><a href="users.jsp" class="active"><i class="fa-solid fa-users"></i> Users Management</a></li>
            <li><a href="login_activity.jsp"><i class="fa-solid fa-clock-rotate-left"></i> Login Activity</a></li>
            <li><a href="reg_activity.jsp"><i class="fa-solid fa-user-plus"></i> Registration Log</a></li>
            <li><a href="contect.jsp"><i class="fa-solid fa-envelope"></i> Contact Messages</a></li>
            <li class="sidebar-logout"><a href="../index.jsp"><i class="fa-solid fa-right-from-bracket"></i> Logout</a></li>
        </ul>
    </div>

    <div class="main">
        <div class="top-bar">
            <h1>Users Management & Security</h1>
            <div style="font-weight:600; color:#64748b;">Manage customer accounts & permissions</div>
        </div>

        <div class="content-container">
            <div class="container-header" style="flex-direction:column; align-items:flex-start; gap:15px;">
                <h2>All Registered Users</h2>
                <div class="search-filter-bar w-100">
                    <input type="text" id="userSearchInput" class="search-input" placeholder="Search by Name, Email, Phone..." style="max-width:350px;">
                    <select id="methodFilterSelect" class="filter-select" onchange="filterUserTable()">
                        <option value="">All Reg Methods</option>
                        <option value="GOOGLE">Google</option>
                        <option value="EMAIL">Email</option>
                        <option value="PHONE">Phone</option>
                    </select>
                    <select id="statusFilterSelect" class="filter-select" onchange="filterUserTable()">
                        <option value="">All Account Status</option>
                        <option value="ACTIVE">Active</option>
                        <option value="BLOCKED">Blocked</option>
                    </select>
                </div>
            </div>

            <table id="usersDataTable">
                <thead>
                    <tr>
                        <th>User ID</th>
                        <th>Full Name</th>
                        <th>Email / Phone</th>
                        <th>Method</th>
                        <th>Verification</th>
                        <th>Status</th>
                        <th>Orders / Reviews</th>
                        <th>Reg Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    if(con != null) {
                        try {
                            PreparedStatement st = con.prepareStatement("SELECT u.*, (SELECT COUNT(*) FROM orfood o WHERE (o.user_id = u.user_id OR (u.email IS NOT NULL AND u.email != '' AND LOWER(o.email) = LOWER(u.email)))) AS order_count, (SELECT COUNT(*) FROM reviews r WHERE (r.user_id = u.user_id OR (u.full_name IS NOT NULL AND LOWER(r.name) = LOWER(u.full_name)))) AS review_count FROM users u ORDER BY u.user_id DESC");
                            ResultSet rs = st.executeQuery();
                            while(rs.next()) {
                                int uId = rs.getInt("user_id");
                                String name = sanitizeHtml(rs.getString("full_name"));
                                String email = sanitizeHtml(rs.getString("email"));
                                String phone = sanitizeHtml(rs.getString("phone_number"));
                                String method = sanitizeHtml(rs.getString("registration_method"));
                                if(method == null || method.isEmpty()) method = "EMAIL";
                                int eVer = rs.getInt("email_verified");
                                int pVer = rs.getInt("phone_verified");
                                String status = sanitizeHtml(rs.getString("account_status"));
                                if(status == null || status.isEmpty()) status = "ACTIVE";
                                String createdAt = rs.getString("created_at");
                                int orderCount = rs.getInt("order_count");
                                int reviewCount = rs.getInt("review_count");

                                String methodBadgeClass = "badge-email";
                                if("GOOGLE".equalsIgnoreCase(method)) methodBadgeClass = "badge-google";
                                else if("PHONE".equalsIgnoreCase(method)) methodBadgeClass = "badge-phone";
                    %>
                    <tr data-method="<%= method.toUpperCase() %>" data-status="<%= status.toUpperCase() %>">
                        <td><strong>#<%= uId %></strong></td>
                        <td>
                          <a href="user_detail.jsp?id=<%= uId %>" style="color:#0f172a; font-weight:700; text-decoration:none;">
                            <%= name %>
                          </a>
                        </td>
                        <td>
                          <div style="font-weight:600;"><%= email != null ? email : "—" %></div>
                          <small style="color:#64748b;"><%= phone != null ? phone : "—" %></small>
                        </td>
                        <td><span class="badge-method <%= methodBadgeClass %>"><%= method.toUpperCase() %></span></td>
                        <td>
                          <% if(eVer == 1 || pVer == 1) { %>
                            <span style="color:#16a34a; font-weight:700;"><i class="fa-solid fa-circle-check"></i> Verified</span>
                          <% } else { %>
                            <span style="color:#dc2626; font-weight:600;"><i class="fa-solid fa-circle-xmark"></i> Unverified</span>
                          <% } %>
                        </td>
                        <td>
                          <% if("ACTIVE".equalsIgnoreCase(status)) { %>
                            <span class="badge-status" style="background:#dcfce7; color:#15803d;">ACTIVE</span>
                          <% } else { %>
                            <span class="badge-status" style="background:#fee2e2; color:#b91c1c;">BLOCKED</span>
                          <% } %>
                        </td>
                        <td>
                          <span style="font-weight:700; color:#ff385c;"><%= orderCount %> Orders</span> / 
                          <span style="font-weight:600; color:#64748b;"><%= reviewCount %> Reviews</span>
                        </td>
                        <td style="font-size:13px; color:#64748b;"><%= createdAt != null ? createdAt.substring(0, 10) : "" %></td>
                        <td>
                          <div style="display:flex; gap:6px;">
                            <a href="user_detail.jsp?id=<%= uId %>" class="btn-action btn-edit" title="View Full Activity Profile"><i class="fa-solid fa-eye"></i> Details</a>
                            <% if("ACTIVE".equalsIgnoreCase(status)) { %>
                              <a href="users.jsp?toggleId=<%= uId %>&status=BLOCKED" class="btn-action btn-delete" style="background:#ef4444; color:#fff;" onclick="return confirm('Suspend this user account?');"><i class="fa-solid fa-ban"></i> Block</a>
                            <% } else { %>
                              <a href="users.jsp?toggleId=<%= uId %>&status=ACTIVE" class="btn-action btn-edit" style="background:#22c55e; color:#fff;"><i class="fa-solid fa-check"></i> Unblock</a>
                            <% } %>
                          </div>
                        </td>
                    </tr>
                    <%
                            }
                            rs.close();
                            st.close();
                            con.close();
                        } catch(Exception e) {
                            out.println("<tr><td colspan='9'>Error: " + e.getMessage() + "</td></tr>");
                        }
                    }
                    %>
                </tbody>
            </table>
        </div>
    </div>

<script>
  document.getElementById("userSearchInput").addEventListener("keyup", filterUserTable);

  function filterUserTable() {
    const query = document.getElementById("userSearchInput").value.toLowerCase();
    const methodFilter = document.getElementById("methodFilterSelect").value;
    const statusFilter = document.getElementById("statusFilterSelect").value;
    const rows = document.querySelectorAll("#usersDataTable tbody tr");

    rows.forEach(row => {
      const text = row.innerText.toLowerCase();
      const rowMethod = row.getAttribute("data-method") || "";
      const rowStatus = row.getAttribute("data-status") || "";

      const matchesText = text.includes(query);
      const matchesMethod = !methodFilter || rowMethod === methodFilter;
      const matchesStatus = !statusFilter || rowStatus === statusFilter;

      if(matchesText && matchesMethod && matchesStatus) {
        row.style.display = "";
      } else {
        row.style.display = "none";
      }
    });
  }
</script>
</body>
</html>
