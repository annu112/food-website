<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contact Us - Z Kitchen</title>
    
    <!-- STYLE CSS LINK -->
    <link rel="stylesheet" href="style.css">
    <!-- BOOTSTRAP CDN LINK -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FONT AWESOME CDN -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">

    <style>
      .contact-info-card {
        background: #ffffff;
        border-radius: 20px;
        padding: 24px;
        border: 1px solid #e2e8f0;
        transition: all 0.3s ease;
        display: flex;
        align-items: center;
        gap: 20px;
      }
      .contact-info-card:hover {
        transform: translateY(-6px);
        box-shadow: 0 15px 30px rgba(15, 23, 42, 0.08);
        border-color: #ff385c;
      }
      .icon-circle {
        width: 60px;
        height: 60px;
        border-radius: 16px;
        background: rgba(255, 56, 92, 0.1);
        color: #ff385c;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 24px;
        flex-shrink: 0;
      }
    </style>
</head>
<body class="bg-light">

<%
  Map<String, Object> navUser = (Map<String, Object>) session.getAttribute("loggedUser");
  boolean navLoggedIn = (navUser != null);
  String navName = navLoggedIn && session.getAttribute("userName") != null ? session.getAttribute("userName").toString() : "";
  String navEmail = navLoggedIn && session.getAttribute("userEmail") != null ? session.getAttribute("userEmail").toString() : "";
  String navPhone = navLoggedIn && session.getAttribute("userPhone") != null ? session.getAttribute("userPhone").toString() : "";
%>
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
        <li class="nav-item"><a href="Contact.jsp" class="nav-link active">Contact</a></li>
        <li class="nav-item ms-lg-2">
          <a href="Order.jsp" class="nav-link position-relative me-2" title="View Cart">
            <i class="fa-solid fa-cart-shopping fs-5"></i>
            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger cart-count-badge" style="display:none;">0</span>
          </a>
        </li>
        <% if(navLoggedIn) { %>
        <li class="nav-item ms-lg-2"><a href="my_orders.jsp" class="nav-link fw-bold"><i class="fa-solid fa-clock-rotate-left me-1"></i> My Orders</a></li>
        <li class="nav-item ms-lg-2"><a href="profile.jsp" class="nav-link fw-bold"><i class="fa-solid fa-user me-1"></i> <%= navName %></a></li>
        <li class="nav-item ms-lg-2"><a href="logout.jsp" class="btn btn-sm btn-outline-danger rounded-pill px-3 py-1 fw-bold">Logout</a></li>
        <% } else { %>
        <li class="nav-item ms-lg-2"><a href="login.jsp?redirect=Contact.jsp" class="nav-link">Login</a></li>
        <li class="nav-item ms-lg-2"><a href="register.jsp?redirect=Contact.jsp" class="nav-link">Register</a></li>
        <% } %>
      </ul>
    </div>
  </div>
</nav>
<!-- Navbar End -->

