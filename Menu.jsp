<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="dbconnection.jsp" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Menu - Z Kitchen</title>

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
        <li class="nav-item"><a href="index.jsp" class="nav-link">Home</a></li>
        <li class="nav-item"><a href="Menu.jsp" class="nav-link active">Menu</a></li>
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

<!-- Our Menu Start -->
<section class="menu" id="menu">
  <div class="section-header">
    <h5>OUR DELICIOUS DISHES</h5>
    <h2>Explore Our Flavoursome Menu</h2>
  </div>

  <!-- Search & Category Filters -->
  <div class="menu-controls">
    <div class="category-tabs">
      <button class="tab-btn active" data-category="all">All Items</button>
      <button class="tab-btn" data-category="Fast Food">Fast Food</button>
      <button class="tab-btn" data-category="Main Course">Main Course</button>
      <button class="tab-btn" data-category="Starters">Starters</button>
    </div>
    <div class="search-box">
      <i class="fa-solid fa-magnifying-glass"></i>
      <input type="text" id="menuSearch" placeholder="Search dish name...">
    </div>
  </div>

  <div class="row g-4" id="dishGrid">
    <%
      boolean hasProducts = false;
      try {
          Connection con = getDbConnection();
          if(con != null) {
              Statement st = con.createStatement();
              ResultSet rs = st.executeQuery("SELECT * FROM products ORDER BY id ASC");
              while(rs.next()) {
                  hasProducts = true;
                  int id = rs.getInt("id");
                  String name = rs.getString("name");
                  int price = rs.getInt("price");
                  String category = rs.getString("category") != null ? rs.getString("category") : "Fast Food";
                  String image = rs.getString("image");
                  if(image == null || image.trim().equals("")) {
                      image = "pizza.png";
                  }
    %>
    <div class="col-md-4 col-lg-3 dish-item-col" data-name="<%= name %>" data-category="<%= category %>">
      <div class="dish-card">
        <div class="dish-img-wrap">
          <span class="badge-category"><%= category %></span>
          <img src="./images/<%= image %>" alt="<%= name %>" onerror="this.src='./images/pizza.png'">
        </div>
        <div class="dish-body">
          <h3 class="dish-title"><%= name %></h3>
          <div class="dish-rating">
            <i class="fa-solid fa-star"></i>
            <i class="fa-solid fa-star"></i>
            <i class="fa-solid fa-star"></i>
            <i class="fa-solid fa-star"></i>
            <i class="fa-solid fa-star"></i>
            <span>(4.9)</span>
          </div>
          <div class="dish-footer d-flex align-items-center justify-content-between">
            <div class="dish-price">&#8377;<%= price %></div>
            <div class="d-flex gap-1">
              <button type="button" onclick="addToCart(<%= id %>, '<%= name.replace("'", "\\'") %>', <%= price %>, '<%= image %>', '<%= category %>', false)" class="btn btn-sm btn-outline-danger rounded-pill px-2 py-1 fw-bold" title="Add item to Cart">
                <i class="fa-solid fa-cart-plus me-1"></i> Add
              </button>
              <button type="button" onclick="addToCart(<%= id %>, '<%= name.replace("'", "\\'") %>', <%= price %>, '<%= image %>', '<%= category %>', true)" class="btn btn-sm btn-danger rounded-pill px-2 py-1 fw-bold shadow-sm" title="Order & Checkout">
                Order &rarr;
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    <%
              }
              con.close();
          }
      } catch(Exception e) {}

      if(!hasProducts) {
          String[][] staticDishes = {
              {"1", "Chicken Nuggets", "200", "Starters", "chicken nuggets.png"},
              {"2", "Garlic Bread", "150", "Starters", "Garlic bread.png"},
              {"3", "Chole Kulche", "250", "Main Course", "Chole Kulche.png"},
              {"4", "Fried Rice", "180", "Main Course", "Pineapple_Fried_Rice.png"},
              {"5", "Paneer Special", "300", "Main Course", "paneer.png"},
              {"6", "Crispy Chicken", "270", "Fast Food", "crispy_fried.png"},
              {"7", "Dahi Vada", "100", "Starters", "Dahi vada.png"},
              {"8", "Seekh Kabab", "250", "Starters", "Lyulya_kebab.png"},
              {"9", "Super Burger", "350", "Fast Food", "burger.png"},
              {"10", "Butter Chicken", "400", "Main Course", "butter chicken.jpeg"},
              {"11", "Biryani", "500", "Main Course", "Biryani.jpeg"},
              {"12", "Italian Pizza", "350", "Fast Food", "pizza.png"}
          };
          for(String[] dish : staticDishes) {
    %>
    <div class="col-md-4 col-lg-3 dish-item-col" data-name="<%= dish[1] %>" data-category="<%= dish[3] %>">
      <div class="dish-card">
        <div class="dish-img-wrap">
          <span class="badge-category"><%= dish[3] %></span>
          <img src="./images/<%= dish[4] %>" alt="<%= dish[1] %>">
        </div>
        <div class="dish-body">
          <h3 class="dish-title"><%= dish[1] %></h3>
          <div class="dish-rating">
            <i class="fa-solid fa-star"></i>
            <i class="fa-solid fa-star"></i>
            <i class="fa-solid fa-star"></i>
            <i class="fa-solid fa-star"></i>
            <i class="fa-solid fa-star"></i>
            <span>(4.8)</span>
          </div>
          <div class="dish-footer d-flex align-items-center justify-content-between">
            <div class="dish-price">&#8377;<%= dish[2] %></div>
            <div class="d-flex gap-1">
              <button type="button" onclick="addToCart(<%= dish[0] %>, '<%= dish[1].replace("'", "\\'") %>', <%= dish[2] %>, '<%= dish[4] %>', '<%= dish[3] %>', false)" class="btn btn-sm btn-outline-danger rounded-pill px-2 py-1 fw-bold" title="Add item to Cart">
                <i class="fa-solid fa-cart-plus me-1"></i> Add
              </button>
              <button type="button" onclick="addToCart(<%= dish[0] %>, '<%= dish[1].replace("'", "\\'") %>', <%= dish[2] %>, '<%= dish[4] %>', '<%= dish[3] %>', true)" class="btn btn-sm btn-danger rounded-pill px-2 py-1 fw-bold shadow-sm" title="Order & Checkout">
                Order &rarr;
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    <%
          }
      }
    %>
  </div>
</section>
<!-- Our Menu End -->

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