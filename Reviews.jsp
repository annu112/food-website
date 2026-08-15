<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="dbconnection.jsp" %>

<%
request.setCharacterEncoding("UTF-8");
Map<String, Object> loggedUser = (Map<String, Object>) session.getAttribute("loggedUser");
boolean navLoggedIn = (loggedUser != null);
String navName = navLoggedIn && session.getAttribute("userName") != null ? session.getAttribute("userName").toString() : "";
int navUserId = navLoggedIn ? Integer.parseInt(loggedUser.get("user_id").toString()) : 0;

String rName = request.getParameter("name");
String rRating = request.getParameter("rating");
String rComment = request.getParameter("comment");

if (rName != null && rComment != null) {
    if (!navLoggedIn) {
        response.sendRedirect("login.jsp?redirect=Reviews.jsp&error=" + java.net.URLEncoder.encode("Please sign in or register before submitting a review.", "UTF-8"));
        return;
    }

    if (rName != null) rName = rName.trim().replaceAll("\\s+", " ");
    if (!isValidFullName(rName)) {
        response.sendRedirect("Reviews.jsp?error=" + java.net.URLEncoder.encode("Name can contain only alphabets and spaces.", "UTF-8"));
        return;
    }

    int ratingInt = 5;
    try {
        if(rRating != null) ratingInt = Integer.parseInt(rRating);
    } catch(Exception e) {}
    if(ratingInt < 1) ratingInt = 1;
    if(ratingInt > 5) ratingInt = 5;

    String cleanName = sanitizeHtml(rName);
    String cleanComment = sanitizeHtml(rComment);

    try {
        Connection con = getDbConnection();
        if(con != null) {
            PreparedStatement ps = con.prepareStatement("INSERT INTO reviews(user_id, name, rating, comment) VALUES(?, ?, ?, ?)");
            ps.setInt(1, navUserId);
            ps.setString(2, cleanName);
            ps.setInt(3, ratingInt);
            ps.setString(4, cleanComment);
            ps.executeUpdate();
            ps.close();
            con.close();
            response.sendRedirect("Reviews.jsp?submitted=true");
            return;
        }
    } catch (Exception e) {}
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Reviews - Z Kitchen</title>
    
    <!-- STYLE CSS LINK -->
    <link rel="stylesheet" href="style.css">
    <!-- BOOTSTRAP CDN LINK -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FONT AWESOME CDN -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">

    <style>
      .review-card {
        background: #ffffff;
        border-radius: 20px;
        padding: 28px;
        border: 1px solid #e2e8f0;
        transition: all 0.3s ease;
        height: 100%;
        display: flex;
        flex-direction: column;
      }
      .review-card:hover {
        transform: translateY(-6px);
        box-shadow: 0 15px 30px rgba(15, 23, 42, 0.08);
        border-color: #ff385c;
      }
      .avatar-circle {
        width: 52px;
        height: 52px;
        border-radius: 50%;
        background: linear-gradient(135deg, #ff385c 0%, #ff758c 100%);
        color: #ffffff;
        font-weight: 800;
        font-size: 20px;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        box-shadow: 0 6px 15px rgba(255, 56, 92, 0.3);
      }
      .rating-stars {
        color: #ffb703;
        font-size: 14px;
      }
      .star-picker i {
        font-size: 28px;
        color: #cbd5e1;
        cursor: pointer;
        transition: all 0.2s ease;
      }
      .star-picker i.active {
        color: #ffb703;
        transform: scale(1.15);
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
        <li class="nav-item"><a href="Reviews.jsp" class="nav-link active">Reviews</a></li>
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
        <li class="nav-item ms-lg-2"><a href="login.jsp?redirect=Reviews.jsp" class="nav-link">Login</a></li>
        <li class="nav-item ms-lg-2"><a href="register.jsp?redirect=Reviews.jsp" class="nav-link">Register</a></li>
        <% } %>
      </ul>
    </div>
  </div>
</nav>
<!-- Navbar End -->

<!-- Reviews Section Start -->
<section class="container py-5" style="margin-top: 90px;">
  <div class="text-center mb-5">
    <span class="text-danger fw-bold text-uppercase tracking-wider">CUSTOMER TESTIMONIALS</span>
    <h1 class="fw-bold mt-1 display-5">What Food Lovers Say About Us</h1>
    <p class="text-muted fs-6 mx-auto" style="max-width: 550px;">Real reviews from our awesome customers. Read their stories or share your experience below!</p>
  </div>

  <%
    String submitted = request.getParameter("submitted");
    String revError = request.getParameter("error");
    if("true".equals(submitted)) {
  %>
  <div class="alert alert-success rounded-3 fs-6 p-3 mb-4 text-center max-w-600 mx-auto d-flex align-items-center justify-content-center gap-2">
    <i class="fa-solid fa-circle-check text-success fs-4"></i>
    <div>Thank you for your feedback! Your review has been posted successfully.</div>
  </div>
  <% } %>

  <% if(revError != null && !revError.isEmpty()) { %>
  <div class="alert alert-danger rounded-3 fs-6 p-3 mb-4 text-center max-w-600 mx-auto d-flex align-items-center justify-content-center gap-2">
    <i class="fa-solid fa-triangle-exclamation text-danger fs-4"></i>
    <div><%= revError %></div>
  </div>
  <% } %>

  <!-- Leave A Review Form Container -->
  <div class="row justify-content-center mb-5">
    <div class="col-lg-8">

      <% if(!navLoggedIn) { %>
      <!-- REVIEW AUTHENTICATION BANNER -->
      <div class="alert alert-warning border-warning p-4 rounded-4 shadow-sm mb-4 d-flex align-items-center justify-content-between flex-wrap gap-3">
        <div>
          <h5 class="fw-bold text-dark mb-1"><i class="fa-solid fa-lock text-warning me-2"></i> Authentication Required To Post Review</h5>
          <p class="small text-muted mb-0">Guest users cannot submit reviews. Please Sign In or Register to share your rating.</p>
        </div>
        <div class="d-flex gap-2">
          <a href="login.jsp?redirect=Reviews.jsp" class="btn btn-outline-dark rounded-pill px-4 fw-bold">Sign In</a>
          <a href="register.jsp?redirect=Reviews.jsp" class="btn btn-danger rounded-pill px-4 fw-bold shadow">Register Now &rarr;</a>
        </div>
      </div>
      <% } %>

      <div class="bg-white p-4 p-md-5 rounded-4 shadow-sm border">
        <h4 class="fw-bold mb-3 d-flex align-items-center gap-2">
          <i class="fa-solid fa-pen-to-square text-danger"></i> Leave a Review
        </h4>

        <form method="post" action="Reviews.jsp" onsubmit="return handleReviewSubmit()">
          <div class="row g-3">
            <div class="col-md-6">
              <label class="form-label fw-semibold">Your Name (Alphabets Only) *</label>
              <input type="text" name="name" id="revNameInput" class="form-control form-control-lg fs-6" value="<%= navName %>" placeholder="Enter Your Full Name" required oninput="validateReviewName(this)">
              <small class="text-danger fw-semibold" id="revNameErr" style="display:none;">Name can contain only alphabets and spaces.</small>
            </div>

            <div class="col-md-6">
              <label class="form-label fw-semibold">Rating *</label>
              <div class="star-picker d-flex align-items-center gap-2 pt-1" id="starRatingSelect">
                <i class="fa-solid fa-star active"></i>
                <i class="fa-solid fa-star active"></i>
                <i class="fa-solid fa-star active"></i>
                <i class="fa-solid fa-star active"></i>
                <i class="fa-solid fa-star active"></i>
              </div>
              <input type="hidden" name="rating" id="ratingValueInput" value="5">
            </div>

            <div class="col-12">
              <label class="form-label fw-semibold">Your Experience / Feedback *</label>
              <textarea name="comment" class="form-control form-control-lg fs-6" rows="3" placeholder="Tell us about the food quality, speed, or service..." required></textarea>
            </div>

            <div class="col-12 mt-4">
              <button type="submit" class="btn-primary-custom w-100 py-3 fs-5 fw-bold shadow">
                Submit Review <i class="fa-solid fa-paper-plane ms-2"></i>
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
  </div>

  <!-- Customer Reviews Grid -->
  <div class="row g-4">
    <%
      boolean hasReviews = false;
      try {
          Connection con = getDbConnection();
          if(con != null) {
              // Fetch only APPROVED customer reviews
              Statement st = con.createStatement();
              ResultSet rs = st.executeQuery("SELECT * FROM reviews WHERE status = 'APPROVED' OR status IS NULL ORDER BY id DESC");
              while(rs.next()) {
                  hasReviews = true;
                  String name = sanitizeHtml(rs.getString("name"));
                  int rating = rs.getInt("rating");
                  String comment = sanitizeHtml(rs.getString("comment"));
                  String initial = name != null && name.trim().length() > 0 ? name.trim().substring(0, 1).toUpperCase() : "U";
    %>
    <div class="col-md-6">
      <div class="review-card shadow-sm">
        <div class="d-flex align-items-center gap-3 mb-3">
          <div class="avatar-circle"><%= initial %></div>
          <div>
            <h5 class="mb-0 fw-bold"><%= name %></h5>
            <div class="d-flex align-items-center gap-2">
              <small class="text-success fw-semibold"><i class="fa-solid fa-circle-check"></i> Verified Customer</small>
            </div>
          </div>
        </div>

        <div class="rating-stars mb-3">
          <% for(int i=1; i<=5; i++) { %>
            <i class="fa-solid fa-star <%= i <= rating ? "text-warning" : "text-muted" %>"></i>
          <% } %>
        </div>

        <p class="text-secondary fs-6 mb-0" style="line-height: 1.6;">"<%= comment %>"</p>
      </div>
    </div>
    <%
              }
              rs.close();
              st.close();
              con.close();
          }
      } catch(Exception e) {}

      if(!hasReviews) {
    %>
    <div class="col-12 text-center py-5">
      <div class="p-5 bg-white rounded-4 shadow-sm border" style="max-width: 500px; margin: 0 auto;">
        <i class="fa-regular fa-star display-3 text-warning mb-3"></i>
        <h4 class="fw-bold text-dark">No Customer Reviews Yet</h4>
        <p class="text-muted mb-0">Be the first customer to share your dining experience with us!</p>
      </div>
    </div>
    <%
      }
    %>
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

<!-- JS LINKS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="js/main.js"></script>
<script>
  const userIsLoggedIn = <%= navLoggedIn %>;

  function validateReviewName(input) {
    const err = document.getElementById("revNameErr");
    const regex = /^[A-Za-z]+(?: [A-Za-z]+)*$/;
    if(!regex.test(input.value.trim())) {
      err.style.display = "block";
      return false;
    } else {
      err.style.display = "none";
      return true;
    }
  }

  function handleReviewSubmit() {
    if(!userIsLoggedIn) {
      alert("Authentication required! Please Sign In or Register to post a review.");
      window.location = "login.jsp?redirect=Reviews.jsp";
      return false;
    }

    const input = document.getElementById("revNameInput");
    if(!validateReviewName(input)) {
      alert("Name can contain only alphabets and spaces.");
      input.focus();
      return false;
    }

    return true;
  }

  // Star Rating Selector Logic
  const stars = document.querySelectorAll("#starRatingSelect i");
  const ratingInput = document.getElementById("ratingValueInput");

  stars.forEach((star, idx) => {
    star.addEventListener("click", () => {
      ratingInput.value = idx + 1;
      stars.forEach((s, sIdx) => {
        if(sIdx <= idx) {
          s.classList.add("active");
        } else {
          s.classList.remove("active");
        }
      });
    });
  });
</script>
</body>
</html>