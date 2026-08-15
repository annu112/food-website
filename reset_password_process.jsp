<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="dbconnection.jsp" %>

<%
request.setCharacterEncoding("UTF-8");
String identifier = request.getParameter("identifier");
String inputOtp = request.getParameter("otp");
String newPassword = request.getParameter("newPassword");
String confirmPassword = request.getParameter("confirmPassword");

if(identifier == null || inputOtp == null || newPassword == null || confirmPassword == null) {
    response.sendRedirect("forgot_password.jsp");
    return;
}

identifier = identifier.trim().toLowerCase();

if(newPassword.length() < 6) {
    response.sendRedirect("reset_password.jsp?identifier=" + java.net.URLEncoder.encode(identifier, "UTF-8") + "&error=" + java.net.URLEncoder.encode("Password must be at least 6 characters long.", "UTF-8"));
    return;
}

if(!newPassword.equals(confirmPassword)) {
    response.sendRedirect("reset_password.jsp?identifier=" + java.net.URLEncoder.encode(identifier, "UTF-8") + "&error=" + java.net.URLEncoder.encode("Passwords do not match. Please re-enter.", "UTF-8"));
    return;
}

String inputHash = hashPassword(inputOtp.trim());
String newPassHash = hashPassword(newPassword);

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
            errorMessage = "No active OTP reset request found.";
        }
        rs.close();
        ps.close();

        if(isValid) {
            // UPDATE USER PASSWORD IN USERS TABLE
            PreparedStatement upPs = con.prepareStatement("UPDATE users SET password_hash = ? WHERE LOWER(email) = ? OR phone_number = ?");
            upPs.setString(1, newPassHash);
            upPs.setString(2, identifier);
            upPs.setString(3, identifier);
            upPs.executeUpdate();
            upPs.close();

            con.close();
            response.sendRedirect("login.jsp?msg=" + java.net.URLEncoder.encode("Password reset successfully! Please sign in with your new password.", "UTF-8"));
            return;
        } else {
            con.close();
        }
    } catch(Exception e) {
        errorMessage = e.getMessage();
    }
}

if(!isValid) {
    if(errorMessage == null) errorMessage = "Invalid OTP code.";
    response.sendRedirect("reset_password.jsp?identifier=" + java.net.URLEncoder.encode(identifier, "UTF-8") + "&error=" + java.net.URLEncoder.encode(errorMessage, "UTF-8"));
}
%>
