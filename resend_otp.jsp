<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="dbconnection.jsp" %>

<%
request.setCharacterEncoding("UTF-8");
String identifier = request.getParameter("identifier");
String redirect = request.getParameter("redirect");
if(redirect == null) redirect = "";

if(identifier != null && !identifier.trim().isEmpty()) {
    String rawOtp = generateSecureOtp();
    String hashedOtp = hashPassword(rawOtp);
    String cleanId = identifier.trim().toLowerCase();

    Connection con = getDbConnection();
    if(con != null) {
        try {
            PreparedStatement otpPs = con.prepareStatement("INSERT INTO user_otps(user_identifier, otp_code, otp_type, expires_at) VALUES(?, ?, 'RESEND', TIMESTAMPADD(MINUTE, 10, NOW()))");
            otpPs.setString(1, cleanId);
            otpPs.setString(2, hashedOtp);
            otpPs.executeUpdate();
            otpPs.close();
            con.close();
        } catch(Exception e) {}
    }

    // DISPATCH FRESH OTP IN BACKGROUND THREAD (PREVENTS PAGE HANGING)
    final String fCleanId = cleanId;
    final String fRawOtp = rawOtp;
    Map<String, String> pendingUser = (Map<String, String>) session.getAttribute("pendingReg_" + cleanId);
    final String fName = pendingUser != null && pendingUser.get("fullName") != null ? pendingUser.get("fullName") : "Customer";

    new Thread(new Runnable() {
        public void run() {
            try {
                if(isValidPhone(fCleanId)) {
                    sendSmsOtp(fCleanId, fName, fRawOtp);
                } else if(isValidEmail(fCleanId)) {
                    sendOtpEmail(fCleanId, fName, fRawOtp);
                }
            } catch(Exception ignore) {}
        }
    }).start();
}

response.sendRedirect("verify_otp.jsp?identifier=" + java.net.URLEncoder.encode(identifier != null ? identifier : "", "UTF-8") + "&redirect=" + java.net.URLEncoder.encode(redirect, "UTF-8"));
%>
