<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="dbconnection.jsp" %>

<%
request.setCharacterEncoding("UTF-8");

Map<String, Object> loggedUser = (Map<String, Object>) session.getAttribute("loggedUser");
if (loggedUser == null) {
    response.sendRedirect("login.jsp?redirect=Order.jsp&error=" + java.net.URLEncoder.encode("Please sign in or register before placing your order.", "UTF-8"));
    return;
}

int userId = Integer.parseInt(loggedUser.get("user_id").toString());
String nm = request.getParameter("nm");
String rs = request.getParameter("rs");
String cname = request.getParameter("cname");
String email = request.getParameter("email");
String monumber = request.getParameter("monumber");
String comm = request.getParameter("comm");

String latitude = request.getParameter("latitude");
String longitude = request.getParameter("longitude");
String houseBuilding = request.getParameter("house_building");
String streetArea = request.getParameter("street_area");
String city = request.getParameter("city");
String state = request.getParameter("state");
String pincode = request.getParameter("pincode");

if(cname != null) cname = cname.trim().replaceAll("\\s+", " ");

/* 1. INPUT SANITIZATION & XSS PREVENTION */
String cleanName = sanitizeHtml(cname);
String cleanItems = sanitizeHtml(nm);
String cleanComm = sanitizeHtml(comm);
String cleanHouse = sanitizeHtml(houseBuilding);
String cleanStreet = sanitizeHtml(streetArea);
String cleanCity = sanitizeHtml(city);
String cleanState = sanitizeHtml(state);
String cleanPincode = sanitizeHtml(pincode);

/* 2. LATITUDE / LONGITUDE COORDINATE VALIDATION */
if (latitude != null && !latitude.trim().isEmpty()) {
    try {
        double latVal = Double.parseDouble(latitude.trim());
        double lngVal = Double.parseDouble(longitude.trim());
        if (latVal < -90 || latVal > 90 || lngVal < -180 || lngVal > 180) {
            latitude = "";
            longitude = "";
        }
    } catch(Exception e) {
        latitude = "";
        longitude = "";
    }
}

boolean success = false;
int generatedOrderId = 0;
String errorMsg = "";

/* 3. DOUBLE SUBMISSION / IDEMPOTENCY CHECK */
String orderHash = userId + "_" + cleanItems + "_" + (rs != null ? rs : "0");
Long lastOrderTime = (Long) session.getAttribute("last_order_timestamp");
String lastHash = (String) session.getAttribute("last_order_hash");
long now = System.currentTimeMillis();

if (lastHash != null && lastHash.equals(orderHash) && lastOrderTime != null && (now - lastOrderTime) < 5000) {
    // Duplicate submission within 5 seconds detected
    response.sendRedirect("my_orders.jsp");
    return;
}

String paymentMethod = "Cash on Delivery";
String paymentStatus = "PENDING";
String razorpayOrderId = "";
String razorpayPaymentId = "";
String razorpaySignature = "";

