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

    int totalOrders = 0;
    int totalProducts = 0;
    int totalSales = 0;
    int totalMessages = 0;
    boolean dbConnected = false;
    String dbErrorMessage = null;
    ResultSet rsOrders = null;
    Connection con = null;

    try {
        con = getDbConnection();
        if(con != null) {
            Statement st = con.createStatement();

            // Auto Create Tables
            st.executeUpdate("CREATE TABLE IF NOT EXISTS contact (id int(11) NOT NULL AUTO_INCREMENT, nam varchar(100) NOT NULL, email varchar(100) NOT NULL, number varchar(50) NOT NULL, comment text NOT NULL, created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            st.executeUpdate("CREATE TABLE IF NOT EXISTS customers (id int(11) NOT NULL AUTO_INCREMENT, name varchar(100) DEFAULT NULL, email varchar(100) DEFAULT NULL, phone varchar(15) DEFAULT NULL, password varchar(100) DEFAULT NULL, created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            st.executeUpdate("CREATE TABLE IF NOT EXISTS orfood (id int(11) NOT NULL AUTO_INCREMENT, nm varchar(100) NOT NULL, rs varchar(100) NOT NULL, cname varchar(100) NOT NULL, email varchar(100) NOT NULL, monumber varchar(100) NOT NULL, comm text NOT NULL, order_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            st.executeUpdate("CREATE TABLE IF NOT EXISTS products (id int(11) NOT NULL AUTO_INCREMENT, name varchar(100) NOT NULL, price int(11) NOT NULL, category varchar(50) DEFAULT 'Fast Food', rating decimal(2,1) DEFAULT 4.5, image varchar(200) DEFAULT NULL, PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
            st.executeUpdate("CREATE TABLE IF NOT EXISTS reviews (id int(11) NOT NULL AUTO_INCREMENT, name varchar(100) NOT NULL, rating int(11) NOT NULL DEFAULT 5, comment text NOT NULL, created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

            // Seed products if empty
            ResultSet pCheck = st.executeQuery("SELECT COUNT(*) FROM products");
            if(pCheck.next() && pCheck.getInt(1) == 0) {
                st.executeUpdate("INSERT INTO products (name, price, category, image) VALUES ('Chicken Nuggets', 200, 'Starters', 'chicken nuggets.png'), ('Garlic Bread', 150, 'Starters', 'Garlic bread.png'), ('Chole Kulche', 250, 'Main Course', 'Chole Kulche.png'), ('Fried Rice', 180, 'Main Course', 'Pineapple_Fried_Rice.png'), ('Paneer Special', 300, 'Main Course', 'paneer.png'), ('Crispy Chicken', 270, 'Fast Food', 'crispy_fried.png'), ('Dahi Vada', 100, 'Starters', 'Dahi vada.png'), ('Seekh Kabab', 250, 'Starters', 'Lyulya_kebab.png'), ('Super Burger', 350, 'Fast Food', 'burger.png'), ('Butter Chicken', 400, 'Main Course', 'butter chicken.jpeg'), ('Biryani', 500, 'Main Course', 'Biryani.jpeg'), ('Italian Pizza', 350, 'Fast Food', 'pizza.png')");
            }

            ResultSet rs1 = st.executeQuery("SELECT COUNT(*) FROM orfood");
            if(rs1.next()) totalOrders = rs1.getInt(1);

            ResultSet rs2 = st.executeQuery("SELECT COUNT(*) FROM products");
            if(rs2.next()) totalProducts = rs2.getInt(1);

            ResultSet rs3 = st.executeQuery("SELECT SUM(CAST(rs AS UNSIGNED)) FROM orfood");
            if(rs3.next()) totalSales = rs3.getInt(1);

            ResultSet rs4 = st.executeQuery("SELECT COUNT(*) FROM contact");
            if(rs4.next()) totalMessages = rs4.getInt(1);

            rsOrders = st.executeQuery("SELECT * FROM orfood ORDER BY id DESC LIMIT 6");
            dbConnected = true;
        } else {
            dbErrorMessage = lastDbError != null ? lastDbError : "MySQL Server is currently stopped on localhost:3306. Please click Start next to MySQL in XAMPP!";
        }
    } catch(Exception e) {
        dbErrorMessage = e.getMessage();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Z Kitchen</title>
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
</head>
<body>

    <div class="sidebar">
        <div class="sidebar-brand">
            <img src="../images/z kitchen.jpeg" alt="Logo">
            <h2>Food Admin</h2>
        </div>
        <ul class="sidebar-menu">
            <li><a href="dashbord.jsp" class="active"><i class="fa-solid fa-chart-line"></i> Dashboard</a></li>
            <li><a href="products.jsp"><i class="fa-solid fa-burger"></i> Products</a></li>
            <li><a href="orders.jsp"><i class="fa-solid fa-cart-shopping"></i> Orders</a></li>
            <li><a href="users.jsp"><i class="fa-solid fa-users"></i> Users Management</a></li>
            <li><a href="login_activity.jsp"><i class="fa-solid fa-clock-rotate-left"></i> Login Activity</a></li>
            <li><a href="reg_activity.jsp"><i class="fa-solid fa-user-plus"></i> Registration Log</a></li>
            <li><a href="contect.jsp"><i class="fa-solid fa-envelope"></i> Contact Messages</a></li>
            <li class="sidebar-logout"><a href="../index.jsp"><i class="fa-solid fa-right-from-bracket"></i> Logout</a></li>
        </ul>
    </div>

    <div class="main">
        <div class="top-bar">
            <h1>Dashboard Overview</h1>
            <div style="font-weight:600; color:#64748b;">Welcome, Admin!</div>
        </div>

        <% if(!dbConnected) { %>
        <div style="background:#fee2e2; border:1px solid #fca5a5; color:#991b1b; padding:20px; border-radius:12px; margin-bottom:25px;">
            <h4 style="margin-bottom:8px;"><i class="fa-solid fa-triangle-exclamation me-2"></i> Database Status Notice</h4>
            <p style="margin-bottom:10px;"><strong>Notice:</strong> <%= dbErrorMessage %></p>
            <p style="margin-bottom:0;">
                <span style="font-weight:700;">Action Required:</span> Open XAMPP Control Panel & Click <strong>Start</strong> next to <strong>MySQL</strong>.
            </p>
        </div>
        <% } %>

        <div class="cards-grid">
            <div class="card-stat">
                <div class="info">
                    <h3>Total Orders</h3>
                    <p><%= totalOrders %></p>
                </div>
                <div class="icon-box"><i class="fa-solid fa-bag-shopping"></i></div>
            </div>

            <div class="card-stat">
                <div class="info">
                    <h3>Total Products</h3>
                    <p><%= totalProducts %></p>
                </div>
                <div class="icon-box"><i class="fa-solid fa-utensils"></i></div>
            </div>

            <div class="card-stat">
                <div class="info">
                    <h3>Total Revenue</h3>
                    <p>&#8377; <%= totalSales %></p>
                </div>
                <div class="icon-box"><i class="fa-solid fa-indian-rupee-sign"></i></div>
            </div>

            <div class="card-stat">
                <div class="info">
                    <h3>Inquiries</h3>
                    <p><%= totalMessages %></p>
                </div>
                <div class="icon-box"><i class="fa-solid fa-comments"></i></div>
            </div>
        </div>

        <div class="content-container">
            <div class="container-header">
                <h2>Recent Orders</h2>
                <a href="orders.jsp" style="color:#ff385c; text-decoration:none; font-weight:700;">View All Orders &rarr;</a>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Customer</th>
                        <th>Product Details</th>
                        <th>Amount</th>
                        <th>Contact</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                    if(dbConnected && rsOrders != null) {
                        while(rsOrders.next()) { 
                    %>
                    <tr>
                        <td><strong>#<%= rsOrders.getString("id") %></strong></td>
                        <td><%= rsOrders.getString("cname") %></td>
                        <td><%= rsOrders.getString("nm") %></td>
                        <td style="font-weight:700; color:#ff385c;">&#8377; <%= rsOrders.getString("rs") %></td>
                        <td><%= rsOrders.getString("email") %></td>
                        <td><span class="badge-status">Confirmed</span></td>
                    </tr>
                    <% 
                        }
                    } else { 
                    %>
                    <tr>
                        <td colspan="6" style="text-align:center; padding:30px; color:#64748b;">
                            MySQL database service is stopped. Start MySQL in XAMPP Control Panel to view dynamic orders!
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

</body>
</html>

<%
    if(con != null) {
        try { con.close(); } catch(Exception e){}
    }
%>