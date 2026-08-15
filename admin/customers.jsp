<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="../dbconnection.jsp" %>

<%
Map<String, Object> adminUser = (Map<String, Object>) session.getAttribute("adminUser");
if (adminUser == null || !"ADMIN".equalsIgnoreCase((String) adminUser.get("role"))) {
    response.sendRedirect("../login.jsp?redirect=admin/dashbord.jsp");
    return;
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registered Customers - Z Kitchen Admin</title>
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
            <li><a href="dashbord.jsp"><i class="fa-solid fa-chart-line"></i> Dashboard</a></li>
            <li><a href="products.jsp"><i class="fa-solid fa-burger"></i> Products</a></li>
            <li><a href="orders.jsp"><i class="fa-solid fa-cart-shopping"></i> Orders</a></li>
            <li><a href="contect.jsp"><i class="fa-solid fa-envelope"></i> Contact Messages</a></li>
            <li class="sidebar-logout"><a href="../index.jsp"><i class="fa-solid fa-right-from-bracket"></i> Logout</a></li>
        </ul>
    </div>

    <div class="main">
        <div class="top-bar">
            <h1>Registered Customers</h1>
        </div>

        <div class="content-container">
            <div class="container-header">
                <h2>Customer Directory</h2>
                <input type="text" id="adminTableSearch" class="search-input" placeholder="Search customers...">
            </div>

            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Phone</th>
                        <th>Registered Date</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    try {
                        Connection con = getDbConnection();
                        PreparedStatement st = con.prepareStatement("SELECT * FROM customers ORDER BY id DESC");
                        ResultSet rs = st.executeQuery();
                        while(rs.next()) {
                    %>
                    <tr>
                        <td>#<%= rs.getInt("id") %></td>
                        <td><strong><%= rs.getString("name") %></strong></td>
                        <td><%= rs.getString("email") %></td>
                        <td><%= rs.getString("phone") %></td>
                        <td><%= rs.getString("created_at") %></td>
                    </tr>
                    <%
                        }
                        con.close();
                    } catch(Exception e){
                        out.println("<tr><td colspan='5' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
                    }
                    %>
                </tbody>
            </table>
        </div>
    </div>

    <script src="js/admin.js"></script>
</body>
</html>