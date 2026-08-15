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

// Toggle Status (APPROVED / HIDDEN)
String toggleId = request.getParameter("toggleId");
String newStatus = request.getParameter("status");
if(toggleId != null && newStatus != null && con != null) {
    try {
        PreparedStatement ps = con.prepareStatement("UPDATE reviews SET status = ? WHERE id = ?");
        ps.setString(1, newStatus);
        ps.setInt(2, Integer.parseInt(toggleId));
        ps.executeUpdate();
        ps.close();
        con.close();
        response.sendRedirect("reviews.jsp");
        return;
    } catch(Exception e){}
}

// Delete Review
String deleteId = request.getParameter("delete");
if(deleteId != null && con != null) {
    try {
        PreparedStatement ps = con.prepareStatement("DELETE FROM reviews WHERE id = ?");
        ps.setInt(1, Integer.parseInt(deleteId));
        ps.executeUpdate();
        ps.close();
        con.close();
        response.sendRedirect("reviews.jsp");
        return;
    } catch(Exception e){}
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Reviews Moderation - Z Kitchen Admin</title>
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
      .rating-stars-visual {
        color: #ffb703;
        font-size: 14px;
      }
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
            <li><a href="users.jsp"><i class="fa-solid fa-users"></i> Users Management</a></li>
            <li><a href="login_activity.jsp"><i class="fa-solid fa-clock-rotate-left"></i> Login Activity</a></li>
            <li><a href="reg_activity.jsp"><i class="fa-solid fa-user-plus"></i> Registration Log</a></li>
            <li><a href="reviews.jsp" class="active"><i class="fa-solid fa-star"></i> Customer Reviews</a></li>
            <li><a href="contect.jsp"><i class="fa-solid fa-envelope"></i> Contact Messages</a></li>
            <li class="sidebar-logout"><a href="../index.jsp"><i class="fa-solid fa-right-from-bracket"></i> Logout</a></li>
        </ul>
    </div>

    <div class="main">
        <div class="top-bar">
            <h1>Customer Reviews & Moderation</h1>
            <div style="font-weight:600; color:#64748b;">Review customer feedback, ratings, and moderation status</div>
        </div>

        <div class="content-container">
            <div class="container-header" style="flex-direction:column; align-items:flex-start; gap:15px;">
                <h2>All Submitted Customer Reviews</h2>
                <div class="search-filter-bar w-100">
                    <input type="text" id="reviewSearchInput" class="search-input" placeholder="Search by customer name, comment..." style="max-width:350px;">
                    <select id="ratingFilterSelect" class="filter-select" onchange="filterReviewsTable()">
                        <option value="">All Ratings</option>
                        <option value="5">★★★★★ 5 Stars</option>
                        <option value="4">★★★★☆ 4 Stars</option>
                        <option value="3">★★★☆☆ 3 Stars</option>
                        <option value="2">★★☆☆☆ 2 Stars</option>
                        <option value="1">★☆☆☆☆ 1 Star</option>
                    </select>
                    <select id="statusFilterSelect" class="filter-select" onchange="filterReviewsTable()">
                        <option value="">All Statuses</option>
                        <option value="APPROVED">Approved</option>
                        <option value="HIDDEN">Hidden</option>
                    </select>
                </div>
            </div>

            <table id="reviewsDataTable">
                <thead>
                    <tr>
                        <th>Review ID</th>
                        <th>Customer Name</th>
                        <th>Email / User ID</th>
                        <th>Order ID</th>
                        <th>Rating Stars</th>
                        <th>Feedback Comment</th>
                        <th>Status</th>
                        <th>Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    if(con != null) {
                        try {
                            Statement st = con.createStatement();
                            ResultSet rs = st.executeQuery("SELECT r.*, u.email FROM reviews r LEFT JOIN users u ON r.user_id = u.user_id ORDER BY r.id DESC");
                            while(rs.next()) {
                                int rId = rs.getInt("id");
                                int uId = rs.getInt("user_id");
                                int oId = rs.getInt("order_id");
                                String name = sanitizeHtml(rs.getString("name"));
                                String email = sanitizeHtml(rs.getString("email"));
                                int rating = rs.getInt("rating");
                                String comment = sanitizeHtml(rs.getString("comment"));
                                String status = sanitizeHtml(rs.getString("status"));
                                if(status == null || status.isEmpty()) status = "APPROVED";
                                String createdAt = sanitizeHtml(rs.getString("created_at"));
                    %>
                    <tr data-rating="<%= rating %>" data-status="<%= status.toUpperCase() %>">
                        <td><strong>#REV-<%= rId %></strong></td>
                        <td><strong style="color:#0f172a;"><%= name %></strong></td>
                        <td>
                            <div><%= email != null ? email : "—" %></div>
                            <% if(uId > 0) { %><small style="color:#64748b;">User #<%= uId %></small><% } %>
                        </td>
                        <td><%= oId > 0 ? "#ORD-" + oId : "General" %></td>
                        <td class="rating-stars-visual">
                            <% for(int i=1; i<=5; i++) { %>
                                <i class="fa-solid fa-star <%= i <= rating ? "" : "text-muted" %>"></i>
                            <% } %>
                            <span style="font-weight:700; color:#0f172a; margin-left:4px;"><%= rating %>/5</span>
                        </td>
                        <td style="max-width:280px; font-size:14px; color:#475569;">"<%= comment %>"</td>
                        <td>
                          <% if("APPROVED".equalsIgnoreCase(status)) { %>
                            <span class="badge-status" style="background:#dcfce7; color:#15803d;">APPROVED</span>
                          <% } else { %>
                            <span class="badge-status" style="background:#fee2e2; color:#b91c1c;">HIDDEN</span>
                          <% } %>
                        </td>
                        <td style="font-size:13px; color:#64748b;"><%= (createdAt != null && createdAt.trim().length() >= 10) ? createdAt.trim().substring(0, 10) : "" %></td>
                        <td>
                          <div style="display:flex; gap:6px;">
                            <% if("APPROVED".equalsIgnoreCase(status)) { %>
                              <a href="reviews.jsp?toggleId=<%= rId %>&status=HIDDEN" class="btn-action btn-edit" style="background:#f59e0b; color:#fff;"><i class="fa-solid fa-eye-slash"></i> Hide</a>
                            <% } else { %>
                              <a href="reviews.jsp?toggleId=<%= rId %>&status=APPROVED" class="btn-action btn-edit" style="background:#22c55e; color:#fff;"><i class="fa-solid fa-check"></i> Approve</a>
                            <% } %>
                            <a href="reviews.jsp?delete=<%= rId %>" class="btn-action btn-delete" style="background:#ef4444; color:#fff;" onclick="return confirm('Delete this review permanently?');"><i class="fa-solid fa-trash"></i> Delete</a>
                          </div>
                        </td>
                    </tr>
                    <%
                            }
                            rs.close();
                            st.close();
                            con.close();
                        } catch(Exception e) {
                            out.println("<tr><td colspan='9'>Error loading reviews: " + e.getMessage() + "</td></tr>");
                        }
                    }
                    %>
                </tbody>
            </table>
        </div>
    </div>

<script>
  document.getElementById("reviewSearchInput").addEventListener("keyup", filterReviewsTable);

  function filterReviewsTable() {
    const query = document.getElementById("reviewSearchInput").value.toLowerCase();
    const ratingFilter = document.getElementById("ratingFilterSelect").value;
    const statusFilter = document.getElementById("statusFilterSelect").value;
    const rows = document.querySelectorAll("#reviewsDataTable tbody tr");

    rows.forEach(row => {
      const text = row.innerText.toLowerCase();
      const rowRating = row.getAttribute("data-rating") || "";
      const rowStatus = row.getAttribute("data-status") || "";

      const matchesText = text.includes(query);
      const matchesRating = !ratingFilter || rowRating === ratingFilter;
      const matchesStatus = !statusFilter || rowStatus === statusFilter;

      if(matchesText && matchesRating && matchesStatus) {
        row.style.display = "";
      } else {
        row.style.display = "none";
      }
    });
  }
</script>
</body>
</html>
