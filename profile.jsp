<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="dbconnection.jsp" %>

<%
request.setCharacterEncoding("UTF-8");
Map<String, Object> loggedUser = (Map<String, Object>) session.getAttribute("loggedUser");
if (loggedUser == null) {
    response.sendRedirect("login.jsp?redirect=profile.jsp&error=" + java.net.URLEncoder.encode("Please log in to view your profile.", "UTF-8"));
    return;
}

int userId = Integer.parseInt(loggedUser.get("user_id").toString());
String updateMsg = null;
String updateError = null;

/* UPDATE PROFILE LOGIC */
String action = request.getParameter("action");
if ("updateProfile".equals(action)) {
    String newName = request.getParameter("fullName");
    String newPhone = request.getParameter("phone");

    if (newName != null) newName = newName.trim().replaceAll("\\s+", " ");

    if (!isValidFullName(newName)) {
        updateError = "Name can contain only alphabets and spaces.";
    } else {
        Connection con = getDbConnection();
        if (con != null) {
            try {
                PreparedStatement ps = con.prepareStatement("UPDATE users SET full_name = ?, phone_number = ? WHERE user_id = ?");
                ps.setString(1, newName);
                ps.setString(2, newPhone != null && !newPhone.isEmpty() ? newPhone : null);
                ps.setInt(3, userId);
                ps.executeUpdate();
                ps.close();
                con.close();

                loggedUser.put("full_name", newName);
                loggedUser.put("phone_number", newPhone);
                session.setAttribute("loggedUser", loggedUser);
                session.setAttribute("userName", newName);
                session.setAttribute("userPhone", newPhone);

                updateMsg = "Profile updated successfully!";
            } catch (Exception e) {
                updateError = "Update failed: " + e.getMessage();
            }
        }
    }
} else if ("addAddress".equals(action)) {
    String addressLine = request.getParameter("addressLine");
    String city = request.getParameter("city");
    String pincode = request.getParameter("pincode");

    if (addressLine != null && !addressLine.trim().isEmpty()) {
        Connection con = getDbConnection();
        if (con != null) {
            try {
                PreparedStatement ps = con.prepareStatement("INSERT INTO user_addresses(user_id, address_line, city, pincode) VALUES(?, ?, ?, ?)");
                ps.setInt(1, userId);
                ps.setString(2, addressLine.trim());
                ps.setString(3, city != null ? city.trim() : "");
                ps.setString(4, pincode != null ? pincode.trim() : "");
                ps.executeUpdate();
                ps.close();
                con.close();
                updateMsg = "New address added!";
            } catch (Exception e) {
                updateError = "Failed to add address: " + e.getMessage();
            }
        }
    }
}

/* FETCH FRESH USER DATA */
String fullName = "";
String email = "";
String phone = "";
String createdAt = "";
boolean emailVerified = false;

Connection con = getDbConnection();
if (con != null) {
    try {
        PreparedStatement ps = con.prepareStatement("SELECT * FROM users WHERE user_id = ?");
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            fullName = rs.getString("full_name");
            email = rs.getString("email") != null ? rs.getString("email") : "";
            phone = rs.getString("phone_number") != null ? rs.getString("phone_number") : "";
            createdAt = rs.getString("created_at");
            emailVerified = rs.getInt("email_verified") == 1;
        }
        rs.close();
        ps.close();
    } catch (Exception e) {}
}

