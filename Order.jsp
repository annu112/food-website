<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*,java.sql.*" %>
<%@ include file="dbconnection.jsp" %>
<%!
    public static List<Map<String, Object>> parseCartJson(String jsonStr) {
        List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
        if (jsonStr == null || jsonStr.trim().isEmpty() || jsonStr.trim().equals("[]")) {
            return list;
        }
        try {
            java.util.regex.Pattern p = java.util.regex.Pattern.compile("\\{[^{}]*\\}");
            java.util.regex.Matcher m = p.matcher(jsonStr);
            while (m.find()) {
                String objStr = m.group();
                Map<String, Object> map = new HashMap<String, Object>();

                int id = 0;
                String name = "";
                double price = 0.0;
                String image = "pizza.png";
                String category = "Fast Food";
                int qty = 1;

                java.util.regex.Matcher mId = java.util.regex.Pattern.compile("\"id\"\\s*:\\s*(\\d+)").matcher(objStr);
                if (mId.find()) id = Integer.parseInt(mId.group(1));

                java.util.regex.Matcher mName = java.util.regex.Pattern.compile("\"name\"\\s*:\\s*\"([^\"]+)\"").matcher(objStr);
                if (mName.find()) name = mName.group(1);

                java.util.regex.Matcher mPrice = java.util.regex.Pattern.compile("\"price\"\\s*:\\s*([0-9.]+)").matcher(objStr);
                if (mPrice.find()) price = Double.parseDouble(mPrice.group(1));

                java.util.regex.Matcher mImg = java.util.regex.Pattern.compile("\"image\"\\s*:\\s*\"([^\"]+)\"").matcher(objStr);
                if (mImg.find()) image = mImg.group(1);

                java.util.regex.Matcher mCat = java.util.regex.Pattern.compile("\"category\"\\s*:\\s*\"([^\"]+)\"").matcher(objStr);
                if (mCat.find()) category = mCat.group(1);

                java.util.regex.Matcher mQty = java.util.regex.Pattern.compile("\"qty\"\\s*:\\s*(\\d+)").matcher(objStr);
                if (mQty.find()) qty = Integer.parseInt(mQty.group(1));

                if (!name.isEmpty() && price > 0) {
                    map.put("id", id);
                    map.put("name", name);
                    map.put("price", price);
                    map.put("image", image);
                    map.put("category", category);
                    map.put("qty", qty);
                    list.add(map);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
%>
<%
  Map<String, Object> loggedUser = (Map<String, Object>) session.getAttribute("loggedUser");
  boolean isLoggedIn = (loggedUser != null);
  String sessionName = isLoggedIn && session.getAttribute("userName") != null ? session.getAttribute("userName").toString() : "";
  String sessionEmail = isLoggedIn && session.getAttribute("userEmail") != null ? session.getAttribute("userEmail").toString() : "";
  String sessionPhone = isLoggedIn && session.getAttribute("userPhone") != null ? session.getAttribute("userPhone").toString() : "";
  String sessionCartJson = (String) session.getAttribute("cart_json");
  if(sessionCartJson == null || sessionCartJson.trim().isEmpty()) {
      sessionCartJson = "[]";
  }

  List<Map<String, Object>> cartItemList = parseCartJson(sessionCartJson);
  int itemsSubtotal = 0;
  for(Map<String, Object> item : cartItemList) {
      double price = Double.parseDouble(item.get("price").toString());
      int qty = Integer.parseInt(item.get("qty").toString());
      itemsSubtotal += (int)(price * qty);
  }
  int deliveryFee = cartItemList.size() > 0 ? 40 : 0;
  int discount = 0;
  int grandTotal = itemsSubtotal + deliveryFee - discount;

  StringBuilder summaryNmBuilder = new StringBuilder();
  for(int i=0; i<cartItemList.size(); i++) {
      Map<String, Object> item = cartItemList.get(i);
      if(i > 0) summaryNmBuilder.append(", ");
      summaryNmBuilder.append(item.get("name")).append(" (x").append(item.get("qty")).append(")");
  }
  String summaryNmStr = summaryNmBuilder.toString();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout & Order - Z Kitchen</title>

    <script>
      try {
        window.serverCartJson = JSON.parse('<%= sessionCartJson.replace("'", "\\'").replace("\n", "").replace("\r", "") %>');
      } catch(e) {
        window.serverCartJson = [];
      }
    </script>
    
    <!-- STYLE CSS LINK -->
    <link rel="stylesheet" href="style.css">
    <!-- BOOTSTRAP CDN LINK -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FONT AWESOME CDN -->
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
        <li class="nav-item ms-lg-2">
          <a href="Order.jsp" class="nav-link active position-relative me-2" title="View Cart">
            <i class="fa-solid fa-cart-shopping fs-5"></i>
            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger cart-count-badge" style="display:<%= cartItemList.size() > 0 ? "inline-block" : "none" %>;"><%= cartItemList.size() %></span>
          </a>
        </li>
        <% if(isLoggedIn) { %>
        <li class="nav-item ms-lg-2"><a href="my_orders.jsp" class="nav-link fw-bold"><i class="fa-solid fa-clock-rotate-left me-1"></i> My Orders</a></li>
        <li class="nav-item ms-lg-2"><a href="profile.jsp" class="nav-link fw-bold"><i class="fa-solid fa-user me-1"></i> <%= sessionName %></a></li>
        <li class="nav-item ms-lg-2"><a href="logout.jsp" class="btn btn-sm btn-outline-danger rounded-pill px-3 py-1 fw-bold">Logout</a></li>
        <% } else { %>
        <li class="nav-item ms-lg-2"><a href="login.jsp?redirect=Order.jsp" class="nav-link">Login</a></li>
        <li class="nav-item ms-lg-2"><a href="register.jsp?redirect=Order.jsp" class="nav-link">Register</a></li>
        <% } %>
      </ul>
    </div>
  </div>
</nav>
<!-- Navbar End -->

<!-- Order Form Section Start -->
<section class="container py-5" style="margin-top: 80px;">
  <div class="text-center mb-5">
    <span class="text-danger fw-bold text-uppercase tracking-wider">CHECKOUT</span>
    <h1 class="fw-bold mt-1 display-5">Complete Your Food Order</h1>
  </div>

  <div class="row justify-content-center">
    <div class="col-lg-9 col-xl-8">

      <% if(!isLoggedIn) { %>
      <!-- AUTHENTICATION REQUIRED PROMPT BANNER -->
      <div class="alert alert-warning border-warning p-4 rounded-4 shadow-sm mb-4 d-flex align-items-center justify-content-between flex-wrap gap-3">
        <div>
          <h5 class="fw-bold text-dark mb-1"><i class="fa-solid fa-lock text-warning me-2"></i> Sign In Required To Place Order</h5>
          <p class="small text-muted mb-0">Please sign in to your existing account or register a new account to confirm your order.</p>
        </div>
        <div class="d-flex gap-2">
          <a href="login.jsp?redirect=Order.jsp" class="btn btn-outline-dark rounded-pill px-4 fw-bold">Sign In</a>
          <a href="register.jsp?redirect=Order.jsp" class="btn btn-danger rounded-pill px-4 fw-bold shadow">Register Now &rarr;</a>
        </div>
      </div>
      <% } %>

      <!-- Empty Cart Notice (hidden by default, shown ONLY if cart is zero items) -->
      <div id="emptyCartNotice" class="card p-5 text-center rounded-4 shadow-sm bg-white border mb-4" style="display:none;">
        <i class="fa-solid fa-cart-shopping display-1 text-muted mb-3"></i>
        <h3 class="fw-bold">Your Cart is Empty!</h3>
        <p class="text-muted">Explore our delicious menu and add items to your cart.</p>
        <div>
          <a href="Menu.jsp" class="btn btn-danger rounded-pill px-4 py-2.5 fw-bold shadow mt-2">Browse Menu <i class="fa-solid fa-utensils ms-2"></i></a>
        </div>
      </div>

      <!-- Main Checkout Form Card (visible by default) -->
      <div id="multiItemOrderForm" class="order-card p-4 p-md-5 rounded-4 shadow-sm bg-white border" style="display:block;">
        
        <form method="post" action="ordprocess.jsp" id="checkoutForm" onsubmit="return handleOrderSubmit(event)">
          <!-- Hidden inputs with server-calculated initial values -->
          <input type="hidden" name="nm" id="formHiddenNm" value="<%= summaryNmStr %>">
          <input type="hidden" name="rs" id="formHiddenRs" value="<%= grandTotal %>">
          <input type="hidden" name="cart_json" id="formHiddenCartJson" value="<%= sessionCartJson %>">
          <input type="hidden" name="latitude" id="latInput">
          <input type="hidden" name="longitude" id="lngInput">
          <input type="hidden" name="comm" id="fullAddressHidden">

          <!-- ================================================== -->
          <!-- 1. TOP — ORDER DETAILS -->
          <!-- ================================================== -->
          <div class="checkout-step-section mb-5">
            <div class="d-flex align-items-center justify-content-between pb-3 border-bottom mb-4">
              <h4 class="fw-bold text-dark mb-0"><i class="fa-solid fa-receipt text-danger me-2"></i> Order Details</h4>
              <a href="Menu.jsp" class="btn btn-sm btn-outline-danger rounded-pill fw-bold px-3">
                <i class="fa-solid fa-plus me-1"></i> Add More Items
              </a>
            </div>

            <!-- Dynamic Cart Items Container (Pre-rendered by Server JSP & updated by JS) -->
            <div id="checkoutOrderDetailsContainer">
              <% if(cartItemList.size() > 0) { %>
                <div class="table-responsive rounded-3 border mb-3">
                    <table class="table align-middle mb-0">
                        <thead class="table-light">
                            <tr class="small text-uppercase text-secondary">
                                <th>Item Details</th>
                                <th class="text-center">Qty</th>
                                <th class="text-end">Price</th>
                                <th class="text-end">Subtotal</th>
                                <th class="text-center">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% 
                           for(int i = 0; i < cartItemList.size(); i++) { 
                               Map<String, Object> item = cartItemList.get(i);
                               int pId = Integer.parseInt(item.get("id").toString());
                               String pName = item.get("name").toString();
                               double pPrice = Double.parseDouble(item.get("price").toString());
                               String pImg = item.get("image").toString();
                               int pQty = Integer.parseInt(item.get("qty").toString());
                               int lineTotal = (int)(pPrice * pQty);
                        %>
                            <tr>
                                <td>
                                    <div class="d-flex align-items-center gap-3">
                                        <img src="./images/<%= pImg %>" alt="<%= pName %>" style="width:48px; height:48px; object-fit:contain;" class="rounded-2 border p-1 bg-white" onerror="this.src='./images/pizza.png'">
                                        <div>
                                            <h6 class="mb-0 fw-bold text-dark fs-6"><%= pName %></h6>
                                            <small class="text-muted">Item ID: #<%= pId %> | &#8377;<%= (int)pPrice %> each</small>
                                        </div>
                                    </div>
                                </td>
                                <td class="text-center">
                                    <div class="qty-counter d-inline-flex align-items-center border rounded-pill bg-white px-2 py-1">
                                        <button type="button" class="btn btn-sm p-0 me-2 text-danger border-0 fw-bold" onclick="updateCartQty(<%= i %>, -1)" style="width:24px; height:24px; line-height:1;">-</button>
                                        <span class="fw-bold px-2 text-dark fs-6"><%= pQty %></span>
                                        <button type="button" class="btn btn-sm p-0 ms-2 text-success border-0 fw-bold" onclick="updateCartQty(<%= i %>, 1)" style="width:24px; height:24px; line-height:1;">+</button>
                                    </div>
                                </td>
                                <td class="text-end fw-semibold text-secondary">&#8377;<%= (int)pPrice %></td>
                                <td class="text-end fw-bold text-danger fs-6">&#8377;<%= lineTotal %></td>
                                <td class="text-center">
                                    <button type="button" class="btn btn-sm btn-outline-danger border-0 rounded-circle" onclick="removeCartItem(<%= i %>)" title="Remove item">
                                        <i class="fa-solid fa-trash-can"></i>
                                    </button>
                                </td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>

                <div class="p-3 bg-light rounded-3 border">
                    <div class="d-flex justify-content-between mb-1">
                        <span class="text-muted">Items Subtotal (<%= cartItemList.size() %> dish<%= cartItemList.size() > 1 ? "es" : "" %>)</span>
                        <span class="fw-semibold text-dark">&#8377;<%= itemsSubtotal %></span>
                    </div>
                    <div class="d-flex justify-content-between mb-1">
                        <span class="text-muted">Standard Delivery Charge</span>
                        <span class="fw-semibold text-dark">&#8377;<%= deliveryFee %></span>
                    </div>
                    <div class="d-flex justify-content-between mb-1">
                        <span class="text-muted">Discount</span>
                        <span class="fw-semibold text-success">&#8377;<%= discount %></span>
                    </div>
                    <hr class="my-2">
                    <div class="d-flex justify-content-between align-items-center">
                        <span class="fw-bold text-dark fs-6">Cart Total</span>
                        <span class="fw-bold fs-5 text-danger">&#8377;<%= grandTotal %></span>
                    </div>
                </div>
              <% } else { %>
                <script>
                  (function() {
                    try {
                      const keys = ["zk_cart", "z_kitchen_cart", "cart", "cart_items", "food_cart", "user_cart"];
                      let cart = [];
                      for (let k of keys) {
                        let s = localStorage.getItem(k) || sessionStorage.getItem(k);
                        if (s && s !== "[]" && s !== "null") {
                          let p = JSON.parse(s);
                          if (Array.isArray(p) && p.length > 0) { cart = p; break; }
                        }
                      }
                      if (cart.length > 0) {
                        let subtotal = 0;
                        let summaryNmList = [];
                        let html = '<div class="table-responsive rounded-3 border mb-3"><table class="table align-middle mb-0"><thead class="table-light"><tr class="small text-uppercase text-secondary"><th>Item Details</th><th class="text-center">Qty</th><th class="text-end">Price</th><th class="text-end">Subtotal</th><th class="text-center">Action</th></tr></thead><tbody>';
                        cart.forEach((item, index) => {
                          let price = parseFloat(item.price) || 0;
                          let qty = parseInt(item.qty) || 1;
                          let lineTotal = price * qty;
                          subtotal += lineTotal;
                          summaryNmList.push(item.name + " (x" + qty + ")");
                          html += '<tr><td><div class="d-flex align-items-center gap-3"><img src="./images/' + (item.image || 'pizza.png') + '" style="width:48px;height:48px;object-fit:contain;" class="rounded-2 border p-1 bg-white" onerror="this.src=\'./images/pizza.png\'"><div><h6 class="mb-0 fw-bold text-dark fs-6">' + item.name + '</h6><small class="text-muted">Item ID: #' + (item.id || (index+1)) + ' | &#8377;' + price + ' each</small></div></div></td><td class="text-center"><div class="qty-counter d-inline-flex align-items-center border rounded-pill bg-white px-2 py-1"><button type="button" class="btn btn-sm p-0 me-2 text-danger border-0 fw-bold" onclick="updateCartQty(' + index + ', -1)">-</button><span class="fw-bold px-2 text-dark fs-6">' + qty + '</span><button type="button" class="btn btn-sm p-0 ms-2 text-success border-0 fw-bold" onclick="updateCartQty(' + index + ', 1)">+</button></div></td><td class="text-end fw-semibold text-secondary">&#8377;' + price + '</td><td class="text-end fw-bold text-danger fs-6">&#8377;' + lineTotal + '</td><td class="text-center"><button type="button" class="btn btn-sm btn-outline-danger border-0 rounded-circle" onclick="removeCartItem(' + index + ')"><i class="fa-solid fa-trash-can"></i></button></td></tr>';
                        });
                        let deliveryFee = subtotal > 0 ? 40 : 0;
                        let grandTotal = subtotal + deliveryFee;
                        html += '</tbody></table></div><div class="p-3 bg-light rounded-3 border"><div class="d-flex justify-content-between mb-1"><span class="text-muted">Items Subtotal (' + cart.length + ' dish' + (cart.length > 1 ? 'es' : '') + ')</span><span class="fw-semibold text-dark">&#8377;' + subtotal + '</span></div><div class="d-flex justify-content-between mb-1"><span class="text-muted">Standard Delivery Charge</span><span class="fw-semibold text-dark">&#8377;' + deliveryFee + '</span></div><hr class="my-2"><div class="d-flex justify-content-between align-items-center"><span class="fw-bold text-dark fs-6">Cart Total</span><span class="fw-bold fs-5 text-danger">&#8377;' + grandTotal + '</span></div></div>';
                        document.write(html);
                        
                        setTimeout(function() {
                          const sit = document.getElementById("summaryItemsTotal");
                          const sdf = document.getElementById("summaryDeliveryFee");
                          const sgt = document.getElementById("summaryGrandTotal");
                          const hnm = document.getElementById("formHiddenNm");
                          const hrs = document.getElementById("formHiddenRs");
                          const hcj = document.getElementById("formHiddenCartJson");
                          if(sit) sit.textContent = '₹' + subtotal;
                          if(sdf) sdf.textContent = '₹' + deliveryFee;
                          if(sgt) sgt.textContent = '₹' + grandTotal;
                          if(hnm) hnm.value = summaryNmList.join(", ");
                          if(hrs) hrs.value = grandTotal.toString();
                          if(hcj) hcj.value = JSON.stringify(cart);
                        }, 10);
                      } else {
                        document.write('<div class="card p-4 text-center rounded-4 shadow-sm bg-white border mb-3"><i class="fa-solid fa-cart-shopping display-3 text-muted mb-2"></i><h4 class="fw-bold text-dark mb-1">Your Shopping Cart is Empty</h4><p class="text-muted small mb-3">Add some delicious dishes from our menu to place your food order.</p><div><a href="Menu.jsp" class="btn btn-danger rounded-pill px-4 py-2 fw-bold shadow-sm"><i class="fa-solid fa-utensils me-2"></i> Browse Menu & Add Food</a></div></div>');
                      }
                    } catch(e) {}
                  })();
                </script>
              <% } %>
            </div>
          </div>


          <!-- ================================================== -->
          <!-- 2. DELIVERY LOCATION DETAILS -->
          <!-- ================================================== -->
          <div class="checkout-step-section mb-5 pt-4 border-top">
            <div class="d-flex align-items-center justify-content-between pb-3 border-bottom mb-4">
              <h4 class="fw-bold text-dark mb-0"><i class="fa-solid fa-truck-fast text-danger me-2"></i> Delivery Location Details</h4>
              <button type="button" id="useCurrentLocationBtn" class="btn btn-outline-danger btn-sm rounded-pill fw-bold px-3 py-1.5">
                <i class="fa-solid fa-location-crosshairs me-1"></i> Use Current Location
              </button>
            </div>

            <div class="row g-3">
              <div class="col-md-6">
                <label class="form-label fw-semibold text-dark">Full Name (Alphabets Only) *</label>
                <input type="text" name="cname" id="cnameInput" class="form-control form-control-lg fs-6" value="<%= sessionName %>" placeholder="e.g. Rahul Patel" required oninput="validateOrderName(this)">
                <small class="text-danger fw-semibold" id="cnameError" style="display:none;">Name can contain only alphabets and spaces.</small>
              </div>
              
              <div class="col-md-6">
                <label class="form-label fw-semibold text-dark">Email Address *</label>
                <input type="email" name="email" id="emailInput" class="form-control form-control-lg fs-6" value="<%= sessionEmail %>" placeholder="name@example.com" required>
              </div>

              <div class="col-md-12">
                <label class="form-label fw-semibold text-dark">Mobile Number *</label>
                <input type="tel" name="monumber" id="phoneInput" class="form-control form-control-lg fs-6" value="<%= sessionPhone %>" placeholder="10-digit mobile number" required pattern="[0-9]{10}">
              </div>

              <div class="col-md-6">
                <label class="form-label fw-semibold text-dark">House / Flat / Building No. *</label>
                <input type="text" name="house_building" id="houseBuildingInput" class="form-control form-control-lg fs-6" placeholder="Flat No. 302, Royal Residency" required oninput="updateFullAddressString()">
              </div>

              <div class="col-md-6">
                <label class="form-label fw-semibold text-dark">Street / Area / Landmark *</label>
                <input type="text" name="street_area" id="streetAreaInput" class="form-control form-control-lg fs-6" placeholder="MG Road, Near Bus Stand" required oninput="updateFullAddressString()">
              </div>

              <div class="col-md-4">
                <label class="form-label fw-semibold text-dark">City *</label>
                <input type="text" name="city" id="cityInput" class="form-control form-control-lg fs-6" placeholder="Junagadh" required oninput="updateFullAddressString()">
              </div>

              <div class="col-md-4">
                <label class="form-label fw-semibold text-dark">State *</label>
                <input type="text" name="state" id="stateInput" class="form-control form-control-lg fs-6" placeholder="Gujarat" required oninput="updateFullAddressString()">
              </div>

              <div class="col-md-4">
                <label class="form-label fw-semibold text-dark">Postal / PIN Code *</label>
                <input type="text" name="pincode" id="pincodeInput" class="form-control form-control-lg fs-6" placeholder="362001" required pattern="[0-9]{6}" oninput="updateFullAddressString()">
              </div>
            </div>
          </div>


          <!-- ================================================== -->
          <!-- 3. PAYMENT METHOD — COD ONLY AS REQUESTED -->
          <!-- ================================================== -->
          <div class="checkout-step-section mb-5 pt-4 border-top">
            <h4 class="fw-bold text-dark mb-4"><i class="fa-solid fa-wallet text-danger me-2"></i> Select Payment Method</h4>
            
            <div class="d-flex flex-column flex-sm-row gap-3">
              <!-- CASH ON DELIVERY (COD) -->
              <div class="flex-fill p-3.5 rounded-4 payment-option-card border-2 cursor-pointer position-relative" id="cardPayCod" style="border: 2px solid #16a34a; background: #f0fdf4; transition: all 0.25s ease;">
                <div class="form-check m-0">
                  <input class="form-check-input" type="radio" name="payment_method" id="payCod" value="Cash on Delivery" checked>
                  <label class="form-check-label fw-bold cursor-pointer ms-2 text-dark fs-6" for="payCod">
                    💵 Cash on Delivery (COD)
                  </label>
                  <div class="small text-secondary mt-1 ms-4">Pay cash when your food order is delivered to your doorstep.</div>
                  <span class="badge bg-success mt-2 ms-4 px-2 py-1" style="font-size:11px;">Pay at Doorstep</span>
                </div>
              </div>
            </div>
          </div>


          <!-- ================================================== -->
          <!-- 4. FINAL ORDER SUMMARY -->
          <!-- ================================================== -->
          <div class="checkout-step-section mb-4 pt-4 border-top">
            <h5 class="fw-bold text-dark mb-3"><i class="fa-solid fa-calculator text-danger me-2"></i> Final Order Summary</h5>
            <div class="p-4 rounded-4 shadow-sm" style="background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%); color: #ffffff;">
              <div class="d-flex justify-content-between mb-2 text-white-50">
                <span>Items Total</span>
                <span class="fw-semibold text-white" id="summaryItemsTotal">&#8377;<%= itemsSubtotal %></span>
              </div>
              <div class="d-flex justify-content-between mb-2 text-white-50">
                <span>Delivery Charge</span>
                <span class="fw-semibold text-white" id="summaryDeliveryFee">&#8377;<%= deliveryFee %></span>
              </div>
              <div class="d-flex justify-content-between mb-2 text-white-50">
                <span>Discount</span>
                <span class="fw-semibold text-success" id="summaryDiscount">&#8377;<%= discount %></span>
              </div>
              <div class="d-flex justify-content-between mb-3 text-white-50">
                <span>Payment Method</span>
                <span class="fw-semibold text-warning" id="summaryPaymentMethod">Cash on Delivery (COD)</span>
              </div>
              <div class="d-flex justify-content-between pt-3 border-top border-secondary align-items-center">
                <span class="fs-5 fw-bold text-white">Grand Total</span>
                <span class="fs-3 fw-extrabold text-warning" id="summaryGrandTotal">&#8377;<%= grandTotal %></span>
              </div>
            </div>
            <script>
              (function() {
                try {
                  const keys = ["zk_cart", "z_kitchen_cart", "cart", "cart_items", "food_cart", "user_cart"];
                  let cart = [];
                  for (let k of keys) {
                    let s = localStorage.getItem(k) || sessionStorage.getItem(k);
                    if (s && s !== "[]" && s !== "null") {
                      let p = JSON.parse(s);
                      if (Array.isArray(p) && p.length > 0) { cart = p; break; }
                    }
                  }
                  if (cart.length > 0) {
                    let subtotal = 0;
                    let summaryNmList = [];
                    cart.forEach(item => {
                      let price = parseFloat(item.price) || 0;
                      let qty = parseInt(item.qty) || 1;
                      subtotal += (price * qty);
                      summaryNmList.push(item.name + " (x" + qty + ")");
                    });
                    let deliveryFee = subtotal > 0 ? 40 : 0;
                    let discount = 0;
                    let grandTotal = subtotal + deliveryFee - discount;

                    const sit = document.getElementById("summaryItemsTotal");
                    const sdf = document.getElementById("summaryDeliveryFee");
                    const sdc = document.getElementById("summaryDiscount");
                    const sgt = document.getElementById("summaryGrandTotal");
                    const hnm = document.getElementById("formHiddenNm");
                    const hrs = document.getElementById("formHiddenRs");
                    const hcj = document.getElementById("formHiddenCartJson");

                    if (sit) sit.textContent = '₹' + subtotal;
                    if (sdf) sdf.textContent = '₹' + deliveryFee;
                    if (sdc) sdc.textContent = '₹' + discount;
                    if (sgt) sgt.textContent = '₹' + grandTotal;

                    if (hnm) hnm.value = summaryNmList.join(", ");
                    if (hrs) hrs.value = grandTotal.toString();
                    if (hcj) hcj.value = JSON.stringify(cart);
                  }
                } catch(e) {}
              })();
            </script>
          </div>


          <!-- ================================================== -->
          <!-- 5. FINAL SUBMIT BUTTON -->
          <!-- ================================================== -->
          <div class="col-12 mt-4">
            <button type="submit" id="confirmOrderBtn" class="btn-primary-custom w-100 py-3.5 fs-5 fw-bold shadow rounded-3">
              <span id="confirmBtnText">PLACE ORDER</span> <i class="fa-solid fa-arrow-right ms-2" id="confirmBtnIcon"></i>
            </button>
          </div>

        </form>
      </div>

    </div>
  </div>
</section>
<!-- Order Form Section End -->

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
  const userIsLoggedIn = <%= isLoggedIn %>;

  function validateOrderName(input) {
    const err = document.getElementById("cnameError");
    const regex = /^[A-Za-z]+(?: [A-Za-z]+)*$/;
    if(!regex.test(input.value.trim())) {
      err.style.display = "block";
      return false;
    } else {
      err.style.display = "none";
      return true;
    }
  }

  function updateFullAddressString() {
    const hb = document.getElementById("houseBuildingInput").value.trim();
    const st = document.getElementById("streetAreaInput").value.trim();
    const ci = document.getElementById("cityInput").value.trim();
    const sa = document.getElementById("stateInput").value.trim();
    const pin = document.getElementById("pincodeInput").value.trim();
    document.getElementById("fullAddressHidden").value = hb + ", " + st + ", " + ci + ", " + sa + " - " + pin;
  }

  function handleOrderSubmit(e) {
    if(!userIsLoggedIn) {
      alert("Authentication required! Please Sign In or Register to place your food order.");
      window.location = "login.jsp?redirect=Order.jsp";
      if(e && e.preventDefault) e.preventDefault();
      return false;
    }

    try {
      const keys = ["zk_cart", "z_kitchen_cart", "cart", "cart_items", "food_cart", "user_cart"];
      let cart = [];
      for (let k of keys) {
        let s = localStorage.getItem(k) || sessionStorage.getItem(k);
        if (s && s !== "[]" && s !== "null") {
          let p = JSON.parse(s);
          if (Array.isArray(p) && p.length > 0) { cart = p; break; }
        }
      }
      if (cart.length > 0) {
        let subtotal = 0;
        let summaryNmList = [];
        cart.forEach(item => {
          let price = parseFloat(item.price) || 0;
          let qty = parseInt(item.qty) || 1;
          subtotal += (price * qty);
          summaryNmList.push(item.name + " (x" + qty + ")");
        });
        let deliveryFee = subtotal > 0 ? 40 : 0;
        let grandTotal = subtotal + deliveryFee;

        const hnm = document.getElementById("formHiddenNm");
        const hrs = document.getElementById("formHiddenRs");
        const hcj = document.getElementById("formHiddenCartJson");

        if (hnm) hnm.value = summaryNmList.join(", ");
        if (hrs) hrs.value = grandTotal.toString();
        if (hcj) hcj.value = JSON.stringify(cart);
      }
    } catch(err) {}

    const totalAmountStr = document.getElementById("formHiddenRs") ? document.getElementById("formHiddenRs").value : "0";
    if (!totalAmountStr || parseFloat(totalAmountStr) <= 0) {
      alert("Your cart is currently empty! Please add food items from the menu before placing an order.");
      window.location = "Menu.jsp";
      if(e && e.preventDefault) e.preventDefault();
      return false;
    }

    const cnameInput = document.getElementById("cnameInput");
    if(!validateOrderName(cnameInput)) {
      alert("Name can contain only alphabets and spaces.");
      cnameInput.focus();
      if(e && e.preventDefault) e.preventDefault();
      return false;
    }

    updateFullAddressString();

    const btn = document.getElementById("confirmOrderBtn");
    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin me-2"></i> Placing Food Order...';
    return true;
  }

  // GEOLOCATION API HANDLER
  document.getElementById("useCurrentLocationBtn").addEventListener("click", function() {
    const btn = this;
    if (!navigator.geolocation) {
      alert("Geolocation is not supported by your browser.");
      return;
    }

    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin me-1"></i> Locating...';

    navigator.geolocation.getCurrentPosition(
      function(position) {
        const lat = position.coords.latitude;
        const lng = position.coords.longitude;
        document.getElementById("latInput").value = lat;
        document.getElementById("lngInput").value = lng;

        fetch("https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=" + lat + "&lon=" + lng)
          .then(response => response.json())
          .then(data => {
            btn.disabled = false;
            btn.innerHTML = '<i class="fa-solid fa-circle-check text-success me-1"></i> Location Captured!';
            if (data && data.address) {
              const addr = data.address;
              if(addr.house_number || addr.building) document.getElementById("houseBuildingInput").value = (addr.house_number || "") + " " + (addr.building || "");
              if(addr.road || addr.suburb || addr.neighbourhood) document.getElementById("streetAreaInput").value = addr.road || addr.suburb || addr.neighbourhood || "";
              if(addr.city || addr.town || addr.village) document.getElementById("cityInput").value = addr.city || addr.town || addr.village || "";
              if(addr.state) document.getElementById("stateInput").value = addr.state;
              if(addr.postcode) document.getElementById("pincodeInput").value = addr.postcode;

              updateFullAddressString();
            }
          })
          .catch(err => {
            btn.disabled = false;
            btn.innerHTML = '<i class="fa-solid fa-location-crosshairs me-1"></i> Use Current Location';
            alert("Coordinates captured: Latitude " + lat.toFixed(4) + ", Longitude " + lng.toFixed(4) + ".");
          });
      },
      function(error) {
        btn.disabled = false;
        btn.innerHTML = '<i class="fa-solid fa-location-crosshairs me-1"></i> Use Current Location';
        alert("Location access denied or unavailable: " + error.message);
      },
      { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 }
    );
  });

  if (typeof window.renderOrderPageCart === "function") {
    window.renderOrderPageCart();
  }
  window.addEventListener("load", function() {
    if (typeof window.renderOrderPageCart === "function") {
      window.renderOrderPageCart();
    }
  });
</script>
</body>
</html>