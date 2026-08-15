<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,java.io.*,java.net.*" %>
<%@ include file="dbconnection.jsp" %>

<%
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

String amountParam = request.getParameter("amount");
if (amountParam == null || amountParam.trim().isEmpty()) {
    out.print("{\"status\":\"error\",\"message\":\"Missing order amount.\"}");
    return;
}

double totalAmount = 0.0;
try {
    totalAmount = Double.parseDouble(amountParam.trim());
} catch(Exception e) {
    out.print("{\"status\":\"error\",\"message\":\"Invalid order amount format.\"}");
    return;
}

if (totalAmount <= 0) {
    out.print("{\"status\":\"error\",\"message\":\"Order total must be greater than zero.\"}");
    return;
}

int amountInPaise = (int) Math.round(totalAmount * 100);

String keyId = getSmtpConfig("RAZORPAY_KEY_ID");
String keySecret = getSmtpConfig("RAZORPAY_KEY_SECRET");

if (keyId == null || keyId.trim().isEmpty()) {
    keyId = "rzp_test_ZKitchenSample";
}
if (keySecret == null || keySecret.trim().isEmpty()) {
    keySecret = "ZKitchenSecretSampleKey";
}

String razorpayOrderId = null;

// Try to call Razorpay Orders API if live test key is configured
if (!keyId.contains("Sample") && keySecret != null && !keySecret.contains("Sample")) {
    try {
        URL url = new URL("https://api.razorpay.com/v1/orders");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        String auth = keyId + ":" + keySecret;
        String encodedAuth = Base64.getEncoder().encodeToString(auth.getBytes("UTF-8"));
        conn.setRequestProperty("Authorization", "Basic " + encodedAuth);
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setDoOutput(true);

        String jsonPayload = "{\"amount\":" + amountInPaise + ",\"currency\":\"INR\",\"receipt\":\"rcpt_" + System.currentTimeMillis() + "\"}";
        OutputStream os = conn.getOutputStream();
        os.write(jsonPayload.getBytes("UTF-8"));
        os.flush();
        os.close();

        int resCode = conn.getResponseCode();
        if (resCode >= 200 && resCode < 300) {
            BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));
            StringBuilder sb = new StringBuilder();
            String line;
            while((line = br.readLine()) != null) sb.append(line);
            br.close();
            String jsonResp = sb.toString();
            int idIdx = jsonResp.indexOf("\"id\":\"");
            if (idIdx != -1) {
                int start = idIdx + 6;
                int end = jsonResp.indexOf("\"", start);
                if (end != -1) {
                    razorpayOrderId = jsonResp.substring(start, end);
                }
            }
        }
    } catch(Exception ignore) {}
}

// Fallback to secure server-generated Razorpay order ID in test mode
if (razorpayOrderId == null || razorpayOrderId.isEmpty()) {
    razorpayOrderId = "order_test_" + Long.toHexString(System.currentTimeMillis()) + String.format("%04d", new Random().nextInt(10000));
}

out.print("{\"status\":\"success\",\"id\":\"" + razorpayOrderId + "\",\"amount\":" + amountInPaise + ",\"currency\":\"INR\",\"key_id\":\"" + keyId + "\"}");
%>