/* 4. STRICT BACKEND FULL NAME VALIDATION */
if (!isValidFullName(cname)) {
    errorMsg = "Full Name can contain only alphabets and spaces.";
} else if (errorMsg.isEmpty() && nm != null && cname != null && email != null) {
    try {
        Connection con = getDbConnection();
        if(con != null) {
            /* 5. BACKEND PRICE VERIFICATION AGAINST DATABASE PRODUCTS TABLE */
            int verifiedTotal = 0;
            try {
                Map<String, Integer> productPrices = new HashMap<String, Integer>();
                Statement stProd = con.createStatement();
                ResultSet rsProd = stProd.executeQuery("SELECT name, price FROM products");
                while(rsProd.next()) {
                    productPrices.put(rsProd.getString("name").toLowerCase().trim(), rsProd.getInt("price"));
                }
                rsProd.close();
                stProd.close();

                if(cleanItems != null) {
                    String[] itemLines = cleanItems.split("\n|,");
                    for(String line : itemLines) {
                        line = line.trim();
                        if(line.isEmpty()) continue;
                        for(Map.Entry<String, Integer> entry : productPrices.entrySet()) {
                            if(line.toLowerCase().contains(entry.getKey())) {
                                int qty = 1;
                                java.util.regex.Matcher m = java.util.regex.Pattern.compile("x\\s*(\\d+)|\\(\\s*x?\\s*(\\d+)\\s*\\)").matcher(line.toLowerCase());
                                if(m.find()) {
                                    String qStr = m.group(1) != null ? m.group(1) : m.group(2);
                                    if(qStr != null) qty = Integer.parseInt(qStr);
                                }
                                verifiedTotal += entry.getValue() * qty;
                                break;
                            }
                        }
                    }
                }
            } catch(Exception ignore) {}

            int parsedRs = 0;
            if (rs != null) {
                try { parsedRs = Integer.parseInt(rs.replaceAll("[^0-9]", "")); } catch(Exception e){}
            }

            int computedTotal = 0;
            if (verifiedTotal > 0) {
                computedTotal = verifiedTotal + 40;
            } else if (parsedRs > 0) {
                computedTotal = parsedRs;
            }

            if (computedTotal <= 0) {
                String cartJsonParam = request.getParameter("cart_json");
                if (cartJsonParam == null || cartJsonParam.trim().isEmpty()) {
                    cartJsonParam = (String) session.getAttribute("cart_json");
                }
                if (cartJsonParam != null && !cartJsonParam.trim().isEmpty()) {
                    try {
                        java.util.regex.Pattern p = java.util.regex.Pattern.compile("\\{[^{}]*\\}");
                        java.util.regex.Matcher m = p.matcher(cartJsonParam);
                        int sum = 0;
                        while (m.find()) {
                            String objStr = m.group();
                            double pVal = 0.0;
                            int qVal = 1;
                            java.util.regex.Matcher mPrice = java.util.regex.Pattern.compile("\"price\"\\s*:\\s*([0-9.]+)").matcher(objStr);
                            if (mPrice.find()) pVal = Double.parseDouble(mPrice.group(1));
                            java.util.regex.Matcher mQty = java.util.regex.Pattern.compile("\"qty\"\\s*:\\s*(\\d+)").matcher(objStr);
                            if (mQty.find()) qVal = Integer.parseInt(mQty.group(1));
                            sum += (int)(pVal * qVal);
                        }
                        if (sum > 0) computedTotal = sum + 40;
                    } catch(Exception e) {}
                }
            }

            String finalPrice = String.valueOf(computedTotal);

            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO orfood(user_id, nm, rs, cname, email, monumber, comm, order_status, subtotal, delivery_charge, latitude, longitude, house_building, street_area, city, state, pincode, payment_method, payment_status, razorpay_order_id, razorpay_payment_id, payment_verified_at) VALUES(?, ?, ?, ?, ?, ?, ?, 'Confirmed', ?, '0', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                Statement.RETURN_GENERATED_KEYS
            );
            ps.setInt(1, userId);
            ps.setString(2, cleanItems);
            ps.setString(3, finalPrice);
            ps.setString(4, cleanName);
            ps.setString(5, email.trim().toLowerCase());
            ps.setString(6, monumber != null ? monumber.trim() : "");
            ps.setString(7, cleanComm);
            ps.setString(8, finalPrice);
            ps.setString(9, latitude != null ? latitude.trim() : "");
            ps.setString(10, longitude != null ? longitude.trim() : "");
            ps.setString(11, cleanHouse);
            ps.setString(12, cleanStreet);
            ps.setString(13, cleanCity);
            ps.setString(14, cleanState);
            ps.setString(15, cleanPincode);
            ps.setString(16, paymentMethod);
            ps.setString(17, paymentStatus);
            ps.setString(18, razorpayOrderId);
            ps.setString(19, razorpayPaymentId);
            ps.setTimestamp(20, "PAID".equalsIgnoreCase(paymentStatus) ? new Timestamp(System.currentTimeMillis()) : null);

            int count = ps.executeUpdate();
            if (count > 0) {
                success = true;
                ResultSet gKeys = ps.getGeneratedKeys();
                if(gKeys.next()) generatedOrderId = gKeys.getInt(1);
                gKeys.close();

                // Save idempotency session markers
                session.setAttribute("last_order_timestamp", now);
                session.setAttribute("last_order_hash", orderHash);

                // Log initial status in order_status_history
                if(generatedOrderId > 0) {
                    PreparedStatement histPs = con.prepareStatement("INSERT INTO order_status_history(order_id, old_status, new_status, changed_by) VALUES(?, 'NONE', 'Confirmed', ?)");
                    histPs.setInt(1, generatedOrderId);
                    histPs.setString(2, cleanName);
                    histPs.executeUpdate();
                    histPs.close();
                }
                // Clear server-side session cart
                session.setAttribute("cart_json", "[]");
            }
            ps.close();
            con.close();

            // SEND ORDER CONFIRMATION EMAIL WITH PAYMENT DETAILS IMMEDIATELY AFTER DB INSERTION
            if(success && generatedOrderId > 0 && email != null && !email.trim().isEmpty()) {
                try {
                    sendOrderConfirmationEmail(email.trim(), cleanName, generatedOrderId, cleanItems, finalPrice, cleanComm, paymentMethod, paymentStatus);
                } catch(Exception ignore) {}
            }

        } else {
            errorMsg = "Database connection failed. Please ensure MySQL service is started in XAMPP.";
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
    <title>Order Status - Z Kitchen</title>
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
        <li class="nav-item"><a href="Contact.jsp" class="nav-link">Contact</a></li>
        <li class="nav-item ms-lg-2"><a href="my_orders.jsp" class="nav-link fw-bold"><i class="fa-solid fa-clock-rotate-left me-1"></i> My Orders</a></li>
        <li class="nav-item ms-lg-2"><a href="profile.jsp" class="nav-link fw-bold"><i class="fa-solid fa-user me-1"></i> Profile</a></li>
      </ul>
    </div>
  </div>
</nav>
<!-- Navbar End -->

<section class="container py-5 text-center" style="margin-top: 100px; min-height: 60vh;">
  <% if (success) { %>
    <div class="card p-5 border-0 shadow-sm mx-auto rounded-4" style="max-width: 600px; background: #ffffff;">
      <div class="mb-3">
        <i class="fa-solid fa-circle-check text-success display-1"></i>
      </div>
      <h2 class="fw-bold text-success mb-2">Order Placed Successfully!</h2>
      <p class="text-muted fs-6 mb-4">Thank you <strong><%= cleanName %></strong>! Your order <strong>#ORD-<%= generatedOrderId %></strong> has been saved and confirmed.</p>
      
      <div class="p-3 bg-light rounded-3 text-start mb-4 border">
        <div class="row">
          <div class="col-6"><strong>Order ID:</strong> #ORD-<%= generatedOrderId %></div>
          <div class="col-6 text-end"><strong>Amount Paid:</strong> &#8377; <%= rs %></div>
          <div class="col-12 mt-2"><strong>Items:</strong> <%= cleanItems %></div>
          <div class="col-12 mt-2"><strong>Delivery Address:</strong> <%= cleanComm %></div>
          <% if(latitude != null && !latitude.isEmpty()) { %>
          <div class="col-12 mt-2 text-success small"><strong><i class="fa-solid fa-location-dot"></i> GPS Coordinates Captured:</strong> <%= latitude %>, <%= longitude %></div>
          <% } %>
        </div>
      </div>

      <div class="d-flex gap-2 justify-content-center">
        <a href="my_orders.jsp" class="btn-primary-custom px-4 py-2">Track Order History &rarr;</a>
        <a href="Menu.jsp" class="btn btn-outline-secondary rounded-pill px-4 py-2">Order More Food</a>
      </div>
    </div>
    
    <script>
      // Clear shopping cart on successful checkout
      if(window.cartManager && window.cartManager.clearCart) {
        window.cartManager.clearCart();
      } else {
        localStorage.removeItem("zk_cart");
        localStorage.removeItem("z_kitchen_cart");
      }
    </script>
  <% } else { %>
    <div class="card p-5 border-0 shadow-sm mx-auto rounded-4" style="max-width: 600px; background: #ffffff;">
      <div class="mb-3">
        <i class="fa-solid fa-circle-xmark text-danger display-1"></i>
      </div>
      <h2 class="fw-bold text-danger mb-2">Order Failed</h2>
      <p class="text-muted fs-6 mb-4"><%= errorMsg != null && !errorMsg.equals("") ? errorMsg : "Something went wrong while processing your order. Please try again." %></p>
      
      <a href="Order.jsp" class="btn-primary-custom px-4 py-2">Try Again &rarr;</a>
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