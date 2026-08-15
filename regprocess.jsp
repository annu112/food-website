<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="dbconnection.jsp" %>

<%
request.setCharacterEncoding("UTF-8");
String regType = request.getParameter("regType");
String fullName = request.getParameter("fullName");
String email = request.getParameter("email");
String countryCode = request.getParameter("countryCode");
String phoneNumber = request.getParameter("phoneNumber");
String password = request.getParameter("password");
String redirect = request.getParameter("redirect");
if(redirect == null) redirect = "";

if(fullName != null) fullName = fullName.trim().replaceAll("\\s+", " ");

/* 1. STRICT BACKEND FULL NAME VALIDATION */
if (!isValidFullName(fullName)) {
    response.sendRedirect("register.jsp?error=" + java.net.URLEncoder.encode("Name can contain only alphabets and spaces.", "UTF-8") + "&redirect=" + java.net.URLEncoder.encode(redirect, "UTF-8"));
    return;
}

String fullPhone = null;
if("phone".equals(regType)) {
    if(countryCode == null) countryCode = "+91";
    fullPhone = countryCode + phoneNumber;
    if(!isValidPhone(fullPhone)) {
        response.sendRedirect("register.jsp?error=" + java.net.URLEncoder.encode("Invalid phone number format.", "UTF-8") + "&redirect=" + java.net.URLEncoder.encode(redirect, "UTF-8"));
        return;
    }
} else {
    if(!isValidEmail(email)) {
        response.sendRedirect("register.jsp?error=" + java.net.URLEncoder.encode("Invalid email address format.", "UTF-8") + "&redirect=" + java.net.URLEncoder.encode(redirect, "UTF-8"));
        return;
    }
}

String identifier = "phone".equals(regType) ? fullPhone : email.toLowerCase();

/* 2. DUPLICATE CHECK IN DATABASE */
Connection con = getDbConnection();
if(con != null) {
    try {
        PreparedStatement checkPs;
        if("phone".equals(regType)) {
            checkPs = con.prepareStatement("SELECT user_id FROM users WHERE phone_number = ?");
            checkPs.setString(1, fullPhone);
        } else {
            checkPs = con.prepareStatement("SELECT user_id FROM users WHERE email = ?");
            checkPs.setString(1, email.toLowerCase());
        }
        ResultSet rs = checkPs.executeQuery();
        if(rs.next()) {
            rs.close();
            checkPs.close();
            con.close();
            response.sendRedirect("login.jsp?error=" + java.net.URLEncoder.encode("Account already exists. Please Sign In below.", "UTF-8") + "&redirect=" + java.net.URLEncoder.encode(redirect, "UTF-8"));
            return;
        }
        rs.close();
        checkPs.close();
    } catch(Exception e) {}
}

/* 3. GENERATE CRYPTOGRAPHICALLY SECURE 6-DIGIT OTP & STORE IN DATABASE */
String rawOtp = generateSecureOtp();
String hashedOtp = hashPassword(rawOtp);

if(con != null) {
    try {
        PreparedStatement otpPs = con.prepareStatement("INSERT INTO user_otps(user_identifier, otp_code, otp_type, expires_at) VALUES(?, ?, ?, TIMESTAMPADD(MINUTE, 10, NOW()))");
        otpPs.setString(1, identifier);
        otpPs.setString(2, hashedOtp);
        otpPs.setString(3, "phone".equals(regType) ? "PHONE_REG" : "EMAIL_REG");
        otpPs.executeUpdate();
        otpPs.close();
        con.close();
    } catch(Exception e) {}
}

/* 4. DISPATCH OTP VIA EMAIL OR SMS IN BACKGROUND THREAD (PREVENTS LOADING HANG) */
final String fIdentifier = identifier;
final String fFullName = fullName;
final String fRawOtp = rawOtp;
final String fRegType = regType;
final String fFullPhone = fullPhone;

new Thread(new Runnable() {
    public void run() {
        try {
            if("phone".equals(fRegType)) {
                sendSmsOtp(fFullPhone, fFullName, fRawOtp);
            } else if("email".equals(fRegType) || isValidEmail(fIdentifier)) {
                sendOtpEmail(fIdentifier, fFullName, fRawOtp);
            }
        } catch(Exception ignore) {}
    }
}).start();

/* 4. STORE PENDING REGISTRATION SESSION DATA (SECURELY WITHOUT EXPOSING RAW OTP) */
Map<String, String> pendingUser = new HashMap<String, String>();
pendingUser.put("fullName", fullName);
pendingUser.put("email", "email".equals(regType) ? email.toLowerCase() : "");
pendingUser.put("phoneNumber", "phone".equals(regType) ? fullPhone : "");
pendingUser.put("passwordHash", hashPassword(password));
pendingUser.put("regType", regType);

session.setAttribute("pendingReg_" + identifier, pendingUser);

response.sendRedirect("verify_otp.jsp?identifier=" + java.net.URLEncoder.encode(identifier, "UTF-8") + "&redirect=" + java.net.URLEncoder.encode(redirect, "UTF-8"));
%>
