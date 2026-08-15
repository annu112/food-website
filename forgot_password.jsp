<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password - Z Kitchen</title>
    
    <!-- STYLE CSS LINK -->
    <link rel="stylesheet" href="style.css">
    <!-- BOOTSTRAP CDN LINK -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FONT AWESOME CDN -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">

    <style>
      .auth-card {
        background: #ffffff;
        border-radius: 24px;
        padding: 40px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 20px 40px rgba(15, 23, 42, 0.08);
      }
      .form-control-auth {
        border-radius: 12px;
        padding: 12px 18px;
        border: 1px solid #cbd5e1;
        font-size: 15px;
      }
      .form-control-auth:focus {
        border-color: #ff385c;
        box-shadow: 0 0 0 4px rgba(255, 56, 92, 0.12);
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
        <li class="nav-item ms-lg-2"><a href="login.jsp" class="nav-link active">Login</a></li>
        <li class="nav-item ms-lg-2"><a href="register.jsp" class="nav-link">Register</a></li>
      </ul>
    </div>
  </div>
</nav>
<!-- Navbar End -->

<%
  String error = request.getParameter("error");
  String msg = request.getParameter("msg");
%>

<section class="container py-5" style="margin-top: 90px; min-height: 80vh;">
  <div class="row justify-content-center">
    <div class="col-lg-5 col-md-7">
      <div class="auth-card">
        <div class="text-center mb-4">
          <div class="d-inline-flex align-items-center justify-content-center bg-danger text-white rounded-circle mb-3" style="width:60px; height:60px; font-size:24px;">
            <i class="fa-solid fa-key"></i>
          </div>
          <h2 class="fw-bold mt-1">Forgot Password?</h2>
          <p class="text-muted small">Enter your registered email or phone number. We will send an OTP code to reset your password.</p>
        </div>

        <% if(msg != null && !msg.isEmpty()) { %>
        <div class="alert alert-success rounded-3 fs-6 p-3 mb-4 d-flex align-items-center gap-2">
          <i class="fa-solid fa-circle-check text-success fs-5"></i>
          <div><%= msg %></div>
        </div>
        <% } %>

        <% if(error != null && !error.isEmpty()) { %>
        <div class="alert alert-danger rounded-3 fs-6 p-3 mb-4 d-flex align-items-center gap-2">
          <i class="fa-solid fa-triangle-exclamation text-danger fs-5"></i>
          <div><%= error %></div>
        </div>
        <% } %>

        <!-- FORGOT PASSWORD FORM -->
        <form method="post" action="forgot_password_process.jsp">
          <div class="mb-4">
            <label class="form-label fw-semibold">Registered Email or Phone Number *</label>
            <input type="text" name="identifier" class="form-control form-control-auth" placeholder="e.g. customer@gmail.com or +919876543210" required>
          </div>

          <button type="submit" class="btn-primary-custom w-100 py-3 fw-bold fs-6 mb-3">
            Send Reset OTP <i class="fa-solid fa-paper-plane ms-2"></i>
          </button>
        </form>

        <div class="text-center mt-3 pt-3 border-top">
          <a href="login.jsp" class="fw-bold text-secondary text-decoration-none small"><i class="fa-solid fa-arrow-left me-1"></i> Back to Login</a>
        </div>
      </div>
    </div>
  </div>
</section>

<!-- Footer Start -->
<footer id="footer">
  <div class="footer-content">
    <div class="footer-logo"><img src="./images/z kitchen.jpeg" alt="Z Kitchen Logo"></div>
  </div>
  <div class="footer-copyright">
    <span>Designed & Developed By <a href="#">Nai Adil / Anas Munshi</a> &copy; 2026 Z Kitchen</span>
  </div>
</footer>
<!-- Footer End -->

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
