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

/* DELETE PRODUCT */
String deleteId = request.getParameter("delete");
if(deleteId != null && con != null) {
    try {
        PreparedStatement ps = con.prepareStatement("DELETE FROM products WHERE id=?");
        ps.setString(1, deleteId);
        ps.executeUpdate();
        ps.close();
        con.close();
        response.sendRedirect("products.jsp");
        return;
    } catch(Exception e){}
}

/* INSERT / UPDATE PRODUCT */
String name = request.getParameter("name");
String price = request.getParameter("price");
String category = request.getParameter("category");
String image = request.getParameter("image");
String pid = request.getParameter("pid");

if(name != null && price != null && con != null) {
    try {
        if(pid != null && !pid.trim().equals("")) {
            // Update
            PreparedStatement ps = con.prepareStatement("UPDATE products SET name=?, price=?, category=?, image=? WHERE id=?");
            ps.setString(1, name);
            ps.setInt(2, Integer.parseInt(price));
            ps.setString(3, category != null ? category : "Fast Food");
            ps.setString(4, image != null && !image.trim().equals("") ? image : "burger.png");
            ps.setInt(5, Integer.parseInt(pid));
            ps.executeUpdate();
            ps.close();
        } else {
            // Insert
            PreparedStatement ps = con.prepareStatement("INSERT INTO products(name, price, category, image) VALUES(?, ?, ?, ?)");
            ps.setString(1, name);
            ps.setInt(2, Integer.parseInt(price));
            ps.setString(3, category != null ? category : "Fast Food");
            ps.setString(4, image != null && !image.trim().equals("") ? image : "burger.png");
            ps.executeUpdate();
            ps.close();
        }
        con.close();
        response.sendRedirect("products.jsp");
        return;
    } catch(Exception e){
        out.println("Error saving product: " + e.getMessage());
    }
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Products - Z Kitchen Admin</title>
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
            <li><a href="products.jsp" class="active"><i class="fa-solid fa-burger"></i> Products</a></li>
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
            <h1>Food Products Management</h1>
        </div>

        <% if(con == null) { %>
        <div style="background:#fee2e2; border:1px solid #fca5a5; color:#991b1b; padding:15px 20px; border-radius:12px; margin-bottom:25px;">
            <i class="fa-solid fa-triangle-exclamation me-2"></i> <strong>MySQL Server Disconnected:</strong> Please start MySQL in XAMPP Control Panel to manage products.
        </div>
        <% } %>

        <!-- Add / Edit Form -->
        <div class="content-container mb-4">
            <h3 id="formHeader" class="mb-3">Add New Food Product</h3>
            <form method="post" action="products.jsp" class="admin-form" style="gap:12px; flex-wrap:wrap; align-items:center;">
                <input type="hidden" name="pid" id="pid">
                <input type="hidden" name="image" id="image" value="burger.png">

                <input type="text" name="name" id="name" placeholder="Food Name (e.g. Cheese Burger)" required style="flex:2;">
                <input type="number" name="price" id="price" placeholder="Price (₹)" required style="flex:1;">
                <select name="category" id="category" style="flex:1.5;">
                    <option value="Fast Food">Fast Food</option>
                    <option value="Main Course">Main Course</option>
                    <option value="Starters">Starters</option>
                </select>
                
                <!-- Pure Choice File Laptop Uploader Input -->
                <div style="display:flex; align-items:center; gap:10px; flex:2.5;">
                    <input type="file" id="laptopFile" accept="image/*" onchange="uploadLaptopImage(this)" style="flex:1; padding:8px 12px; border-radius:8px; border:1px solid #cbd5e1; outline:none; font-size:14px; background:#ffffff; cursor:pointer;">

                    <img id="imgPreview" src="../images/burger.png" alt="Preview" style="width:42px; height:42px; object-fit:contain; border-radius:8px; border:1px solid #e2e8f0; background:#f8fafc; padding:2px;" onerror="this.src='../images/pizza.png'">
                    <span id="uploadStatus" style="font-size:12px; color:#10b981; font-weight:600;"></span>
                </div>

                <button type="submit" class="btn-save"><i class="fa-solid fa-floppy-disk me-1"></i> Save Product</button>
                <button type="button" id="cancelEditBtn" onclick="cancelEdit()" style="display:none; padding:10px 16px; border-radius:8px; border:1px solid #ccc; background:#fff; cursor:pointer;">Cancel</button>
            </form>
        </div>

        <div class="content-container">
            <div class="container-header">
                <h2>Product Inventory</h2>
                <input type="text" id="adminTableSearch" class="search-input" placeholder="Search products...">
            </div>

            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Image</th>
                        <th>Food Name</th>
                        <th>Category</th>
                        <th>Price</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    if(con != null) {
                        try {
                            Statement st = con.createStatement();
                            ResultSet rs = st.executeQuery("SELECT * FROM products ORDER BY id DESC");
                            while(rs.next()) {
                                int id = rs.getInt("id");
                                String pName = rs.getString("name");
                                int pPrice = rs.getInt("price");
                                String pCat = rs.getString("category") != null ? rs.getString("category") : "Fast Food";
                                String pImg = rs.getString("image") != null ? rs.getString("image") : "burger.png";
                    %>
                    <tr>
                        <td><strong>#<%= id %></strong></td>
                        <td>
                            <img src="../images/<%= pImg %>" alt="<%= pName %>" style="width:45px; height:45px; object-fit:contain; border-radius:6px; background:#f8fafc;" onerror="this.src='../images/pizza.png'">
                        </td>
                        <td><strong><%= pName %></strong></td>
                        <td><span class="badge-status" style="background:#e0f2fe; color:#0369a1;"><%= pCat %></span></td>
                        <td style="font-weight:700; color:#ff385c;">&#8377; <%= pPrice %></td>
                        <td>
                            <button class="btn-sm btn-update" onclick="editProduct('<%= id %>', '<%= pName.replace("'", "\\'") %>', '<%= pPrice %>', '<%= pCat %>', '<%= pImg %>')">
                                <i class="fa-solid fa-pen-to-square"></i> Edit
                            </button>
                            <button class="btn-sm btn-delete" onclick="deleteProduct(<%= id %>)">
                                <i class="fa-solid fa-trash"></i> Delete
                            </button>
                        </td>
                    </tr>
                    <%
                            }
                            con.close();
                        } catch(Exception e){
                            out.println("<tr><td colspan='6' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
                        }
                    } else {
                    %>
                    <tr>
                        <td colspan="6" style="text-align:center; padding:30px; color:#64748b;">
                            MySQL database not connected. Please start MySQL service in XAMPP!
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <script src="js/admin.js"></script>
</body>
</html>