String initial = fullName != null && fullName.length() > 0 ? fullName.substring(0, 1).toUpperCase() : "U";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Account - Z Kitchen</title>
    
    <!-- STYLE CSS LINK -->
    <link rel="stylesheet" href="style.css">
    <!-- BOOTSTRAP CDN LINK -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FONT AWESOME CDN -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">

    <style>
      .profile-card {
        background: #ffffff;
        border-radius: 20px;
        padding: 30px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 10px 30px rgba(15, 23, 42, 0.05);
      }
      .avatar-large {
        width: 80px;
        height: 80px;
        border-radius: 50%;
        background: linear-gradient(135deg, #ff385c 0%, #ff758c 100%);
        color: #ffffff;
        font-weight: 800;
        font-size: 32px;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 8px 20px rgba(255, 56, 92, 0.3);
      }
      .order-history-card {
        background: #f8fafc;
        border-radius: 16px;
        padding: 20px;
        border: 1px solid #e2e8f0;
      }
    </style>
</head>
<body class="bg-light">

<!-- Navbar Start -->
<nav class="navbar navbar-expand-lg" id="navbar">
  <div class="container-fluid">
    <a href="index.jsp" class="navbar-brand" id="logo">
      <img src="./images/z kitchen.jpeg" alt="Z Kitchen Logo">
    </a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#mynavbar">
      <span><i class="fa-solid fa-bars text-dark fs-4"></i></span>
    </button>
    <div class="collapse navbar-collapse" id="mynavbar">
      <ul class="navbar-nav ms-auto align-items-center">
        <li class="nav-item"><a href="index.jsp" class="nav-link">Home</a></li>
        <li class="nav-item"><a href="Menu.jsp" class="nav-link">Menu</a></li>
        <li class="nav-item"><a href="Reviews.jsp" class="nav-link">Reviews</a></li>
        <li class="nav-item"><a href="About.jsp" class="nav-link">About</a></li>
        <li class="nav-item"><a href="Contact.jsp" class="nav-link">Contact</a></li>
        <li class="nav-item ms-lg-2">
          <a href="Order.jsp" class="nav-link position-relative me-2" title="View Cart">
            <i class="fa-solid fa-cart-shopping fs-5"></i>
            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger cart-count-badge" style="display:none;">0</span>
          </a>
        </li>
        <li class="nav-item ms-lg-2"><a href="my_orders.jsp" class="nav-link fw-bold"><i class="fa-solid fa-clock-rotate-left me-1"></i> My Orders</a></li>
        <li class="nav-item ms-lg-2"><a href="profile.jsp" class="nav-link active fw-bold"><i class="fa-solid fa-user me-1"></i> <%= fullName %></a></li>
        <li class="nav-item ms-lg-2"><a href="logout.jsp" class="btn btn-sm btn-outline-danger rounded-pill px-3 py-1 fw-bold"><i class="fa-solid fa-right-from-bracket me-1"></i> Logout</a></li>
      </ul>
    </div>
  </div>
</nav>
<!-- Navbar End -->

<section class="container py-5" style="margin-top: 90px;">
  <div class="row g-4">
    <!-- Left Sidebar Profile Summary -->
    <div class="col-lg-4">
      <div class="profile-card text-center mb-4">
        <div class="d-flex justify-content-center mb-3">
          <div class="avatar-large"><%= initial %></div>
        </div>
        <h4 class="fw-bold mb-1"><%= fullName %></h4>
        <p class="text-muted small mb-3"><%= email.isEmpty() ? phone : email %></p>
        
        <div class="d-flex justify-content-center gap-2 mb-3">
          <span class="badge bg-success bg-opacity-10 text-success border border-success px-3 py-2 rounded-pill small">
            <i class="fa-solid fa-circle-check me-1"></i> Verified Account
          </span>
        </div>

        <a href="my_orders.jsp" class="btn btn-danger w-100 rounded-pill fw-bold py-2 mb-3 shadow-sm">
          <i class="fa-solid fa-clock-rotate-left me-2"></i> My Orders & Live Tracking &rarr;
        </a>

        <hr>

        <div class="text-start small text-muted">
          <div class="mb-2"><i class="fa-solid fa-id-badge text-danger me-2"></i> User ID: <strong>#<%= userId %></strong></div>
          <div class="mb-2"><i class="fa-solid fa-calendar-check text-danger me-2"></i> Member Since: <strong><%= (createdAt != null && createdAt.trim().length() >= 10) ? createdAt.trim().substring(0, 10) : "2026" %></strong></div>
          <div><i class="fa-solid fa-shield-halved text-danger me-2"></i> Status: <strong class="text-success">Active Customer</strong></div>
        </div>
      </div>

      <!-- Saved Addresses -->
      <div class="profile-card">
        <h5 class="fw-bold mb-3 d-flex align-items-center gap-2">
          <i class="fa-solid fa-location-dot text-danger"></i> Saved Addresses
        </h5>

        <%
          boolean hasAddr = false;
          if(con != null) {
              try {
                  PreparedStatement addrPs = con.prepareStatement("SELECT * FROM user_addresses WHERE user_id = ? ORDER BY id DESC");
                  addrPs.setInt(1, userId);
                  ResultSet addrRs = addrPs.executeQuery();
                  while(addrRs.next()) {
                      hasAddr = true;
        %>
        <div class="p-3 bg-light rounded-3 mb-2 border">
          <div class="fw-bold text-dark small mb-1"><i class="fa-solid fa-house text-danger me-1"></i> Address</div>
          <div class="small text-secondary"><%= addrRs.getString("address_line") %>, <%= addrRs.getString("city") %> - <%= addrRs.getString("pincode") %></div>
        </div>
        <%
                  }
                  addrRs.close();
                  addrPs.close();
              } catch(Exception e){}
          }
          if(!hasAddr) {
        %>
        <p class="text-muted small mb-3">No saved addresses yet.</p>
        <% } %>

        <!-- Add Address Collapse Form -->
        <button type="button" class="btn btn-sm btn-outline-danger w-100 rounded-pill mt-2 fw-semibold" data-bs-toggle="collapse" data-bs-target="#addAddrForm">
          + Add New Address
        </button>

        <div class="collapse mt-3" id="addAddrForm">
          <form method="post" action="profile.jsp">
            <input type="hidden" name="action" value="addAddress">
            <div class="mb-2">
              <input type="text" name="addressLine" class="form-control form-control-sm" placeholder="Street Address / House No." required>
            </div>
            <div class="row g-2 mb-2">
              <div class="col-6">
                <input type="text" name="city" class="form-control form-control-sm" placeholder="City" required>
              </div>
              <div class="col-6">
                <input type="text" name="pincode" class="form-control form-control-sm" placeholder="Pincode" required>
              </div>
            </div>
            <button type="submit" class="btn btn-sm btn-danger w-100 rounded-pill fw-bold">Save Address</button>
          </form>
        </div>
      </div>
    </div>

    <!-- Right Content Tabs -->
    <div class="col-lg-8">
      <% if(updateMsg != null) { %>
      <div class="alert alert-success rounded-3 fs-6 p-3 mb-4 d-flex align-items-center gap-2">
        <i class="fa-solid fa-circle-check text-success fs-5"></i>
        <div><%= updateMsg %></div>
      </div>
      <% } %>

      <% if(updateError != null) { %>
      <div class="alert alert-danger rounded-3 fs-6 p-3 mb-4 d-flex align-items-center gap-2">
        <i class="fa-solid fa-triangle-exclamation text-danger fs-5"></i>
        <div><%= updateError %></div>
      </div>
      <% } %>

      <!-- Edit Profile Card -->
      <div class="profile-card mb-4">
        <h4 class="fw-bold mb-4 d-flex align-items-center gap-2">
          <i class="fa-solid fa-user-pen text-danger"></i> Profile Information
        </h4>

        <form method="post" action="profile.jsp" onsubmit="return validateProfileName()">
          <input type="hidden" name="action" value="updateProfile">

          <div class="row g-3">
            <div class="col-md-6">
              <label class="form-label fw-semibold">Full Name (Alphabets Only) *</label>
              <input type="text" name="fullName" id="profileNameInput" class="form-control" value="<%= fullName %>" required>
              <small class="text-danger fw-semibold" id="profileNameErr" style="display:none;">Name can contain only alphabets and spaces.</small>
            </div>

            <div class="col-md-6">
              <label class="form-label fw-semibold">Email Address (Read-only)</label>
              <input type="email" class="form-control bg-light" value="<%= email %>" readonly>
            </div>

            <div class="col-md-6">
              <label class="form-label fw-semibold">Phone Number</label>
              <input type="tel" name="phone" class="form-control" value="<%= phone %>" placeholder="e.g. +91 9876543210">
            </div>

            <div class="col-12 mt-4">
              <button type="submit" class="btn-primary-custom px-4 py-2.5 fw-bold">
                Save Profile Changes <i class="fa-solid fa-floppy-disk ms-2"></i>
              </button>
            </div>
          </div>
        </form>
      </div>

      <!-- Order History Card -->
      <div class="profile-card">
        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-4 pb-2 border-bottom">
          <h4 class="fw-bold mb-0 d-flex align-items-center gap-2">
            <i class="fa-solid fa-bag-shopping text-danger"></i> My Food Orders
          </h4>
          <a href="my_orders.jsp" class="btn btn-sm btn-outline-danger rounded-pill px-3 fw-bold">
            <i class="fa-solid fa-clock-rotate-left me-1"></i> View Full Live Tracking & History &rarr;
          </a>
        </div>

        <%
          boolean hasOrders = false;
          if(con != null) {
              try {
                  PreparedStatement ordPs = con.prepareStatement("SELECT * FROM orfood WHERE user_id = ? ORDER BY id DESC");
                  ordPs.setInt(1, userId);

                  ResultSet ordRs = ordPs.executeQuery();
                  while(ordRs.next()) {
                      hasOrders = true;
                      int orderId = ordRs.getInt("id");
                      String foodItems = sanitizeHtml(ordRs.getString("nm"));
                      String amount = sanitizeHtml(ordRs.getString("rs"));
                      String orderDate = sanitizeHtml(ordRs.getString("order_date"));
                      String status = sanitizeHtml(ordRs.getString("order_status"));
                      if(status == null || status.trim().isEmpty()) status = "Pending";

                      String badgeStyle = "background:#fef3c7; color:#92400e; border:1px solid #fcd34d;";
                      if("Confirmed".equalsIgnoreCase(status)) badgeStyle = "background:#e0f2fe; color:#0369a1; border:1px solid #7dd3fc;";
                      else if("Preparing".equalsIgnoreCase(status)) badgeStyle = "background:#fef08a; color:#854d0e; border:1px solid #fde047;";
                      else if("Ready".equalsIgnoreCase(status)) badgeStyle = "background:#dcfce7; color:#166534; border:1px solid #86efac;";
                      else if("Out for Delivery".equalsIgnoreCase(status)) badgeStyle = "background:#fae8ff; color:#86198f; border:1px solid #f0abfc;";
                      else if("Delivered".equalsIgnoreCase(status)) badgeStyle = "background:#dcfce7; color:#15803d; border:1px solid #4ade80;";
                      else if("Cancelled".equalsIgnoreCase(status)) badgeStyle = "background:#fee2e2; color:#991b1b; border:1px solid #fca5a5;";
        %>
        <div class="order-history-card mb-3">
          <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-2">
            <div>
              <span class="fw-bold text-dark fs-6">Order #ORD-<%= orderId %></span>
              <small class="text-muted ms-2"><i class="fa-solid fa-clock me-1"></i> <%= orderDate %></small>
            </div>
            <span class="badge px-3 py-1 rounded-pill fw-bold" style="<%= badgeStyle %>"><%= status %></span>
          </div>

          <div class="p-3 bg-white rounded-3 border mb-2">
            <div class="fw-semibold text-dark"><i class="fa-solid fa-utensils text-danger me-2"></i> Items:</div>
            <div class="text-secondary small mt-1"><%= foodItems %></div>
          </div>

          <div class="d-flex justify-content-between align-items-center">
            <span class="text-muted small">Total Paid:</span>
            <span class="fw-bold text-danger fs-5">&#8377; <%= amount %></span>
          </div>
        </div>
        <%
                  }
                  ordRs.close();
                  ordPs.close();
                  con.close();
              } catch(Exception e){}
          }

          if(!hasOrders) {
        %>
        <div class="text-center py-4">
          <i class="fa-solid fa-box-open display-4 text-muted mb-2"></i>
          <h6 class="fw-bold text-muted">No Orders Found Yet</h6>
          <p class="small text-muted mb-3">Explore our menu and place your first delicious food order!</p>
          <a href="Menu.jsp" class="btn-primary-custom px-4 py-2 small">Browse Menu &rarr;</a>
        </div>
        <% } %>
      </div>
    </div>
  </div>
</section>

<!-- Footer Start -->
<footer id="footer">
  <div class="footer-content">
    <div class="footer-logo"><img src="./images/z kitchen.jpeg" alt="Z Kitchen Logo"></div>
    <p class="text-muted small" style="max-width: 400px;">Serving delicious moments and authentic flavors with passion everyday.</p>
  </div>
  <div class="footer-copyright">
    <span>Designed & Developed By <a href="#">Nai Adil / Anas Munshi</a> &copy; 2026 Z Kitchen</span>
  </div>
</footer>
<!-- Footer End -->

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
  function validateProfileName() {
    const input = document.getElementById("profileNameInput");
    const err = document.getElementById("profileNameErr");
    const regex = /^[A-Za-z]+(?: [A-Za-z]+)*$/;

    if(!regex.test(input.value.trim())) {
      alert("Name can contain only alphabets and spaces.");
      err.style.display = "block";
      input.focus();
      return false;
    }
    err.style.display = "none";
    return true;
  }
</script>
</body>
</html>
