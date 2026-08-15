<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="../dbconnection.jsp" %>

<%
request.setCharacterEncoding("UTF-8");

// ROLE-BASED ADMIN AUTHORIZATION CHECK
Map<String, Object> adminLoggedUser = (Map<String, Object>) session.getAttribute("loggedUser");
String adminUserRole = session.getAttribute("userRole") != null ? session.getAttribute("userRole").toString() : "";
boolean isAdminSession = (session.getAttribute("adminUser") != null) || (adminLoggedUser != null && "ADMIN".equalsIgnoreCase(adminUserRole));

if(!isAdminSession) {
    response.sendRedirect("../index.jsp?error=" + java.net.URLEncoder.encode("Unauthorized access. Admin privileges required.", "UTF-8"));
    return;
}

Connection con = getDbConnection();

// Update Payment Status Handler (Admin Only)
String updatePaymentId = request.getParameter("updatePaymentId");
String newPaymentStatus = request.getParameter("newPaymentStatus");
if(updatePaymentId != null && newPaymentStatus != null && con != null) {
    try {
        int pOrderId = Integer.parseInt(updatePaymentId);
        String formattedPayStatus = newPaymentStatus.trim().toUpperCase();
        
        PreparedStatement upPayPs = con.prepareStatement("UPDATE orfood SET payment_status = ? WHERE id = ?");
        upPayPs.setString(1, formattedPayStatus);
        upPayPs.setInt(2, pOrderId);
        upPayPs.executeUpdate();
        upPayPs.close();
        
        con.close();
        response.sendRedirect("orders.jsp?paymentUpdated=true");
        return;
    } catch(Exception e) {
        out.println("Error updating payment status: " + e.getMessage());
    }
}

// Update Order Status Handler
String updateStatusId = request.getParameter("updateStatusId");
String newStatus = request.getParameter("newStatus");
if(updateStatusId != null && newStatus != null && con != null) {
    try {
        int orderId = Integer.parseInt(updateStatusId);
        String oldStatus = "Pending";
        String customerEmail = "";
        String customerName = "";
        String orderPrice = "0";
        String deliveryAddr = "";
        int deliveredSent = 0;

        PreparedStatement selPs = con.prepareStatement("SELECT * FROM orfood WHERE id = ?");
        selPs.setInt(1, orderId);
        ResultSet selRs = selPs.executeQuery();
        if(selRs.next()) {
            oldStatus = selRs.getString("order_status") != null ? selRs.getString("order_status") : "Pending";
            customerEmail = selRs.getString("email");
            customerName = selRs.getString("cname");
            orderPrice = selRs.getString("rs");
            deliveryAddr = selRs.getString("comm");
            deliveredSent = selRs.getInt("delivered_email_sent");
        }
        selRs.close();
        selPs.close();

        if(!newStatus.equalsIgnoreCase(oldStatus)) {
            // Update order_status in DB
            PreparedStatement upPs = con.prepareStatement("UPDATE orfood SET order_status = ? WHERE id = ?");
            upPs.setString(1, newStatus);
            upPs.setInt(2, orderId);
            upPs.executeUpdate();
            upPs.close();

            // Record status change in order_status_history
            PreparedStatement histPs = con.prepareStatement("INSERT INTO order_status_history(order_id, old_status, new_status, changed_by) VALUES(?, ?, ?, 'ADMIN')");
            histPs.setInt(1, orderId);
            histPs.setString(2, oldStatus);
            histPs.setString(3, newStatus);
            histPs.executeUpdate();
            histPs.close();

            // Send Order Delivered Email if status changed to 'Delivered' and email not already sent
            if("Delivered".equalsIgnoreCase(newStatus) && deliveredSent == 0) {
                if(customerEmail != null && !customerEmail.trim().isEmpty()) {
                    try {
                        sendOrderDeliveredEmail(customerEmail.trim(), customerName, orderId, orderPrice, deliveryAddr);
                    } catch(Exception ignore) {}
                }
                PreparedStatement flagPs = con.prepareStatement("UPDATE orfood SET delivered_email_sent = 1 WHERE id = ?");
                flagPs.setInt(1, orderId);
                flagPs.executeUpdate();
                flagPs.close();
            }
        }
        con.close();
        response.sendRedirect("orders.jsp?updated=true");
        return;
    } catch(Exception e) {
        out.println("Error updating order status: " + e.getMessage());
    }
}

