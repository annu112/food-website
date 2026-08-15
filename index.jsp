<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="dbconnection.jsp" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Z Kitchen - Delicious Food Delivered Fast</title>
    
    <!-- STYLE CSS LINK -->
    <link rel="stylesheet" href="style.css">
    <!-- BOOTSTRAP CDN LINK -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FONT AWESOME CDN -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
</head>
<body>

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
        <li class="nav-item"><a href="index.jsp" class="nav-link active">Home</a></li>
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

<!-- Hero Section Start -->
<section class="hero-section">
  <div class="container">
    <div class="row align-items-center g-5">
      <div class="col-lg-6">
        <div class="hero-badge"><i class="fa-solid fa-fire me-2"></i> Hot & Fresh Culinary Delights</div>
        <h1 class="hero-title">Taste The <span>Extraordinary</span> Food Delivered Fast!</h1>
        <p class="hero-desc">Indulge in handcrafted gourmet burgers, wood-fired cheesy pizzas, authentic dum biryanis, and crispy starters prepared fresh everyday by top master chefs.</p>
        <div class="hero-actions">
          <a href="Menu.jsp" class="btn-primary-custom">Order Food Now <i class="fa-solid fa-arrow-right ms-2"></i></a>
        </div>

        <div class="d-flex align-items-center gap-4 mt-4 pt-3 border-top">
          <div>
            <h3 class="fw-bold mb-0 text-danger">30+</h3>
            <small class="text-muted fw-semibold">Delicious Dishes</small>
          </div>
          <div class="vr"></div>
          <div>
            <h3 class="fw-bold mb-0 text-warning">4.9 ★</h3>
            <small class="text-muted fw-semibold">2,500+ Reviews</small>
          </div>
          <div class="vr"></div>
          <div>
            <h3 class="fw-bold mb-0 text-dark">25 Min</h3>
            <small class="text-muted fw-semibold">Express Delivery</small>
          </div>
        </div>
      </div>

      <div class="col-lg-6 text-center position-relative">
        <div class="hero-img-wrap">
          <div class="floating-pill-card top-left">
            <i class="fa-solid fa-star text-warning fs-5"></i>
            <div>
              <div class="fw-bold small">4.9 Rating</div>
              <small class="text-muted">Top Rated Kitchen</small>
            </div>
          </div>
          
          <img src="./images/burger.png" alt="Featured Gourmet Burger" class="hero-img">
          
          <div class="floating-pill-card bottom-right">
            <i class="fa-solid fa-motorcycle text-danger fs-4"></i>
            <div>
              <div class="fw-bold small">Express Delivery</div>
              <small class="text-muted">Hot & Fresh</small>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>
<!-- Hero Section End -->

<!-- Popular Categories Section -->
<section class="container my-5 py-3">
  <div class="section-header mb-4 text-start">
    <h5>WHAT WE SERVE</h5>
    <h2>Explore Popular Categories</h2>
  </div>

  <div class="row g-3">
    <div class="col-6 col-md-3">
      <a href="Menu.jsp?cat=Fast+Food" class="category-card">
        <div class="cat-icon"><i class="fa-solid fa-burger"></i></div>
        <h5 class="fw-bold mb-1">Fast Food</h5>
        <small class="text-muted">Burgers, Pizza & More</small>
      </a>
    </div>

    <div class="col-6 col-md-3">
      <a href="Menu.jsp?cat=Main+Course" class="category-card">
        <div class="cat-icon"><i class="fa-solid fa-bowl-rice"></i></div>
        <h5 class="fw-bold mb-1">Main Course</h5>
        <small class="text-muted">Biryani, Curries & Rice</small>
      </a>
    </div>

    <div class="col-6 col-md-3">
      <a href="Menu.jsp?cat=Starters" class="category-card">
        <div class="cat-icon"><i class="fa-solid fa-drumstick-bite"></i></div>
        <h5 class="fw-bold mb-1">Starters</h5>
        <small class="text-muted">Kabab, Nuggets & Snacks</small>
      </a>
    </div>

    <div class="col-6 col-md-3">
      <a href="Menu.jsp?cat=Starters" class="category-card">
        <div class="cat-icon"><i class="fa-solid fa-wine-glass"></i></div>
        <h5 class="fw-bold mb-1">Drinks & Shakes</h5>
        <small class="text-muted">Coolers & Beverages</small>
      </a>
    </div>
  </div>
