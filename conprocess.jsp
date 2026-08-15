<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="dbconnection.jsp" %>

<%
request.setCharacterEncoding("UTF-8");
Map<String, Object> loggedUser = (Map<String, Object>) session.getAttribute("loggedUser");
if(loggedUser == null) {
    response.sendRedirect("login.jsp?redirect=Contact.jsp&error=" + java.net.URLEncoder.encode("Please sign in or register before sending a contact message.", "UTF-8"));
    return;
}

String nam = request.getParameter("nam");
String email = request.getParameter("email");
String number = request.getParameter("number");
String comment = request.getParameter("comment");

if (nam != null) nam = nam.trim().replaceAll("\\s+", " ");
if (!isValidFullName(nam)) {
    response.sendRedirect("Contact.jsp?error=" + java.net.URLEncoder.encode("Name can contain only alphabets and spaces.", "UTF-8"));
    return;
}

boolean success = false;
String errorMsg = "";

String cleanNam = sanitizeHtml(nam);
String cleanComm = sanitizeHtml(comment);

if (nam != null && email != null) {
    try {
        Connection con = getDbConnection();
        if(con != null) {
            PreparedStatement ps = con.prepareStatement("INSERT INTO contact(nam, email, number, comment) VALUES(?, ?, ?, ?)");
            ps.setString(1, cleanNam);
            ps.setString(2, email.trim().toLowerCase());
            ps.setString(3, number != null ? number.trim() : "");
            ps.setString(4, cleanComm);
            
            int count = ps.executeUpdate();
            if (count > 0) {
                success = true;
            }
            ps.close();
            con.close();
        } else {
            errorMsg = "Database connection failed.";
        }
    } catch (Exception e) {
        errorMsg = e.getMessage();
    }
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contact Message Status - Z Kitchen</title>
    <link rel="stylesheet" href="style.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
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
        <li class="nav-item"><a href="Contact.jsp" class="nav-link active">Contact</a></li>
        <li class="nav-item ms-lg-2"><a href="my_orders.jsp" class="nav-link fw-bold"><i class="fa-solid fa-clock-rotate-left me-1"></i> My Orders</a></li>
        <li class="nav-item ms-lg-2"><a href="profile.jsp" class="nav-link fw-bold"><i class="fa-solid fa-user me-1"></i> Profile</a></li>
      </ul>
    </div>
  </div>
</nav>
<!-- Navbar End -->

<section class="container py-5 text-center" style="margin-top: 100px; min-height:60vh;">
  <% if(success) { %>
    <div class="card p-5 border-0 shadow-sm mx-auto rounded-4" style="max-width: 600px; background:#ffffff;">
      <div class="mb-3">
        <i class="fa-solid fa-paper-plane text-success display-1"></i>
      </div>
      <h2 class="fw-bold text-success mb-2">Message Sent Successfully!</h2>
      <p class="text-muted fs-6 mb-4">Thank you <strong><%= nam %></strong>! We have received your inquiry and will get back to you shortly.</p>
      
      <div class="d-flex gap-2 justify-content-center">
        <a href="index.jsp" class="btn-primary-custom px-4 py-2">Back to Home &rarr;</a>
        <a href="Menu.jsp" class="btn btn-outline-secondary rounded-pill px-4 py-2">Explore Menu</a>
      </div>
    </div>
  <% } else { %>
    <div class="card p-5 border-0 shadow-sm mx-auto rounded-4" style="max-width: 600px; background:#ffffff;">
      <div class="mb-3">
        <i class="fa-solid fa-circle-xmark text-danger display-1"></i>
      </div>
      <h2 class="fw-bold text-danger mb-2">Submission Failed</h2>
      <p class="text-muted fs-6 mb-4"><%= errorMsg != null && !errorMsg.equals("") ? errorMsg : "Something went wrong while sending your message. Please try again." %></p>
      
      <a href="Contact.jsp" class="btn-primary-custom px-4 py-2">Try Again &rarr;</a>
    </div>
  <% } %>
</section>

<!-- Footer Start -->
<footer id="footer">
  <div class="footer-content">
    <div class="footer-logo"><img src="./images/z kitchen.jpeg" alt="Z Kitchen Logo"></div>
    <div class="footer-copyright">
      <span>Designed & Developed By <a href="#">Nai Adil / Anas Munshi</a> &copy; 2026 Z Kitchen</span>
    </div>
  </div>
</footer>
<!-- Footer End -->

</body>
</html>