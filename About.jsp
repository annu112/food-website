<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About Us - Z Kitchen</title>
    <!-- STYLE CSS LINK -->
    <link rel="stylesheet" href="style.css">
    <!-- BOOTSTRAP CDN LINK -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FONT AWESOME CDN -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
</head>
<body class="bg-light">

<%
  Map<String, Object> navUser = (Map<String, Object>) session.getAttribute("loggedUser");
  boolean navLoggedIn = (navUser != null);
  String navName = navLoggedIn && session.getAttribute("userName") != null ? session.getAttribute("userName").toString() : "";
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
        <li class="nav-item"><a href="About.jsp" class="nav-link active">About</a></li>
        <li class="nav-item"><a href="Contact.jsp" class="nav-link">Contact</a></li>
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
        <li class="nav-item ms-lg-2"><a href="login.jsp" class="nav-link">Login</a></li>
        <li class="nav-item ms-lg-2"><a href="register.jsp" class="nav-link">Register</a></li>
        <% } %>
      </ul>
    </div>
  </div>
</nav>
<!-- Navbar End -->

<!-- About Section -->
<section class="about-hero py-5" style="margin-top: 80px; min-height: 70vh;">
    <div class="container">
        <div class="row align-items-center g-5">
            <div class="col-lg-6 text-center">
                <div class="position-relative">
                  <img src="./images/z kitchen.jpeg" alt="Z Kitchen Experience" class="img-fluid rounded-4 shadow-lg w-75">
                  <div class="badge-tag position-absolute bottom-0 start-50 translate-middle-x mb-n3 shadow">
                    <i class="fa-solid fa-award me-1"></i> Certified Quality 2026
                  </div>
                </div>
            </div>

            <div class="col-lg-6">
                <div class="badge-tag mb-2"><i class="fa-solid fa-utensils"></i> Discover Our Story</div>
                <h2 class="display-6 fw-bold mb-4">Quality Food, <br>Served With True Passion</h2>
                <p class="text-muted lead">
                    At <strong>Z Kitchen</strong>, we believe that every meal is a celebration. Founded on the principles of freshness and culinary authenticity, we bring you flavors that stay on your tongue and memories that stay in your heart.
                </p>
                <p class="text-muted mb-4">
                    Our master chefs use 100% locally sourced organic ingredients to craft dishes that aren't just food, but unforgettable dining experiences. From our kitchen to your table, we ensure absolute hygiene and perfection.
                </p>

                <div class="row g-3">
                    <div class="col-md-6">
                        <div class="feature-box d-flex align-items-center p-3 bg-white rounded-3 border">
                            <i class="fa-solid fa-truck-fast fs-2 text-danger me-3"></i>
                            <div>
                                <h6 class="mb-0 fw-bold">Fast Express Delivery</h6>
                                <p class="small mb-0 text-muted">Hot & Fresh under 20 mins</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="feature-box d-flex align-items-center p-3 bg-white rounded-3 border">
                            <i class="fa-solid fa-shield-halved fs-2 text-danger me-3"></i>
                            <div>
                                <h6 class="mb-0 fw-bold">100% Hygienic</h6>
                                <p class="small mb-0 text-muted">Strict kitchen standards</p>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="mt-4">
                    <a href="Menu.jsp" class="btn-primary-custom">Explore Full Menu <i class="fa-solid fa-arrow-right ms-2"></i></a>
                </div>
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
</body>
</html>