</section>

<!-- Promo Offer Banner -->
<section class="container my-5">
  <div class="promo-banner">
    <div class="row align-items-center">
      <div class="col-lg-7">
        <span class="promo-badge">SPECIAL DISCOUNT OFFER</span>
        <h2 class="display-5 fw-bold mb-3 text-white">Get FLAT 25% OFF On Your First 3 Orders!</h2>
        <p class="text-white-50 fs-5 mb-4">Use promo code <strong class="text-warning">ZKITCHEN25</strong> at checkout to enjoy mouthwatering food delivered with zero delivery fees!</p>
        <a href="Menu.jsp" class="btn-primary-custom fs-6">Claim Discount & Order <i class="fa-solid fa-arrow-right ms-2"></i></a>
      </div>
      <div class="col-lg-5 text-center d-none d-lg-block">
        <img src="./images/pizza.png" alt="Special Pizza Offer" style="max-height:280px;" class="img-fluid animate-pulse">
      </div>
    </div>
  </div>
</section>

<!-- Features Highlights -->
<section class="container my-5 py-4">
  <div class="section-header">
    <h5>WHY CHOOSE US</h5>
    <h2>The Z Kitchen Experience</h2>
  </div>

  <div class="row g-4 text-center">
    <div class="col-md-4">
      <div class="feature-card p-4 rounded-4 shadow-sm bg-white border h-100">
        <div class="feature-icon text-danger fs-1 mb-3"><i class="fa-solid fa-bolt"></i></div>
        <h4 class="fw-bold">Superfast 25-Min Delivery</h4>
        <p class="text-muted small">Our dedicated delivery squad ensures your meals arrive hot, fresh, and perfectly packaged.</p>
      </div>
    </div>
    <div class="col-md-4">
      <div class="feature-card p-4 rounded-4 shadow-sm bg-white border h-100">
        <div class="feature-icon text-warning fs-1 mb-3"><i class="fa-solid fa-leaf"></i></div>
        <h4 class="fw-bold">100% Fresh Ingredients</h4>
        <p class="text-muted small">We source farm-fresh vegetables and premium spices to craft every single dish without preservatives.</p>
      </div>
    </div>
    <div class="col-md-4">
      <div class="feature-card p-4 rounded-4 shadow-sm bg-white border h-100">
        <div class="feature-icon text-success fs-1 mb-3"><i class="fa-solid fa-award"></i></div>
        <h4 class="fw-bold">Master Chef Recipes</h4>
        <p class="text-muted small">Prepared with authentic secret recipes by experienced culinary chefs passionate about flavor.</p>
      </div>
    </div>
  </div>
</section>

<!-- Floating Cart Bar -->
<div id="floatingCartBar" style="position:fixed; bottom:30px; right:30px; background:#0f172a; color:#fff; padding:14px 28px; border-radius:40px; box-shadow:0 10px 30px rgba(0,0,0,0.3); display:none; align-items:center; gap:20px; z-index:9999;">
  <div>
    <div style="font-size:12px; color:#94a3b8;">Selected Items</div>
    <div style="font-weight:700;"><span id="floatCartQty">0 items</span> | <span id="floatCartTotal" style="color:#ffb703;">&#8377;0</span></div>
  </div>
  <a href="Order.jsp" class="btn-primary-custom py-2 px-4" style="font-size:14px;">View Cart & Checkout &rarr;</a>
</div>

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