<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="dbconnection.jsp" %>

<%
request.setCharacterEncoding("UTF-8");
String identifier = request.getParameter("identifier");
String password = request.getParameter("password");
String redirect = request.getParameter("redirect");
if(redirect == null) redirect = "";

if(identifier == null || password == null || identifier.trim().isEmpty() || password.trim().isEmpty()) {
    response.sendRedirect("login.jsp?error=" + java.net.URLEncoder.encode("Please enter email/phone and password.", "UTF-8"));
    return;
}

identifier = identifier.trim().toLowerCase();
String passHash = hashPassword(password);

Connection con = getDbConnection();
if(con != null) {
    try {
        try {
            Statement alterSt = con.createStatement();
            try { alterSt.executeUpdate("ALTER TABLE users CHANGE COLUMN id user_id INT AUTO_INCREMENT"); } catch(Exception ignore){}
            try { alterSt.executeUpdate("ALTER TABLE users ADD COLUMN user_id INT"); } catch(Exception ignore){}
            alterSt.close();
        } catch(Exception ignore){}

        PreparedStatement ps = con.prepareStatement("SELECT * FROM users WHERE (LOWER(email) = ? OR phone_number = ? OR (phone_number IS NULL AND email = ?)) AND (password_hash = ? OR password_hash = ?)");
        ps.setString(1, identifier);
        ps.setString(2, identifier);
        ps.setString(3, identifier);
        ps.setString(4, passHash);
        ps.setString(5, password);

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

            String accountStatus = "ACTIVE";
            try { accountStatus = rs.getString("account_status"); } catch(Exception e){}

            if("BLOCKED".equalsIgnoreCase(accountStatus)) {
                rs.close();
                ps.close();
                con.close();
                response.sendRedirect("login.jsp?error=" + java.net.URLEncoder.encode("Account is suspended. Please contact administrator.", "UTF-8"));
                return;
            }

            // 1. RECORD PENDING LOGIN ATTEMPT IN LOGIN_ACTIVITY
            int loginId = 0;
            PreparedStatement logPs = con.prepareStatement("INSERT INTO login_activity(user_id, user_identifier, login_status, otp_verified) VALUES(?, ?, 'PENDING_OTP', 0)", Statement.RETURN_GENERATED_KEYS);
            logPs.setInt(1, userId);
            logPs.setString(2, identifier);
            logPs.executeUpdate();
            ResultSet logKeys = logPs.getGeneratedKeys();
            if(logKeys.next()) loginId = logKeys.getInt(1);
            logKeys.close();
            logPs.close();

            // 2. GENERATE CRYPTOGRAPHICALLY SECURE 6-DIGIT OTP FOR LOGIN
            String rawOtp = generateSecureOtp();
            String hashedOtp = hashPassword(rawOtp);

            try {
                PreparedStatement otpPs = con.prepareStatement("INSERT INTO user_otps(user_identifier, user_id, otp_code, otp_type, expires_at) VALUES(?, ?, ?, 'LOGIN', TIMESTAMPADD(MINUTE, 10, NOW()))");
                otpPs.setString(1, identifier);
                otpPs.setInt(2, userId);
                otpPs.setString(3, hashedOtp);
                otpPs.executeUpdate();
                otpPs.close();
            } catch(Exception ex1) {
                PreparedStatement otpPs = con.prepareStatement("INSERT INTO user_otps(user_identifier, otp_code, otp_type, expires_at) VALUES(?, ?, 'LOGIN', TIMESTAMPADD(MINUTE, 10, NOW()))");
                otpPs.setString(1, identifier);
                otpPs.setString(2, hashedOtp);
                otpPs.executeUpdate();
                otpPs.close();
            }

            rs.close();
            ps.close();
            con.close();

            // DISPATCH LOGIN OTP IN BACKGROUND THREAD (PREVENTS PAGE HANGING)
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

            // 3. STORE PENDING LOGIN DATA IN SESSION (SECURELY WITHOUT EXPOSING RAW OTP)
            Map<String, String> pendingLogin = new HashMap<String, String>();
            pendingLogin.put("userId", String.valueOf(userId));
            pendingLogin.put("loginId", String.valueOf(loginId));
            pendingLogin.put("fullName", fullName);
            pendingLogin.put("email", email != null ? email : "");
            pendingLogin.put("phoneNumber", phone != null ? phone : "");
            pendingLogin.put("loginType", "LOGIN");

            session.setAttribute("pendingReg_" + identifier, pendingLogin);

            // Redirect to OTP verification
            response.sendRedirect("verify_otp.jsp?identifier=" + java.net.URLEncoder.encode(identifier, "UTF-8") + "&redirect=" + java.net.URLEncoder.encode(redirect, "UTF-8"));
            return;
        } else {
            rs.close();
            ps.close();

            // Log Failed Login Attempt
            try {
                PreparedStatement failLogPs = con.prepareStatement("INSERT INTO login_activity(user_identifier, login_status, otp_verified) VALUES(?, 'FAILED_PASSWORD', 0)");
                failLogPs.setString(1, identifier);
                failLogPs.executeUpdate();
                failLogPs.close();
            } catch(Exception ignore) {}

            con.close();
            response.sendRedirect("login.jsp?error=" + java.net.URLEncoder.encode("Invalid email/phone or password. Please try again.", "UTF-8") + "&redirect=" + java.net.URLEncoder.encode(redirect, "UTF-8"));
            return;
        }
    } catch(Exception e) {
        response.sendRedirect("login.jsp?error=" + java.net.URLEncoder.encode("Login error: " + e.getMessage(), "UTF-8"));
        return;
    }
} else {
    response.sendRedirect("login.jsp?error=" + java.net.URLEncoder.encode("Database disconnected. Start MySQL in XAMPP.", "UTF-8"));
}
%>
