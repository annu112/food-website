<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="dbconnection.jsp" %>

<%
request.setCharacterEncoding("UTF-8");
String identifier = request.getParameter("identifier");

if(identifier == null || identifier.trim().isEmpty()) {
    response.sendRedirect("forgot_password.jsp?error=" + java.net.URLEncoder.encode("Please enter your registered email or phone number.", "UTF-8"));
    return;
}

identifier = identifier.trim().toLowerCase();

Connection con = getDbConnection();
if(con != null) {
    try {
        PreparedStatement ps = con.prepareStatement("SELECT * FROM users WHERE LOWER(email) = ? OR phone_number = ?");
        ps.setString(1, identifier);
        ps.setString(2, identifier);

        ResultSet rs = ps.executeQuery();
        if(rs.next()) {
            int userId = 0;
            try { userId = rs.getInt("user_id"); } catch(Exception e1) { try { userId = rs.getInt("id"); } catch(Exception e2){} }
            String fullName = "";
            try { fullName = rs.getString("full_name"); } catch(Exception e1) { try { fullName = rs.getString("name"); } catch(Exception e2){} }
            if(fullName == null || fullName.isEmpty()) fullName = "User";

            String email = "";
            try { email = rs.getString("email"); } catch(Exception e){}
            String phone = "";
            try { phone = rs.getString("phone_number"); } catch(Exception e1) { try { phone = rs.getString("phone"); } catch(Exception e2){} }

            rs.close();
            ps.close();

            // Ensure user_otps table schema has required columns
            try {
                Statement alterSt = con.createStatement();
                try { alterSt.executeUpdate("ALTER TABLE user_otps ADD COLUMN user_id INT DEFAULT NULL"); } catch(Exception ignore){}
                try { alterSt.executeUpdate("ALTER TABLE user_otps ADD COLUMN otp_type VARCHAR(20) DEFAULT 'REGISTRATION'"); } catch(Exception ignore){}
                try { alterSt.executeUpdate("ALTER TABLE user_otps ADD COLUMN attempts INT DEFAULT 0"); } catch(Exception ignore){}
                alterSt.close();
            } catch(Exception ignore){}

            // GENERATE CRYPTOGRAPHICALLY SECURE 6-DIGIT OTP FOR PASSWORD RESET
            String rawOtp = generateSecureOtp();
            String hashedOtp = hashPassword(rawOtp);

            try {
                PreparedStatement otpPs = con.prepareStatement("INSERT INTO user_otps(user_identifier, user_id, otp_code, otp_type, expires_at) VALUES(?, ?, ?, 'FORGOT_PASSWORD', TIMESTAMPADD(MINUTE, 10, NOW()))");
                otpPs.setString(1, identifier);
                otpPs.setInt(2, userId);
                otpPs.setString(3, hashedOtp);
                otpPs.executeUpdate();
                otpPs.close();
            } catch(Exception ex1) {
                PreparedStatement otpPs = con.prepareStatement("INSERT INTO user_otps(user_identifier, otp_code, otp_type, expires_at) VALUES(?, ?, 'FORGOT_PASSWORD', TIMESTAMPADD(MINUTE, 10, NOW()))");
                otpPs.setString(1, identifier);
                otpPs.setString(2, hashedOtp);
                otpPs.executeUpdate();
                otpPs.close();
            }
            con.close();

            // DISPATCH RESET OTP IN BACKGROUND THREAD
            final String fIdentifier = identifier;
            final String fFullName = fullName;
            final String fRawOtp = rawOtp;
            final String fEmail = email;

            new Thread(new Runnable() {
                public void run() {
                    try {
                        if(isValidPhone(fIdentifier)) {
                            sendSmsOtp(fIdentifier, fFullName, fRawOtp);
                        } else if(fEmail != null && !fEmail.trim().isEmpty()) {
                            sendOtpEmail(fEmail.trim(), fFullName, fRawOtp);
                        }
                    } catch(Exception ignore) {}
                }
            }).start();

            // Store reset state in session
            Map<String, String> resetState = new HashMap<String, String>();
            resetState.put("userId", String.valueOf(userId));
            resetState.put("fullName", fullName);
            resetState.put("email", email != null ? email : "");
            resetState.put("phone", phone != null ? phone : "");
            session.setAttribute("resetState_" + identifier, resetState);

            response.sendRedirect("reset_password.jsp?identifier=" + java.net.URLEncoder.encode(identifier, "UTF-8") + "&msg=" + java.net.URLEncoder.encode("Reset OTP has been sent to your email/phone. Please enter OTP and your new password.", "UTF-8"));
            return;
        } else {
            rs.close();
            ps.close();
            con.close();
            response.sendRedirect("forgot_password.jsp?error=" + java.net.URLEncoder.encode("No registered account found matching that email or phone number.", "UTF-8"));
            return;
        }
    } catch(Exception e) {
        response.sendRedirect("forgot_password.jsp?error=" + java.net.URLEncoder.encode("Error: " + e.getMessage(), "UTF-8"));
        return;
    }
} else {
    response.sendRedirect("forgot_password.jsp?error=" + java.net.URLEncoder.encode("Database connection error. Please try again later.", "UTF-8"));
}
%>
