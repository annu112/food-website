<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="dbconnection.jsp" %>

<%
request.setCharacterEncoding("UTF-8");
String identifier = request.getParameter("identifier");
String inputOtp = request.getParameter("otp");
String redirect = request.getParameter("redirect");
if(redirect == null) redirect = "";

if(identifier == null || inputOtp == null) {
    response.sendRedirect("register.jsp");
    return;
}

Map<String, String> pendingUser = (Map<String, String>) session.getAttribute("pendingReg_" + identifier);
String rawOtp = pendingUser != null ? pendingUser.get("rawOtp") : null;
String loginType = pendingUser != null ? pendingUser.get("loginType") : "REGISTRATION";
String inputHash = hashPassword(inputOtp.trim());

boolean isValid = false;
String errorMessage = null;

Connection con = getDbConnection();
if(con != null) {
    try {
        PreparedStatement ps = con.prepareStatement("SELECT * FROM user_otps WHERE user_identifier = ? AND verified = 0 ORDER BY id DESC LIMIT 1");
        ps.setString(1, identifier);
        ResultSet rs = ps.executeQuery();
        if(rs.next()) {
            int otpId = rs.getInt("id");
            int attempts = rs.getInt("attempts");
            String storedHash = rs.getString("otp_code");
            Timestamp expiresAt = rs.getTimestamp("expires_at");

            String isTestMode = getSmtpConfig("OTP_TEST_MODE");
            boolean testModeEnabled = "true".equalsIgnoreCase(isTestMode);

            if(attempts >= 5) {
                errorMessage = "Maximum verification attempts exceeded. Please request a new OTP.";
            } else if(expiresAt != null && expiresAt.before(new java.util.Date())) {
                errorMessage = "OTP has expired. Please click Resend OTP.";
            } else if(inputHash.equals(storedHash) || (testModeEnabled && "555555".equals(inputOtp.trim()))) {
                isValid = true;
                // Mark OTP verified
                PreparedStatement markPs = con.prepareStatement("UPDATE user_otps SET verified = 1 WHERE id = ?");
                markPs.setInt(1, otpId);
                markPs.executeUpdate();
                markPs.close();
            } else {
                // Increment attempts
                PreparedStatement incPs = con.prepareStatement("UPDATE user_otps SET attempts = attempts + 1 WHERE id = ?");
                incPs.setInt(1, otpId);
                incPs.executeUpdate();
                incPs.close();
                errorMessage = "Incorrect OTP code. Attempts remaining: " + (4 - attempts);
            }
        } else {
            errorMessage = "No active OTP request found.";
        }
        rs.close();
        ps.close();
    } catch(Exception e) {
        errorMessage = e.getMessage();
    }
}

if(!isValid) {
    if(errorMessage == null) errorMessage = "Invalid OTP code.";
    response.sendRedirect("verify_otp.jsp?identifier=" + java.net.URLEncoder.encode(identifier, "UTF-8") + "&error=" + java.net.URLEncoder.encode(errorMessage, "UTF-8") + "&redirect=" + java.net.URLEncoder.encode(redirect, "UTF-8"));
    return;
}

/* PROCESS SUCCESSFUL OTP VERIFICATION FOR LOGIN OR REGISTRATION */
if(pendingUser != null && con != null) {
    try {
        int targetUserId = 0;
        String fullName = pendingUser.get("fullName");
        String email = pendingUser.get("email");
        String phoneNumber = pendingUser.get("phoneNumber");

        if("LOGIN".equals(loginType)) {
            // EXISTING USER LOGIN OTP VERIFIED
            targetUserId = Integer.parseInt(pendingUser.get("userId"));
            String loginIdStr = pendingUser.get("loginId");

            // Update login activity status
            if(loginIdStr != null && !loginIdStr.isEmpty()) {
                PreparedStatement logUp = con.prepareStatement("UPDATE login_activity SET otp_verified = 1, login_status = 'SUCCESS' WHERE login_id = ?");
                logUp.setInt(1, Integer.parseInt(loginIdStr));
                logUp.executeUpdate();
                logUp.close();
            }

            // Update last_login
            PreparedStatement userUp = con.prepareStatement("UPDATE users SET last_login = NOW() WHERE user_id = ?");
            userUp.setInt(1, targetUserId);
            userUp.executeUpdate();
            userUp.close();

        } else {
            // NEW USER REGISTRATION OTP VERIFIED
            String passwordHash = pendingUser.get("passwordHash");
            String regType = pendingUser.get("regType");

            String regMethod = "phone".equals(regType) ? "PHONE" : "EMAIL";

            PreparedStatement insertPs = con.prepareStatement("INSERT INTO users(full_name, email, phone_number, password_hash, registration_method, role, email_verified, phone_verified, last_login) VALUES(?, ?, ?, ?, ?, 'CUSTOMER', ?, ?, NOW())", Statement.RETURN_GENERATED_KEYS);
            insertPs.setString(1, fullName);
            insertPs.setString(2, email != null && !email.isEmpty() ? email : null);
            insertPs.setString(3, phoneNumber != null && !phoneNumber.isEmpty() ? phoneNumber : null);
            insertPs.setString(4, passwordHash);
            insertPs.setString(5, regMethod);
            insertPs.setInt(6, "email".equals(regType) ? 1 : 0);
            insertPs.setInt(7, "phone".equals(regType) ? 1 : 0);

            insertPs.executeUpdate();
            ResultSet keys = insertPs.getGeneratedKeys();
            if(keys.next()) targetUserId = keys.getInt(1);
            keys.close();
            insertPs.close();

            // Record initial registration login activity
            PreparedStatement regLogPs = con.prepareStatement("INSERT INTO login_activity(user_id, user_identifier, login_status, otp_verified) VALUES(?, ?, 'SUCCESS', 1)");
            regLogPs.setInt(1, targetUserId);
            regLogPs.setString(2, identifier);
            regLogPs.executeUpdate();
            regLogPs.close();

            // SEND REGISTRATION CONFIRMATION EMAIL IMMEDIATELY
            if(email != null && !email.trim().isEmpty()) {
                try {
                    sendRegistrationEmail(email.trim(), fullName, targetUserId);
                } catch(Exception ignore) {}
            }
        }

        // Create Active Session
        Map<String, Object> loggedUser = new HashMap<String, Object>();
        loggedUser.put("user_id", targetUserId);
        loggedUser.put("full_name", fullName);
        loggedUser.put("email", email != null ? email : "");
        loggedUser.put("phone_number", phoneNumber != null ? phoneNumber : "");
        loggedUser.put("role", "CUSTOMER");

        session.setAttribute("loggedUser", loggedUser);
        session.setAttribute("userId", targetUserId);
        session.setAttribute("userName", fullName);
        session.setAttribute("userEmail", email != null ? email : "");
        session.setAttribute("userPhone", phoneNumber != null ? phoneNumber : "");
        session.setAttribute("userRole", "CUSTOMER");

        session.removeAttribute("pendingReg_" + identifier);
        con.close();

        if(redirect != null && !redirect.trim().isEmpty() && !redirect.contains("login") && !redirect.contains("register")) {
            response.sendRedirect(redirect);
        } else {
            response.sendRedirect("profile.jsp");
        }
        return;
    } catch(Exception e) {
        out.println("OTP Verification completion error: " + e.getMessage());
    }
} else {
    response.sendRedirect("login.jsp");
}
%>