<!-- Contact Header -->
<section class="container py-5" style="margin-top: 90px;">
  <div class="text-center mb-5">
    <span class="text-danger fw-bold text-uppercase tracking-wider">GET IN TOUCH</span>
    <h1 class="fw-bold mt-1 display-5">We'd Love To Hear From You</h1>
    <p class="text-muted fs-6 mx-auto" style="max-width: 550px;">Have a question about our menu, special catering inquiries, or feedback? Send us a message below!</p>
  </div>

  <%
    String conErr = request.getParameter("error");
    if(conErr != null && !conErr.isEmpty()) {
  %>
  <div class="alert alert-danger rounded-3 fs-6 p-3 mb-4 text-center max-w-600 mx-auto d-flex align-items-center justify-content-center gap-2">
    <i class="fa-solid fa-triangle-exclamation text-danger fs-4"></i>
    <div><%= conErr %></div>
  </div>
  <% } %>

  <div class="row g-4 mb-5">
    <!-- Phone Info Card -->
    <div class="col-md-6 col-lg-3">
      <div class="contact-info-card">
        <div class="icon-circle"><i class="fa-solid fa-phone"></i></div>
        <div>
          <small class="text-muted fw-semibold">Phone Support</small>
          <h6 class="mb-0 fw-bold mt-1"><a href="tel:+918154085562" class="text-dark text-decoration-none">+91 8154085562</a></h6>
        </div>
      </div>
    </div>

    <!-- Email Info Card -->
    <div class="col-md-6 col-lg-3">
      <div class="contact-info-card">
        <div class="icon-circle"><i class="fa-solid fa-envelope"></i></div>
        <div>
          <small class="text-muted fw-semibold">Email Us</small>
          <h6 class="mb-0 fw-bold mt-1"><a href="mailto:info@zkitchen.com" class="text-dark text-decoration-none">info@zkitchen.com</a></h6>
        </div>
      </div>
    </div>

    <!-- Location Info Card -->
    <div class="col-md-6 col-lg-3">
      <div class="contact-info-card">
        <div class="icon-circle"><i class="fa-solid fa-location-dot"></i></div>
        <div>
          <small class="text-muted fw-semibold">Our Location</small>
          <h6 class="mb-0 fw-bold mt-1">Noble University Campus, Junagadh</h6>
        </div>
      </div>
    </div>

    <!-- Hours Info Card -->
    <div class="col-md-6 col-lg-3">
      <div class="contact-info-card">
        <div class="icon-circle"><i class="fa-solid fa-clock"></i></div>
        <div>
          <small class="text-muted fw-semibold">Working Hours</small>
          <h6 class="mb-0 fw-bold mt-1">24 / 7 Always Open</h6>
        </div>
      </div>
    </div>
  </div>

  <!-- Contact Form & Card Container -->
  <div class="row justify-content-center">
    <div class="col-lg-9">

      <% if(!navLoggedIn) { %>
      <!-- CONTACT AUTHENTICATION BANNER -->
      <div class="alert alert-warning border-warning p-4 rounded-4 shadow-sm mb-4 d-flex align-items-center justify-content-between flex-wrap gap-3">
        <div>
          <h5 class="fw-bold text-dark mb-1"><i class="fa-solid fa-lock text-warning me-2"></i> Authentication Required To Send Message</h5>
          <p class="small text-muted mb-0">Guest users cannot submit contact inquiries. Please Sign In or Register to contact us.</p>
        </div>
        <div class="d-flex gap-2">
          <a href="login.jsp?redirect=Contact.jsp" class="btn btn-outline-dark rounded-pill px-4 fw-bold">Sign In</a>
          <a href="register.jsp?redirect=Contact.jsp" class="btn btn-danger rounded-pill px-4 fw-bold shadow">Register Now &rarr;</a>
        </div>
      </div>
      <% } %>

      <div class="bg-white p-4 p-md-5 rounded-4 shadow-sm border">
        <div class="mb-4">
          <h3 class="fw-bold mb-1">Send Us A Message</h3>
          <p class="text-muted">Fill out the form below and our support team will get back to you within 1 hour.</p>
        </div>

        <form method="post" action="conprocess.jsp" onsubmit="return handleContactSubmit()">
          <div class="row g-3">
            <div class="col-md-6">
              <label class="form-label fw-semibold">Full Name (Alphabets Only) *</label>
              <input type="text" name="nam" id="conNameInput" class="form-control form-control-lg fs-6" value="<%= navName %>" placeholder="Enter Your Full Name" required oninput="validateContactName(this)">
              <small class="text-danger fw-semibold" id="conNameErr" style="display:none;">Name can contain only alphabets and spaces.</small>
            </div>
            
            <div class="col-md-6">
              <label class="form-label fw-semibold">Email Address *</label>
              <input type="email" name="email" class="form-control form-control-lg fs-6" value="<%= navEmail %>" placeholder="name@example.com" required>
            </div>

            <div class="col-md-12">
              <label class="form-label fw-semibold">Phone Number *</label>
              <input type="tel" name="number" class="form-control form-control-lg fs-6" value="<%= navPhone %>" placeholder="Enter 10-digit Mobile Number" required pattern="[0-9]{10}">
            </div>

            <div class="col-12">
              <label class="form-label fw-semibold">Message / Inquiry *</label>
              <textarea name="comment" class="form-control form-control-lg fs-6" rows="4" placeholder="How can we help you today?" required></textarea>
            </div>

            <div class="col-12 mt-4">
              <button type="submit" class="btn-primary-custom w-100 py-3 fs-5 fw-bold shadow">
                Send Message <i class="fa-solid fa-paper-plane ms-2"></i>
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
  </div>
</section>

<!-- Footer Start -->
<footer id="footer">
  <div class="footer-content">
    <div class="footer-logo"><img src="./images/z kitchen.jpeg" alt="Z Kitchen Logo"></div>
    <p class="text-muted small" style="max-width: 400px;">Serving delicious moments and authentic flavors with passion everyday.</p>
    <div class="social-links">
      <a href="#" class="social-link"><i class="fa-brands fa-twitter"></i></a>
      <a href="#" class="social-link"><i class="fa-brands fa-instagram"></i></a>
      <a href="#" class="social-link"><i class="fa-brands fa-facebook-f"></i></a>
      <a href="#" class="social-link"><i class="fa-brands fa-youtube"></i></a>
    </div>
  </div>
  <div class="footer-copyright">
    <span>Designed & Developed By <a href="#">Nai Adil / Anas Munshi</a> &copy; 2026 Z Kitchen</span>
  </div>
</footer>
<!-- Footer End -->

<!-- JS LINKS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="js/main.js"></script>
<script>
  const userIsLoggedIn = <%= navLoggedIn %>;

  function validateContactName(input) {
    const err = document.getElementById("conNameErr");
    const regex = /^[A-Za-z]+(?: [A-Za-z]+)*$/;
    if(!regex.test(input.value.trim())) {
      err.style.display = "block";
      return false;
    } else {
      err.style.display = "none";
      return true;
    }
  }

  function handleContactSubmit() {
    if(!userIsLoggedIn) {
      alert("Authentication required! Please Sign In or Register to send a contact message.");
      window.location = "login.jsp?redirect=Contact.jsp";
      return false;
    }

    const input = document.getElementById("conNameInput");
    if(!validateContactName(input)) {
      alert("Name can contain only alphabets and spaces.");
      input.focus();
      return false;
    }

    return true;
  }
</script>
</body>
</html>