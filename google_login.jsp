<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="dbconnection.jsp" %>

<%
request.setCharacterEncoding("UTF-8");
String email = request.getParameter("email");
String name = request.getParameter("name");
String googleId = request.getParameter("google_id");
String redirect = request.getParameter("redirect");
if(redirect == null) redirect = "";

if(email == null || email.trim().isEmpty()) {
    response.sendRedirect("login.jsp?error=Invalid+Google+Account");
    return;
}

email = email.trim().toLowerCase();
if(googleId == null || googleId.trim().isEmpty()) googleId = "g_" + System.currentTimeMillis();

if(name == null || !isValidFullName(name)) {
    name = "Google User";
}

Connection con = getDbConnection();
if(con != null) {
    try {
        int userId = 0;
        String fullName = name;
        String phone = "";

        // Check if google_id or email exists
        PreparedStatement checkPs = con.prepareStatement("SELECT * FROM users WHERE google_id = ? OR LOWER(email) = ? LIMIT 1");
        checkPs.setString(1, googleId);
        checkPs.setString(2, email);
        ResultSet rs = checkPs.executeQuery();

        if(rs.next()) {
            userId = rs.getInt("user_id");
            fullName = rs.getString("full_name");
            phone = rs.getString("phone_number");

            // Update google_id & last_login
            PreparedStatement updatePs = con.prepareStatement("UPDATE users SET google_id = ?, email_verified = 1, last_login = NOW() WHERE user_id = ?");
            updatePs.setString(1, googleId);
            updatePs.setInt(2, userId);
            updatePs.executeUpdate();
            updatePs.close();
        } else {
            // Insert New Google User
            PreparedStatement insertPs = con.prepareStatement("INSERT INTO users(full_name, email, google_id, registration_method, email_verified, last_login) VALUES(?, ?, ?, 'GOOGLE', 1, NOW())", Statement.RETURN_GENERATED_KEYS);
            insertPs.setString(1, fullName);
            insertPs.setString(2, email);
            insertPs.setString(3, googleId);
            insertPs.executeUpdate();

            ResultSet keys = insertPs.getGeneratedKeys();
            if(keys.next()) userId = keys.getInt(1);
            keys.close();
            insertPs.close();
        }
        rs.close();
        checkPs.close();

        // Record Login Activity Log
        PreparedStatement logPs = con.prepareStatement("INSERT INTO login_activity(user_id, user_identifier, login_status, otp_verified) VALUES(?, ?, 'SUCCESS_GOOGLE', 1)");
        logPs.setInt(1, userId);
        logPs.setString(2, email);
        logPs.executeUpdate();
        logPs.close();

        con.close();

        // Create Active Session
        Map<String, Object> loggedUser = new HashMap<String, Object>();
        loggedUser.put("user_id", userId);
        loggedUser.put("full_name", fullName);
        loggedUser.put("email", email);
        loggedUser.put("phone_number", phone != null ? phone : "");

        session.setAttribute("loggedUser", loggedUser);
        session.setAttribute("userId", userId);
        session.setAttribute("userName", fullName);
        session.setAttribute("userEmail", email);
        session.setAttribute("userPhone", phone != null ? phone : "");

        if(redirect != null && !redirect.trim().isEmpty() && !redirect.contains("login") && !redirect.contains("register")) {
            response.sendRedirect(redirect);
        } else {
            response.sendRedirect("Order.jsp");
        }
        return;
    } catch(Exception e) {
        response.sendRedirect("login.jsp?error=" + java.net.URLEncoder.encode("Google auth error: " + e.getMessage(), "UTF-8"));
        return;
    }
} else {
    response.sendRedirect("login.jsp?error=Database+disconnected.");
}
%>
