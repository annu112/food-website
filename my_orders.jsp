<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="dbconnection.jsp" %>

<%
request.setCharacterEncoding("UTF-8");

Map<String, Object> loggedUser = (Map<String, Object>) session.getAttribute("loggedUser");
boolean navLoggedIn = (loggedUser != null);
String navName = navLoggedIn ? (String) loggedUser.get("full_name") : "User";
int userId = navLoggedIn && loggedUser.get("user_id") != null ? (Integer) loggedUser.get("user_id") : 0;
String userEmail = navLoggedIn && loggedUser.get("email") != null ? (String) loggedUser.get("email") : "";
String userPhone = navLoggedIn && loggedUser.get("phone_number") != null ? (String) loggedUser.get("phone_number") : "";

if(!navLoggedIn) {
    response.sendRedirect("login.jsp?redirect=my_orders.jsp");
    return;
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Orders & Live Status - Z Kitchen</title>
    <!-- STYLE CSS LINK -->
    <link rel="stylesheet" href="style.css">
    <!-- BOOTSTRAP CDN LINK -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FONT AWESOME CDN -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">

    <style>
      .order-card {
        background: #ffffff;
        border-radius: 20px;
        padding: 25px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 10px 30px rgba(15, 23, 42, 0.05);
        margin-bottom: 25px;
        transition: all 0.3s ease;
      }
      .order-card:hover {
        transform: translateY(-3px);
        box-shadow: 0 15px 35px rgba(15, 23, 42, 0.08);
      }
      .status-pill {
        padding: 6px 16px;
        border-radius: 30px;
        font-weight: 700;
        font-size: 13px;
        display: inline-flex;
        align-items: center;
        gap: 6px;
      }
      .status-pending { background: #fef3c7; color: #92400e; border: 1px solid #fcd34d; }
      .status-confirmed { background: #e0f2fe; color: #0369a1; border: 1px solid #7dd3fc; }
      .status-preparing { background: #fef08a; color: #854d0e; border: 1px solid #fde047; }
      .status-ready { background: #dcfce7; color: #166534; border: 1px solid #86efac; }
      .status-out-for-delivery { background: #fae8ff; color: #86198f; border: 1px solid #f0abfc; }
      .status-delivered { background: #dcfce7; color: #15803d; border: 1px solid #4ade80; }
      .status-cancelled { background: #fee2e2; color: #991b1b; border: 1px solid #fca5a5; }

      .stepper-wrapper {
        display: flex;
        justify-content: space-between;
        margin-top: 20px;
        padding-top: 20px;
        border-top: 1px dashed #cbd5e1;
        position: relative;
      }
      .stepper-item {
        flex: 1;
        text-align: center;
        position: relative;
        font-size: 12px;
        font-weight: 600;
        color: #94a3b8;
      }
      .stepper-item .step-counter {
        width: 34px;
        height: 34px;
        border-radius: 50%;
        background: #e2e8f0;
        color: #64748b;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 8px auto;
        font-size: 14px;
        font-weight: 700;
        transition: all 0.3s ease;
      }
      .stepper-item.active {
        color: #0f172a;
      }
      .stepper-item.active .step-counter {
        background: #ff385c;
        color: #ffffff;
        box-shadow: 0 4px 12px rgba(255, 56, 92, 0.3);
      }
      .stepper-item.completed .step-counter {
        background: #22c55e;
        color: #ffffff;
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
        <li class="nav-item ms-lg-2"><a href="my_orders.jsp" class="nav-link active fw-bold"><i class="fa-solid fa-clock-rotate-left me-1"></i> My Orders</a></li>
        <li class="nav-item ms-lg-2"><a href="profile.jsp" class="nav-link fw-bold"><i class="fa-solid fa-user me-1"></i> <%= navName %></a></li>
        <li class="nav-item ms-lg-2"><a href="logout.jsp" class="btn btn-sm btn-outline-danger rounded-pill px-3 py-1 fw-bold">Logout</a></li>
      </ul>
    </div>
  </div>
</nav>
<!-- Navbar End -->

<section class="container py-5" style="margin-top: 90px; min-height: 80vh;">
  <div class="d-flex justify-content-between align-items-center flex-wrap gap-3 mb-4">
    <div>
      <h2 class="fw-bold text-dark mb-1"><i class="fa-solid fa-bag-shopping text-danger me-2"></i> Client Order History</h2>
      <p class="text-muted mb-0">Track your current food deliveries & past orders in real-time</p>
    </div>
    <a href="Menu.jsp" class="btn-primary-custom px-4 py-2.5 fw-bold text-decoration-none">
      <i class="fa-solid fa-plus me-2"></i> Order More Food
    </a>
  </div>

  <%
    boolean hasOrders = false;
    Connection con = getDbConnection();
    if(con != null) {
        try {
            PreparedStatement ps = con.prepareStatement("SELECT * FROM orfood WHERE user_id = ? OR LOWER(email) = ? OR monumber = ? ORDER BY id DESC");
            ps.setInt(1, userId);
            ps.setString(2, userEmail.toLowerCase());
            ps.setString(3, userPhone);

            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                hasOrders = true;
                int orderId = rs.getInt("id");
                String items = sanitizeHtml(rs.getString("nm"));
                String price = sanitizeHtml(rs.getString("rs"));
                String cName = sanitizeHtml(rs.getString("cname"));
                String email = sanitizeHtml(rs.getString("email"));
                String phone = sanitizeHtml(rs.getString("monumber"));
                String address = sanitizeHtml(rs.getString("comm"));
                String status = sanitizeHtml(rs.getString("order_status"));
                if(status == null || status.trim().isEmpty()) status = "Pending";
                String orderDate = sanitizeHtml(rs.getString("order_date"));

                String pillClass = "status-pending";
                String statusIcon = "<i class=\"fa-solid fa-clock\"></i>";
                int stepIndex = 1;

                if("Confirmed".equalsIgnoreCase(status)) {
                    pillClass = "status-confirmed";
                    statusIcon = "<i class=\"fa-solid fa-thumbs-up\"></i>";
                    stepIndex = 2;
                } else if("Preparing".equalsIgnoreCase(status)) {
                    pillClass = "status-preparing";
                    statusIcon = "<i class=\"fa-solid fa-kitchen-set\"></i>";
                    stepIndex = 3;
                } else if("Ready".equalsIgnoreCase(status)) {
                    pillClass = "status-ready";
                    statusIcon = "<i class=\"fa-solid fa-box\"></i>";
                    stepIndex = 4;
                } else if("Out for Delivery".equalsIgnoreCase(status)) {
                    pillClass = "status-out-for-delivery";
                    statusIcon = "<i class=\"fa-solid fa-motorcycle\"></i>";
                    stepIndex = 5;
                } else if("Delivered".equalsIgnoreCase(status)) {
                    pillClass = "status-delivered";
                    statusIcon = "<i class=\"fa-solid fa-circle-check\"></i>";
                    stepIndex = 6;
                } else if("Cancelled".equalsIgnoreCase(status)) {
                    pillClass = "status-cancelled";
                    statusIcon = "<i class=\"fa-solid fa-circle-xmark\"></i>";
                    stepIndex = 0;
                }
                String payMethod = sanitizeHtml(rs.getString("payment_method"));
                String payStatus = sanitizeHtml(rs.getString("payment_status"));
                String rzpPayId = sanitizeHtml(rs.getString("razorpay_payment_id"));
                if(payMethod == null || payMethod.isEmpty()) payMethod = "Cash on Delivery";
                if(payStatus == null || payStatus.isEmpty() || "null".equalsIgnoreCase(payStatus)) payStatus = "PENDING";

                String payBadgeStyle = "background:#fef3c7; color:#92400e; border:1px solid #fcd34d;"; // Orange/Yellow for PENDING
                if("COMPLETED".equalsIgnoreCase(payStatus) || "PAID".equalsIgnoreCase(payStatus)) {
                    payStatus = "COMPLETED";
                    payBadgeStyle = "background:#dcfce7; color:#15803d; border:1px solid #4ade80;"; // Green for COMPLETED
                } else if("FAILED".equalsIgnoreCase(payStatus)) {
                    payBadgeStyle = "background:#fee2e2; color:#991b1b; border:1px solid #fca5a5;";
                }
  %>
  <div class="order-card">
    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
      <div>
        <h5 class="fw-bold text-dark mb-1">Order #ORD-<%= orderId %></h5>
        <small class="text-muted"><i class="fa-regular fa-calendar me-1"></i> Date: <%= orderDate %></small>
      </div>
      <div class="d-flex gap-2 align-items-center flex-wrap">
        <span class="badge px-3 py-2 rounded-pill fw-bold" style="<%= payBadgeStyle %>"><i class="fa-solid fa-credit-card me-1"></i> <%= payStatus %> (<%= payMethod %>)</span>
        <span class="status-pill <%= pillClass %>">
          <%= statusIcon %> <%= status %>
        </span>
      </div>
    </div>

    <div class="row g-3">
      <div class="col-md-7">
        <div class="p-3 bg-light rounded-3 border">
          <h6 class="fw-bold text-dark mb-2"><i class="fa-solid fa-burger text-danger me-2"></i> Ordered Items:</h6>
          <p class="text-secondary mb-0" style="white-space: pre-line;"><%= items %></p>
        </div>
      </div>
      <div class="col-md-5">
        <div class="p-3 bg-light rounded-3 border">
          <h6 class="fw-bold text-dark mb-2"><i class="fa-solid fa-location-dot text-danger me-2"></i> Delivery Address:</h6>
          <p class="text-secondary small mb-2"><%= address %></p>
          <div class="d-flex justify-content-between align-items-center pt-2 border-top">
            <span class="fw-bold text-dark">Total Amount:</span>
            <span class="fw-bold text-danger fs-5">&#8377; <%= price %></span>
          </div>
        </div>
      </div>
    </div>

    <% if(!"Cancelled".equalsIgnoreCase(status)) { %>
    <!-- Live Order Tracking Stepper -->
    <div class="stepper-wrapper">
      <div class="stepper-item <%= stepIndex >= 1 ? (stepIndex > 1 ? "completed" : "active") : "" %>">
        <div class="step-counter"><i class="fa-solid fa-file-lines"></i></div>
        <div>Placed</div>
      </div>
      <div class="stepper-item <%= stepIndex >= 2 ? (stepIndex > 2 ? "completed" : "active") : "" %>">
        <div class="step-counter"><i class="fa-solid fa-check"></i></div>
        <div>Confirmed</div>
      </div>
      <div class="stepper-item <%= stepIndex >= 3 ? (stepIndex > 3 ? "completed" : "active") : "" %>">
        <div class="step-counter"><i class="fa-solid fa-fire"></i></div>
        <div>Preparing</div>
      </div>
      <div class="stepper-item <%= stepIndex >= 5 ? (stepIndex > 5 ? "completed" : "active") : "" %>">
        <div class="step-counter"><i class="fa-solid fa-motorcycle"></i></div>
        <div>On the Way</div>
      </div>
      <div class="stepper-item <%= stepIndex >= 6 ? "completed active" : "" %>">
        <div class="step-counter"><i class="fa-solid fa-house-circle-check"></i></div>
        <div>Delivered</div>
      </div>
    </div>
    <% } %>
  </div>
  <%
            }
            rs.close();
            ps.close();
            con.close();
        } catch(Exception e) {
            out.println("<div class='alert alert-danger'>Error loading orders: " + e.getMessage() + "</div>");
        }
    }

    if(!hasOrders) {
  %>
  <div class="text-center py-5 bg-white rounded-4 shadow-sm border">
    <i class="fa-solid fa-utensils display-1 text-muted mb-3"></i>
    <h3 class="fw-bold text-dark">No Food Orders Found</h3>
    <p class="text-secondary mb-4">You haven't placed any delicious food orders yet.</p>
    <a href="Menu.jsp" class="btn-primary-custom px-5 py-3 fs-5 fw-bold shadow">
      Browse Food Menu Now <i class="fa-solid fa-arrow-right ms-2"></i>
    </a>
  </div>
  <% } %>
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
<script src="js/main.js"></script>
</body>
</html>