// Delete Order Handler
String deleteId = request.getParameter("delete");
if(deleteId != null && con != null) {
    try {
        PreparedStatement ps = con.prepareStatement("DELETE FROM orfood WHERE id=?");
        ps.setString(1, deleteId);
        ps.executeUpdate();
        ps.close();
        con.close();
        response.sendRedirect("orders.jsp");
        return;
    } catch(Exception e){}
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Orders & Status - Z Kitchen Admin</title>
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <style>
      .status-select {
        padding: 6px 12px;
        border-radius: 8px;
        font-weight: 700;
        font-size: 13px;
        border: 1px solid #cbd5e1;
        outline: none;
        cursor: pointer;
      }
      .status-pending { background: #fef3c7; color: #92400e; }
      .status-confirmed { background: #e0f2fe; color: #0369a1; }
      .status-preparing { background: #fef08a; color: #854d0e; }
      .status-ready { background: #dcfce7; color: #166534; }
      .status-out-for-delivery { background: #fae8ff; color: #86198f; }
      .status-delivered { background: #dcfce7; color: #15803d; border-color: #22c55e; }
      .status-cancelled { background: #fee2e2; color: #991b1b; }
      .btn-pay-complete {
        background: #16a34a;
        color: #ffffff;
        border: none;
        padding: 5px 12px;
        border-radius: 20px;
        font-weight: 700;
        font-size: 11px;
        cursor: pointer;
        transition: all 0.2s ease;
      }
      .btn-pay-complete:hover {
        background: #15803d;
      }
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="sidebar-brand">
            <img src="../images/z kitchen.jpeg" alt="Logo">
            <h2>Food Admin</h2>
        </div>
        <ul class="sidebar-menu">
            <li><a href="dashbord.jsp"><i class="fa-solid fa-chart-line"></i> Dashboard</a></li>
            <li><a href="products.jsp"><i class="fa-solid fa-burger"></i> Products</a></li>
            <li><a href="orders.jsp" class="active"><i class="fa-solid fa-cart-shopping"></i> Orders</a></li>
            <li><a href="users.jsp"><i class="fa-solid fa-users"></i> Users Management</a></li>
            <li><a href="login_activity.jsp"><i class="fa-solid fa-clock-rotate-left"></i> Login Activity</a></li>
            <li><a href="reg_activity.jsp"><i class="fa-solid fa-user-plus"></i> Registration Log</a></li>
            <li><a href="reviews.jsp"><i class="fa-solid fa-star"></i> Customer Reviews</a></li>
            <li><a href="contect.jsp"><i class="fa-solid fa-envelope"></i> Contact Messages</a></li>
            <li class="sidebar-logout"><a href="../index.jsp"><i class="fa-solid fa-right-from-bracket"></i> Logout</a></li>
        </ul>
    </div>

    <div class="main">
        <div class="top-bar">
            <h1>Manage Customer Orders & Delivery Status</h1>
        </div>

        <div class="content-container">
            <div class="container-header">
                <h2>All Food Orders</h2>
                <input type="text" id="adminTableSearch" class="search-input" placeholder="Search orders by customer, food, or status...">
            </div>

            <table>
                <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>Food Item(s)</th>
                        <th>Price</th>
                        <th>Customer</th>
                        <th>Contact / Email</th>
                        <th>Payment Info</th>
                        <th>Delivery Address & GPS</th>
                        <th>Order Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    if(con != null) {
                        try {
                            PreparedStatement st = con.prepareStatement("SELECT * FROM orfood ORDER BY id DESC");
                            ResultSet rs = st.executeQuery();
                            while(rs.next()) {
                                int id = rs.getInt("id");
                                String foodName = sanitizeHtml(rs.getString("nm"));
                                String price = sanitizeHtml(rs.getString("rs"));
                                String cName = sanitizeHtml(rs.getString("cname"));
                                String email = sanitizeHtml(rs.getString("email"));
                                String phone = sanitizeHtml(rs.getString("monumber"));
                                String address = sanitizeHtml(rs.getString("comm"));
                                String status = sanitizeHtml(rs.getString("order_status"));
                                if(status == null || status.trim().isEmpty()) status = "Pending";
                                String lat = sanitizeHtml(rs.getString("latitude"));
                                String lng = sanitizeHtml(rs.getString("longitude"));

                                String payMethod = sanitizeHtml(rs.getString("payment_method"));
                                String payStatus = sanitizeHtml(rs.getString("payment_status"));
                                if(payMethod == null || payMethod.isEmpty()) payMethod = "Cash on Delivery";
                                if(payStatus == null || payStatus.isEmpty() || "null".equalsIgnoreCase(payStatus)) payStatus = "PENDING";

                                String payBadgeStyle = "background:#fef3c7; color:#92400e; border:1px solid #fcd34d;"; // Orange/Yellow
                                boolean isCompleted = false;
                                if("COMPLETED".equalsIgnoreCase(payStatus) || "PAID".equalsIgnoreCase(payStatus)) {
                                    payStatus = "COMPLETED";
                                    payBadgeStyle = "background:#dcfce7; color:#15803d; border:1px solid #4ade80;"; // Green
                                    isCompleted = true;
                                }

                                String statusClass = "status-pending";
                                if("Confirmed".equalsIgnoreCase(status)) statusClass = "status-confirmed";
                                else if("Preparing".equalsIgnoreCase(status)) statusClass = "status-preparing";
                                else if("Ready".equalsIgnoreCase(status)) statusClass = "status-ready";
                                else if("Out for Delivery".equalsIgnoreCase(status)) statusClass = "status-out-for-delivery";
                                else if("Delivered".equalsIgnoreCase(status)) statusClass = "status-delivered";
                                else if("Cancelled".equalsIgnoreCase(status)) statusClass = "status-cancelled";
                    %>
                    <tr>
                        <td><strong>#ORD-<%= id %></strong></td>
                        <td><strong style="color:#0f172a;"><%= foodName %></strong></td>
                        <td style="font-weight:800; color:#ff385c;">&#8377; <%= price %></td>
                        <td><%= cName %></td>
                        <td>
                            <div><%= email %></div>
                            <small style="color:#64748b;"><i class="fa-solid fa-phone me-1"></i><%= phone %></small>
                        </td>
                        <td>
                            <span class="badge px-2 py-1 rounded-pill" style="<%= payBadgeStyle %> font-weight:800; font-size:11px;"><%= payStatus %></span>
                            <div class="small text-muted mt-1" style="font-size:11px; font-weight:600;"><%= payMethod %></div>
                            
                            <div class="mt-2">
                                <% if(!isCompleted) { %>
                                <button type="button" class="btn-pay-complete" onclick="markPaymentCompleted(<%= id %>)" title="Click when Cash on Delivery payment is received from customer">
                                    <i class="fa-solid fa-check me-1"></i> Mark Payment Completed
                                </button>
                                <% } else { %>
                                <span style="font-size:11px; font-weight:700; color:#16a34a;">
                                    <i class="fa-solid fa-circle-check me-1"></i> Payment Completed ✓
                                </span>
                                <% } %>
                            </div>
                        </td>
                        <td>
                            <small style="color:#475569; display:block;"><%= address %></small>
                            <% if(lat != null && !lat.isEmpty()) { %>
                            <small style="color:#16a34a; font-weight:700;"><i class="fa-solid fa-location-dot"></i> GPS: <%= lat %>, <%= lng %></small>
                            <% } %>
                        </td>
                        <td>
                            <select class="status-select <%= statusClass %>" onchange="changeOrderStatus(<%= id %>, this.value)">
                                <option value="Pending" <%= "Pending".equalsIgnoreCase(status) ? "selected" : "" %>>Pending</option>
                                <option value="Confirmed" <%= "Confirmed".equalsIgnoreCase(status) ? "selected" : "" %>>Confirmed</option>
                                <option value="Preparing" <%= "Preparing".equalsIgnoreCase(status) ? "selected" : "" %>>Preparing</option>
                                <option value="Ready" <%= "Ready".equalsIgnoreCase(status) ? "selected" : "" %>>Ready</option>
                                <option value="Out for Delivery" <%= "Out for Delivery".equalsIgnoreCase(status) ? "selected" : "" %>>Out for Delivery</option>
                                <option value="Delivered" <%= "Delivered".equalsIgnoreCase(status) ? "selected" : "" %>>Delivered ✔️</option>
                                <option value="Cancelled" <%= "Cancelled".equalsIgnoreCase(status) ? "selected" : "" %>>Cancelled ❌</option>
                            </select>
                        </td>
                        <td>
                            <button class="btn-sm btn-delete" onclick="confirmDeleteOrder(<%= id %>)">
                                <i class="fa-solid fa-trash"></i> Delete
                            </button>
                        </td>
                    </tr>
                    <%
                            }
                            rs.close();
                            st.close();
                            con.close();
                        } catch(Exception e){
                            out.println("<tr><td colspan='9' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
                        }
                    }
                    %>
                </tbody>
            </table>
        </div>
    </div>

<script>
  function markPaymentCompleted(orderId) {
    if(confirm("Mark Cash on Delivery payment as COMPLETED for Order #" + orderId + "?")) {
      window.location = "orders.jsp?updatePaymentId=" + orderId + "&newPaymentStatus=COMPLETED";
    }
  }

  function changeOrderStatus(orderId, statusValue) {
    if(confirm("Change Order #" + orderId + " status to \"" + statusValue + "\"?")) {
      window.location = "orders.jsp?updateStatusId=" + orderId + "&newStatus=" + encodeURIComponent(statusValue);
    }
  }

  function confirmDeleteOrder(id) {
    if(confirm("Delete Order #" + id + " permanently?")) {
      window.location = "orders.jsp?delete=" + id;
    }
  }

  document.getElementById("adminTableSearch").addEventListener("keyup", function() {
    const q = this.value.toLowerCase();
    document.querySelectorAll("tbody tr").forEach(r => {
      r.style.display = r.innerText.toLowerCase().includes(q) ? "" : "none";
    });
  });
</script>
</body>
</html>