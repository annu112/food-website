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

String idStr = request.getParameter("id");
if(idStr == null || idStr.trim().isEmpty()) {
    response.sendRedirect("users.jsp");
    return;
}

int targetUserId = Integer.parseInt(idStr.trim());
Connection con = getDbConnection();

String fullName = "";
String email = "";
String phone = "";
String googleId = "";
String regMethod = "";
int emailVer = 0;
int phoneVer = 0;
String status = "ACTIVE";
String createdAt = "";
String lastLogin = "";

if(con != null) {
    try {
        PreparedStatement ps = con.prepareStatement("SELECT * FROM users WHERE user_id = ?");
        ps.setInt(1, targetUserId);
        ResultSet rs = ps.executeQuery();
        if(rs.next()) {
            fullName = rs.getString("full_name");
            email = rs.getString("email") != null ? rs.getString("email") : "—";
            phone = rs.getString("phone_number") != null ? rs.getString("phone_number") : "—";
            googleId = rs.getString("google_id") != null ? rs.getString("google_id") : "—";
            regMethod = rs.getString("registration_method") != null ? rs.getString("registration_method") : "EMAIL";
            emailVer = rs.getInt("email_verified");
            phoneVer = rs.getInt("phone_verified");
            status = rs.getString("account_status") != null ? rs.getString("account_status") : "ACTIVE";
            createdAt = rs.getString("created_at");
            lastLogin = rs.getString("last_login") != null ? rs.getString("last_login") : "Never";
        } else {
            rs.close();
            ps.close();
            con.close();
            response.sendRedirect("users.jsp");
            return;
        }
        rs.close();
        ps.close();
    } catch(Exception e){}
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Profile Details - Z Kitchen Admin</title>
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <style>
      .user-detail-card {
        background: #ffffff;
        border-radius: 16px;
        padding: 25px;
        border: 1px solid #e2e8f0;
        margin-bottom: 25px;
      }
      .detail-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: 20px;
        margin-top: 15px;
      }
      .detail-item label {
        font-size: 13px;
        color: #64748b;
        font-weight: 600;
        display: block;
        margin-bottom: 4px;
      }
      .detail-item div {
        font-size: 16px;
        font-weight: 700;
        color: #0f172a;
      }
      .section-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 15px;
        border-bottom: 2px solid #f1f5f9;
        padding-bottom: 10px;
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
            <li><a href="users.jsp" class="active"><i class="fa-solid fa-users"></i> Users Management</a></li>
            <li><a href="login_activity.jsp"><i class="fa-solid fa-clock-rotate-left"></i> Login Activity</a></li>
            <li><a href="reg_activity.jsp"><i class="fa-solid fa-user-plus"></i> Registration Log</a></li>
            <li><a href="contect.jsp"><i class="fa-solid fa-envelope"></i> Contact Messages</a></li>
            <li class="sidebar-logout"><a href="../index.jsp"><i class="fa-solid fa-right-from-bracket"></i> Logout</a></li>
        </ul>
    </div>

    <div class="main">
        <div class="top-bar">
            <h1>User Activity & Account Profile</h1>
            <a href="users.jsp" style="color:#ff385c; font-weight:700; text-decoration:none;">&larr; Back to Users List</a>
        </div>

        <!-- 1. ACCOUNT INFORMATION CARD -->
        <div class="user-detail-card">
            <div class="section-header">
                <h2><i class="fa-solid fa-id-card text-danger me-2"></i> Account Information</h2>
                <div>
                    <% if("ACTIVE".equalsIgnoreCase(status)) { %>
                        <a href="users.jsp?toggleId=<%= targetUserId %>&status=BLOCKED" class="btn-action btn-delete" style="background:#ef4444; color:#fff;" onclick="return confirm('Suspend user?');"><i class="fa-solid fa-ban"></i> Block User Account</a>
                    <% } else { %>
                        <a href="users.jsp?toggleId=<%= targetUserId %>&status=ACTIVE" class="btn-action btn-edit" style="background:#22c55e; color:#fff;"><i class="fa-solid fa-check"></i> Unblock Account</a>
                    <% } %>
                </div>
            </div>

            <div class="detail-grid">
                <div class="detail-item">
                    <label>User ID</label>
                    <div>#<%= targetUserId %></div>
                </div>
                <div class="detail-item">
                    <label>Full Name</label>
                    <div><%= fullName %></div>
                </div>
                <div class="detail-item">
                    <label>Email Address</label>
                    <div><%= email %></div>
                </div>
                <div class="detail-item">
                    <label>Phone Number</label>
                    <div><%= phone %></div>
                </div>
                <div class="detail-item">
                    <label>Reg Method</label>
                    <div><span class="badge-status" style="background:#f1f5f9; color:#0f172a;"><%= regMethod.toUpperCase() %></span></div>
                </div>
                <div class="detail-item">
                    <label>Account Status</label>
                    <div>
                      <% if("ACTIVE".equalsIgnoreCase(status)) { %>
                        <span style="color:#16a34a;"><i class="fa-solid fa-circle-check"></i> Active</span>
                      <% } else { %>
                        <span style="color:#dc2626;"><i class="fa-solid fa-ban"></i> Suspended</span>
                      <% } %>
                    </div>
                </div>
                <div class="detail-item">
                    <label>Verification Status</label>
                    <div><%= emailVer == 1 || phoneVer == 1 ? "Verified ✔️" : "Unverified" %></div>
                </div>
                <div class="detail-item">
                    <label>Registration Date</label>
                    <div><%= createdAt %></div>
                </div>
                <div class="detail-item">
                    <label>Last Login</label>
                    <div><%= lastLogin %></div>
                </div>
            </div>
        </div>

        <!-- 2. ORDER HISTORY CARD -->
        <div class="user-detail-card">
            <div class="section-header">
                <h2><i class="fa-solid fa-bag-shopping text-danger me-2"></i> Order History</h2>
            </div>
            <table>
                <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>Items Ordered</th>
                        <th>Amount Paid</th>
                        <th>Delivery Contact</th>
                        <th>Order Timestamp</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    int orderCount = 0;
                    if(con != null) {
                        try {
                            PreparedStatement ordPs = con.prepareStatement("SELECT * FROM orfood WHERE user_id = ? OR LOWER(email) = ? OR monumber = ? ORDER BY id DESC");
                            ordPs.setInt(1, targetUserId);
                            ordPs.setString(2, email.toLowerCase());
                            ordPs.setString(3, phone);
                            ResultSet ordRs = ordPs.executeQuery();
                            while(ordRs.next()) {
                                orderCount++;
                    %>
                    <tr>
                        <td><strong>#ORD-<%= ordRs.getInt("id") %></strong></td>
                        <td><%= sanitizeHtml(ordRs.getString("nm")) %></td>
                        <td style="font-weight:700; color:#ff385c;">&#8377; <%= sanitizeHtml(ordRs.getString("rs")) %></td>
                        <td><%= sanitizeHtml(ordRs.getString("monumber")) %></td>
                        <td style="font-size:13px; color:#64748b;"><%= sanitizeHtml(ordRs.getString("order_date")) %></td>
                    </tr>
                    <%
                            }
                            ordRs.close();
                            ordPs.close();
                        } catch(Exception e){}
                    }
                    if(orderCount == 0) {
                    %>
                    <tr><td colspan="5" style="text-align:center; padding:20px; color:#64748b;">No food orders placed by this user yet.</td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <!-- 3. REVIEWS HISTORY CARD -->
        <div class="user-detail-card">
            <div class="section-header">
                <h2><i class="fa-solid fa-star text-warning me-2"></i> Submitted Reviews</h2>
            </div>
            <table>
                <thead>
                    <tr>
                        <th>Review ID</th>
                        <th>Rating Stars</th>
                        <th>Feedback Comment</th>
                        <th>Posted Date</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    int reviewCount = 0;
                    if(con != null) {
                        try {
                            PreparedStatement revPs = con.prepareStatement("SELECT * FROM reviews WHERE user_id = ? OR LOWER(name) = ? ORDER BY id DESC");
                            revPs.setInt(1, targetUserId);
                            revPs.setString(2, fullName.toLowerCase());
                            ResultSet revRs = revPs.executeQuery();
                            while(revRs.next()) {
                                reviewCount++;
                                int rating = revRs.getInt("rating");
                    %>
                    <tr>
                        <td><strong>#REV-<%= revRs.getInt("id") %></strong></td>
                        <td style="color:#ffb703;">
                            <% for(int i=1; i<=5; i++) { %>
                                <i class="fa-solid fa-star <%= i <= rating ? "" : "text-muted" %>"></i>
                            <% } %>
                        </td>
                        <td>"<%= revRs.getString("comment") %>"</td>
                        <td style="font-size:13px; color:#64748b;"><%= revRs.getString("created_at") %></td>
                    </tr>
                    <%
                            }
                            revRs.close();
                            revPs.close();
                        } catch(Exception e){}
                    }
                    if(reviewCount == 0) {
                    %>
                    <tr><td colspan="4" style="text-align:center; padding:20px; color:#64748b;">No reviews submitted by this user yet.</td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <!-- 4. LOGIN ACTIVITY HISTORY CARD -->
        <div class="user-detail-card">
            <div class="section-header">
                <h2><i class="fa-solid fa-clock-rotate-left text-danger me-2"></i> User Login Activity Audit</h2>
            </div>
            <table>
                <thead>
                    <tr>
                        <th>Log ID</th>
                        <th>Login Timestamp</th>
                        <th>OTP Verification</th>
                        <th>Login Result</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    int logCount = 0;
                    if(con != null) {
                        try {
                            PreparedStatement logPs = con.prepareStatement("SELECT * FROM login_activity WHERE user_id = ? OR LOWER(user_identifier) = ? OR user_identifier = ? ORDER BY login_id DESC LIMIT 20");
                            logPs.setInt(1, targetUserId);
                            logPs.setString(2, email.toLowerCase());
                            logPs.setString(3, phone);
                            ResultSet logRs = logPs.executeQuery();
                            while(logRs.next()) {
                                logCount++;
                                int otpVer = logRs.getInt("otp_verified");
                                String lStatus = logRs.getString("login_status");
                    %>
                    <tr>
                        <td><strong>#LOG-<%= logRs.getInt("login_id") %></strong></td>
                        <td><%= logRs.getString("login_time") %></td>
                        <td><%= otpVer == 1 ? "Verified ✔️" : "Unverified ❌" %></td>
                        <td><span class="badge-status" style="background:#f1f5f9; color:#0f172a;"><%= lStatus.toUpperCase() %></span></td>
                    </tr>
                    <%
                            }
                            logRs.close();
                            logPs.close();
                            con.close();
                        } catch(Exception e){}
                    }
                    if(logCount == 0) {
                    %>
                    <tr><td colspan="4" style="text-align:center; padding:20px; color:#64748b;">No login activity logs recorded yet.</td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>

    </div>
</body>
</html>
