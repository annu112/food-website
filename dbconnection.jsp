<%@ page import="java.sql.*,java.io.*,java.net.*,java.util.*,java.nio.file.*,java.security.MessageDigest" %>
<%!
    public static class DriverShim implements Driver {
        private Driver driver;
        public DriverShim(Driver d) { this.driver = d; }
        public boolean acceptsURL(String u) throws SQLException { return this.driver.acceptsURL(u); }
        public Connection connect(String u, Properties p) throws SQLException { return this.driver.connect(u, p); }
        public int getMajorVersion() { return this.driver.getMajorVersion(); }
        public int getMinorVersion() { return this.driver.getMinorVersion(); }
        public DriverPropertyInfo[] getPropertyInfo(String u, Properties p) throws SQLException { return this.driver.getPropertyInfo(u, p); }
        public boolean jdbcCompliant() { return this.driver.jdbcCompliant(); }
        public java.util.logging.Logger getParentLogger() throws SQLFeatureNotSupportedException { return this.driver.getParentLogger(); }
    }

    private static boolean resourcesAutoCopied = false;
    public static String lastDbError = null;
    private static String cachedDbPassword = null;
    private static boolean dbTablesUpgraded = false;

    /* Password Hashing Helper (SHA-256) */
    public static String hashPassword(String password) {
        if(password == null || password.isEmpty()) return "";
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes("UTF-8"));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch(Exception e) {
            return password;
        }
    }

    /* Cryptographically Secure 6-Digit OTP Generator */
    public static String generateSecureOtp() {
        try {
            java.security.SecureRandom random = new java.security.SecureRandom();
            int num = 100000 + random.nextInt(900000);
            return String.valueOf(num);
        } catch(Exception e) {
            return String.format("%06d", new java.util.Random().nextInt(900000) + 100000);
        }
    }

    /* CSRF TOKEN GENERATOR AND VERIFIER */
    public static String getCsrfToken(HttpSession session) {
        if (session == null) return "";
        String token = (String) session.getAttribute("CSRF_TOKEN");
        if (token == null || token.isEmpty()) {
            token = java.util.UUID.randomUUID().toString();
            session.setAttribute("CSRF_TOKEN", token);
        }
        return token;
    }

    public static boolean isValidCsrfToken(HttpServletRequest request, HttpSession session) {
        if (session == null) return false;
        String sessionToken = (String) session.getAttribute("CSRF_TOKEN");
        if (sessionToken == null || sessionToken.isEmpty()) return false;
        String requestToken = request.getParameter("csrf_token");
        if (requestToken == null || requestToken.isEmpty()) {
            requestToken = request.getHeader("X-CSRF-TOKEN");
        }
        return sessionToken.equals(requestToken);
    }

    /* INJECT SECURITY RESPONSE HEADERS */
    public static void setSecurityHeaders(HttpServletResponse response) {
        if (response != null) {
            response.setHeader("X-Frame-Options", "DENY");
            response.setHeader("X-Content-Type-Options", "nosniff");
            response.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
            response.setHeader("X-XSS-Protection", "1; mode=block");
        }
    }

    /* HTML Sanitizer (XSS Protection) */
    public static String sanitizeHtml(String input) {
        if(input == null) return "";
        return input.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#x27;")
                    .replace("/", "&#x2F;");
    }

    /* FULL NAME VALIDATION (Accepts ONLY English Alphabets A-Z, a-z and single spaces) */
    public static boolean isValidFullName(String name) {
        if(name == null) return false;
        String trimmed = name.trim();
        if(trimmed.length() < 2 || trimmed.length() > 80) return false;
        return trimmed.matches("^[A-Za-z]+(?: [A-Za-z]+)*$");
    }

    /* Email Format Validation */
    public static boolean isValidEmail(String email) {
        if(email == null) return false;
        return email.trim().matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    }

    /* Phone Number Format Validation */
    public static boolean isValidPhone(String phone) {
        if(phone == null) return false;
        return phone.trim().matches("^\\+?[0-9]{7,15}$");
    }

    /* SERVER-SIDE RAZORPAY HMAC-SHA256 SIGNATURE VERIFICATION */
    public static boolean verifyRazorpaySignature(String razorpayOrderId, String razorpayPaymentId, String razorpaySignature, String secretKey) {
        if(razorpayOrderId == null || razorpayPaymentId == null || razorpaySignature == null || secretKey == null) return false;
        try {
            String payload = razorpayOrderId.trim() + "|" + razorpayPaymentId.trim();
            javax.crypto.Mac mac = javax.crypto.Mac.getInstance("HmacSHA256");
            javax.crypto.spec.SecretKeySpec secretKeySpec = new javax.crypto.spec.SecretKeySpec(secretKey.getBytes("UTF-8"), "HmacSHA256");
            mac.init(secretKeySpec);
            byte[] hash = mac.doFinal(payload.getBytes("UTF-8"));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString().equalsIgnoreCase(razorpaySignature.trim());
        } catch(Exception e) {
            return false;
        }
    /* SERVER-SIDE CART JSON PARSER */
    public static List<Map<String, Object>> parseCartJson(String jsonStr) {
        List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
        if (jsonStr == null || jsonStr.trim().isEmpty() || jsonStr.trim().equals("[]")) {
            return list;
        }
        try {
            java.util.regex.Pattern p = java.util.regex.Pattern.compile("\\{[^{}]*\\}");
            java.util.regex.Matcher m = p.matcher(jsonStr);
            while (m.find()) {
                String objStr = m.group();
                Map<String, Object> map = new HashMap<String, Object>();

                int id = 0;
                String name = "";
                double price = 0.0;
                String image = "pizza.png";
                String category = "Fast Food";
                int qty = 1;

                java.util.regex.Matcher mId = java.util.regex.Pattern.compile("\"id\"\\s*:\\s*(\\d+)").matcher(objStr);
                if (mId.find()) id = Integer.parseInt(mId.group(1));

                java.util.regex.Matcher mName = java.util.regex.Pattern.compile("\"name\"\\s*:\\s*\"([^\"]+)\"").matcher(objStr);
                if (mName.find()) name = mName.group(1);

                java.util.regex.Matcher mPrice = java.util.regex.Pattern.compile("\"price\"\\s*:\\s*([0-9.]+)").matcher(objStr);
                if (mPrice.find()) price = Double.parseDouble(mPrice.group(1));

                java.util.regex.Matcher mImg = java.util.regex.Pattern.compile("\"image\"\\s*:\\s*\"([^\"]+)\"").matcher(objStr);
                if (mImg.find()) image = mImg.group(1);

                java.util.regex.Matcher mCat = java.util.regex.Pattern.compile("\"category\"\\s*:\\s*\"([^\"]+)\"").matcher(objStr);
                if (mCat.find()) category = mCat.group(1);

                java.util.regex.Matcher mQty = java.util.regex.Pattern.compile("\"qty\"\\s*:\\s*(\\d+)").matcher(objStr);
                if (mQty.find()) qty = Integer.parseInt(mQty.group(1));

                if (!name.isEmpty() && price > 0) {
                    map.put("id", id);
                    map.put("name", name);
                    map.put("price", price);
                    map.put("image", image);
                    map.put("category", category);
                    map.put("qty", qty);
                    list.add(map);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /* ENVIRONMENT & .ENV CONFIGURATION LOADER */
    public static String getSmtpConfig(String key) {
        if(key == null) return null;
        String val = System.getenv(key);
        if(val != null && !val.trim().isEmpty()) return val.trim();
        val = System.getProperty(key);
        if(val != null && !val.trim().isEmpty()) return val.trim();
        try {
            String[] envPaths = {
                "c:/Program Files/Apache Software Foundation/Tomcat 9.0/webapps/Daynemic_web/WEB-INF/.env",
                "c:/xampp/tomcat/webapps/Daynemic_web/WEB-INF/.env"
            };
            for(String path : envPaths) {
                File f = new File(path);
                if(f.exists()) {
                    List<String> lines = Files.readAllLines(f.toPath());
                    for(String line : lines) {
                        line = line.trim();
                        if(line.startsWith("#") || !line.contains("=")) continue;
                        String[] parts = line.split("=", 2);
                        if(parts[0].trim().equals(key)) {
                            return parts[1].trim().replaceAll("^\"|\"$|^'|'$", "");
                        }
                    }
                }
            }
        } catch(Exception ignore) {}
        return null;
    }

    private static void sendSmtpCmd(OutputStream out, String cmd) throws Exception {
        if (!cmd.endsWith("\r\n")) cmd = cmd + "\r\n";
        out.write(cmd.getBytes("UTF-8"));
        out.flush();
    }

    private static String readSmtpResponse(BufferedReader reader) throws Exception {
        String line;
        StringBuilder sb = new StringBuilder();
        while ((line = reader.readLine()) != null) {
            sb.append(line).append("\n");
            if (line.length() >= 4 && line.charAt(3) == ' ') break;
        }
        return sb.toString();
    }

    /* NATIVE JAVA SOCKET SMTP CLIENT FOR GMAIL & SMTP SERVERS (ZERO EXTERNAL JAR DEPENDENCY) */
    public static boolean sendNativeSmtpEmail(String smtpHost, int smtpPort, String smtpUser, String smtpPass, String smtpFrom, String toEmail, String subject, String bodyHtml) throws Exception {
        java.net.Socket socket = new java.net.Socket();
        socket.connect(new java.net.InetSocketAddress(smtpHost, smtpPort), 4000);
        socket.setSoTimeout(5000);
        BufferedReader reader = new BufferedReader(new InputStreamReader(socket.getInputStream(), "UTF-8"));
        OutputStream out = socket.getOutputStream();

        String line = reader.readLine();
        if (line == null || !line.startsWith("220")) {
            socket.close();
            throw new Exception("SMTP Server greeting failed: " + line);
        }

        sendSmtpCmd(out, "EHLO localhost");
        readSmtpResponse(reader);

        if (smtpPort == 587) {
            sendSmtpCmd(out, "STARTTLS");
            line = reader.readLine();
            if (line == null || !line.startsWith("220")) {
                socket.close();
                throw new Exception("STARTTLS failed: " + line);
            }
            javax.net.ssl.SSLSocketFactory sslFactory = (javax.net.ssl.SSLSocketFactory) javax.net.ssl.SSLSocketFactory.getDefault();
            javax.net.ssl.SSLSocket sslSocket = (javax.net.ssl.SSLSocket) sslFactory.createSocket(socket, smtpHost, smtpPort, true);
            sslSocket.startHandshake();
            reader = new BufferedReader(new InputStreamReader(sslSocket.getInputStream(), "UTF-8"));
            out = sslSocket.getOutputStream();

            sendSmtpCmd(out, "EHLO localhost");
            readSmtpResponse(reader);
        }

        // AUTH LOGIN
        sendSmtpCmd(out, "AUTH LOGIN");
        line = reader.readLine();
        if (line == null || !line.startsWith("334")) {
            throw new Exception("AUTH LOGIN rejected: " + line);
        }

        String b64User = Base64.getEncoder().encodeToString(smtpUser.getBytes("UTF-8"));
        sendSmtpCmd(out, b64User);
        line = reader.readLine();
        if (line == null || !line.startsWith("334")) {
            throw new Exception("Username rejected: " + line);
        }

        String b64Pass = Base64.getEncoder().encodeToString(smtpPass.getBytes("UTF-8"));
        sendSmtpCmd(out, b64Pass);
        line = reader.readLine();
        if (line == null || !line.startsWith("235")) {
            throw new Exception("SMTP Authentication failed: " + line);
        }

        // MAIL FROM
        sendSmtpCmd(out, "MAIL FROM:<" + smtpFrom + ">");
        line = reader.readLine();
        if (line == null || !line.startsWith("250")) {
            throw new Exception("MAIL FROM rejected: " + line);
        }

        // RCPT TO
        sendSmtpCmd(out, "RCPT TO:<" + toEmail + ">");
        line = reader.readLine();
        if (line == null || !line.startsWith("250")) {
            throw new Exception("RCPT TO rejected for " + toEmail + ": " + line);
        }

        // DATA
        sendSmtpCmd(out, "DATA");
        line = reader.readLine();
        if (line == null || !line.startsWith("354")) {
            throw new Exception("DATA command rejected: " + line);
        }

        // MIME Body Construction
        StringBuilder msg = new StringBuilder();
        msg.append("From: Z Kitchen Support <").append(smtpFrom).append(">\r\n");
        msg.append("To: ").append(toEmail).append("\r\n");
        msg.append("Subject: ").append(subject).append("\r\n");
        msg.append("MIME-Version: 1.0\r\n");
        msg.append("Content-Type: text/html; charset=utf-8\r\n");
        msg.append("\r\n");
        msg.append(bodyHtml);
        msg.append("\r\n.\r\n");

        sendSmtpCmd(out, msg.toString());
        line = reader.readLine();
        if (line == null || !line.startsWith("250")) {
            throw new Exception("Email dispatch failed: " + line);
        }

        sendSmtpCmd(out, "QUIT");
        try { socket.close(); } catch(Exception ignore) {}
        return true;
    }

    /* BACKEND EMAIL NOTIFICATION SERVICE */
    public static boolean sendEmailNotification(String toEmail, String subject, String bodyHtml, String emailType) {
        if(toEmail == null || toEmail.trim().isEmpty()) return false;
        toEmail = toEmail.trim();

        String smtpHost = getSmtpConfig("SMTP_HOST");
        String smtpPort = getSmtpConfig("SMTP_PORT");
        String smtpUser = getSmtpConfig("SMTP_USER");
        String smtpPass = getSmtpConfig("SMTP_PASSWORD");
        String smtpFrom = getSmtpConfig("SMTP_FROM");
        if(smtpFrom == null || smtpFrom.isEmpty()) smtpFrom = (smtpUser != null && !smtpUser.isEmpty()) ? smtpUser : "no-reply@zkitchen.com";
        if(smtpPort == null || smtpPort.isEmpty()) smtpPort = "587";

        boolean sent = false;
        String err = null;

        if(smtpHost != null && !smtpHost.isEmpty() && smtpUser != null && !smtpUser.isEmpty() && smtpPass != null && !smtpPass.isEmpty()) {
            try {
                // Primary: Try Native Java Socket SMTP Client
                sent = sendNativeSmtpEmail(smtpHost, Integer.parseInt(smtpPort), smtpUser, smtpPass, smtpFrom, toEmail, subject, bodyHtml);
            } catch(Exception socketEx) {
                // Secondary Fallback: Try JavaMail Reflection if javax.mail is present
                try {
                    Class<?> sessionClass = Class.forName("javax.mail.Session");
                    Class<?> mimeMessageClass = Class.forName("javax.mail.internet.MimeMessage");
                    Class<?> internetAddressClass = Class.forName("javax.mail.internet.InternetAddress");
                    Class<?> recipientTypeClass = Class.forName("javax.mail.Message$RecipientType");
                    Class<?> transportClass = Class.forName("javax.mail.Transport");
                    Class<?> addressClass = Class.forName("javax.mail.Address");
                    Class<?> addressArrayClass = Class.forName("[Ljavax.mail.Address;");
                    Class<?> messageClass = Class.forName("javax.mail.Message");

                    Properties props = new Properties();
                    props.put("mail.smtp.host", smtpHost);
                    props.put("mail.smtp.port", smtpPort);
                    props.put("mail.smtp.auth", "true");
                    props.put("mail.smtp.starttls.enable", "true");

                    Object mailSession = sessionClass.getMethod("getInstance", Properties.class).invoke(null, props);
                    Object message = mimeMessageClass.getConstructor(sessionClass).newInstance(mailSession);

                    Object fromAddr = internetAddressClass.getConstructor(String.class, String.class).newInstance(smtpFrom, "Z Kitchen Support");
                    mimeMessageClass.getMethod("setFrom", addressClass).invoke(message, fromAddr);

                    Object toAddrs = internetAddressClass.getMethod("parse", String.class).invoke(null, toEmail);
                    Object toType = recipientTypeClass.getField("TO").get(null);
                    mimeMessageClass.getMethod("setRecipients", recipientTypeClass, addressArrayClass).invoke(message, toType, toAddrs);

                    mimeMessageClass.getMethod("setSubject", String.class).invoke(message, subject);
                    mimeMessageClass.getMethod("setContent", Object.class, String.class).invoke(message, bodyHtml, "text/html; charset=utf-8");

                    Object transport = sessionClass.getMethod("getTransport", String.class).invoke(mailSession, "smtp");
                    transportClass.getMethod("connect", String.class, int.class, String.class, String.class).invoke(transport, smtpHost, Integer.parseInt(smtpPort), smtpUser, smtpPass);
                    Object allRecipients = messageClass.getMethod("getAllRecipients").invoke(message);
                    transportClass.getMethod("sendMessage", messageClass, addressArrayClass).invoke(transport, message, allRecipients);
                    transportClass.getMethod("close").invoke(transport);
                    sent = true;
                } catch(Throwable t) {
                    err = socketEx.getMessage();
                }
            }
        } else {
            err = "SMTP credentials (SMTP_HOST, SMTP_USER, SMTP_PASSWORD) not configured in environment or WEB-INF/.env file.";
        }

        // Log email dispatch status to database table email_logs
        try {
            Connection con = getDbConnection();
            if(con != null) {
                PreparedStatement ps = con.prepareStatement("INSERT INTO email_logs(recipient_email, subject, email_type, status, error_message) VALUES(?, ?, ?, ?, ?)");
                ps.setString(1, toEmail);
                ps.setString(2, subject);
                ps.setString(3, emailType);
                ps.setString(4, sent ? "SENT" : "FAILED");
                ps.setString(5, err);
                ps.executeUpdate();
                ps.close();
                con.close();
            }
        } catch(Exception ignore) {}

        return sent;
    }

    /* PROFESSIONAL OTP EMAIL SERVICE */
    public static boolean sendOtpEmail(String toEmail, String customerName, String rawOtp) {
        if(toEmail == null || toEmail.trim().isEmpty() || rawOtp == null) return false;
        if(customerName == null || customerName.trim().isEmpty()) customerName = "Customer";

        String subject = "Your Food Website Verification OTP — Z Kitchen";
        String bodyHtml = "<div style='font-family:Arial,sans-serif; max-width:600px; margin:0 auto; padding:24px; border:1px solid #e2e8f0; border-radius:16px; background:#ffffff;'>"
            + "<div style='text-align:center; margin-bottom:20px;'>"
            + "  <h2 style='color:#ff385c; margin:0; font-size:28px;'>Z Kitchen</h2>"
            + "  <p style='color:#64748b; font-size:14px; margin-top:4px;'>Food Ordering & Delivery Service</p>"
            + "</div>"
            + "<div style='background:#f8fafc; padding:24px; border-radius:12px; border:1px solid #cbd5e1; text-align:center;'>"
            + "  <h3 style='color:#0f172a; margin-top:0;'>Verification OTP Code</h3>"
            + "  <p style='color:#475569; font-size:15px;'>Hello <strong>" + sanitizeHtml(customerName) + "</strong>,</p>"
            + "  <p style='color:#475569; font-size:15px;'>Your OTP code for completing registration / sign-in is:</p>"
            + "  <div style='font-size:36px; font-weight:800; letter-spacing:8px; color:#ff385c; background:#ffffff; padding:16px 24px; border-radius:10px; display:inline-block; margin:16px 0; border:2px dashed #ff385c;'>" + rawOtp + "</div>"
            + "  <p style='color:#64748b; font-size:13px; margin-bottom:0;'>This OTP is valid for <strong>10 minutes</strong>. For your security, do not share this code with anyone.</p>"
            + "</div>"
            + "<p style='font-size:12px; color:#94a3b8; text-align:center; margin-top:24px;'>If you did not request this verification code, please ignore this email.<br>&copy; 2026 Z Kitchen. All rights reserved.</p>"
            + "</div>";

        return sendEmailNotification(toEmail.trim(), subject, bodyHtml, "OTP_VERIFICATION");
    }

    /* SMS NOTIFICATION SERVICE FOR PHONE OTP (TWILIO & FAST2SMS SUPPORT) */
    public static boolean sendSmsNotification(String phoneNumber, String messageText) {
        if(phoneNumber == null || phoneNumber.trim().isEmpty()) return false;
        phoneNumber = phoneNumber.trim();

        String smsProvider = getSmtpConfig("SMS_PROVIDER");
        String apiKey = getSmtpConfig("SMS_API_KEY");
        String sid = getSmtpConfig("TWILIO_ACCOUNT_SID");
        String token = getSmtpConfig("TWILIO_AUTH_TOKEN");
        String fromNum = getSmtpConfig("TWILIO_PHONE_NUMBER");

        boolean sent = false;
        String err = null;

        if("TWILIO".equalsIgnoreCase(smsProvider) && sid != null && !sid.isEmpty() && token != null && !token.isEmpty() && fromNum != null && !fromNum.isEmpty()) {
            try {
                String urlStr = "https://api.twilio.com/2010-04-01/Accounts/" + sid + "/Messages.json";
                URL url = new URL(urlStr);
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("POST");
                String auth = sid + ":" + token;
                String encodedAuth = Base64.getEncoder().encodeToString(auth.getBytes("UTF-8"));
                conn.setRequestProperty("Authorization", "Basic " + encodedAuth);
                conn.setDoOutput(true);

                String data = "To=" + java.net.URLEncoder.encode(phoneNumber, "UTF-8")
                            + "&From=" + java.net.URLEncoder.encode(fromNum, "UTF-8")
                            + "&Body=" + java.net.URLEncoder.encode(messageText, "UTF-8");

                OutputStream os = conn.getOutputStream();
                os.write(data.getBytes("UTF-8"));
                os.flush();
                os.close();

                int code = conn.getResponseCode();
                if(code >= 200 && code < 300) {
                    sent = true;
                } else {
                    BufferedReader br = new BufferedReader(new InputStreamReader(conn.getErrorStream() != null ? conn.getErrorStream() : conn.getInputStream(), "UTF-8"));
                    StringBuilder errSb = new StringBuilder();
                    String errLine;
                    while((errLine = br.readLine()) != null) errSb.append(errLine);
                    br.close();
                    err = "Twilio SMS Failed (HTTP " + code + "): " + errSb.toString();
                }
            } catch(Exception ex) {
                err = "Twilio Connection Error: " + ex.getMessage();
            }
        } else if("FAST2SMS".equalsIgnoreCase(smsProvider) && apiKey != null && !apiKey.isEmpty()) {
            try {
                String cleanPhone = phoneNumber.replaceAll("[^0-9]", "");
                if(cleanPhone.length() > 10) cleanPhone = cleanPhone.substring(cleanPhone.length() - 10);
                String urlStr = "https://www.fast2sms.com/dev/bulkV2?authorization=" + java.net.URLEncoder.encode(apiKey, "UTF-8")
                            + "&route=otp&variables_values=" + java.net.URLEncoder.encode(messageText, "UTF-8")
                            + "&numbers=" + java.net.URLEncoder.encode(cleanPhone, "UTF-8");
                URL url = new URL(urlStr);
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("GET");
                int code = conn.getResponseCode();
                if(code >= 200 && code < 300) {
                    sent = true;
                } else {
                    err = "Fast2SMS Error (HTTP " + code + ")";
                }
            } catch(Exception ex) {
                err = "Fast2SMS Error: " + ex.getMessage();
            }
        } else {
            err = "SMS Provider credentials (SMS_PROVIDER, TWILIO_ACCOUNT_SID or FAST2SMS API Key) not configured in environment or WEB-INF/.env file.";
        }

        // Log SMS dispatch status to database table sms_logs
        try {
            Connection con = getDbConnection();
            if(con != null) {
                PreparedStatement ps = con.prepareStatement("INSERT INTO sms_logs(recipient_phone, message_text, status, error_message) VALUES(?, ?, ?, ?)");
                ps.setString(1, phoneNumber);
                ps.setString(2, messageText);
                ps.setString(3, sent ? "SENT" : "FAILED");
                ps.setString(4, err);
                ps.executeUpdate();
                ps.close();
                con.close();
            }
        } catch(Exception ignore) {}

        return sent;
    }

    public static boolean sendSmsOtp(String phoneNumber, String customerName, String rawOtp) {
        if(phoneNumber == null || phoneNumber.trim().isEmpty() || rawOtp == null) return false;
        String message = "Your Z Kitchen verification OTP code is: " + rawOtp + ". Valid for 10 minutes.";
        return sendSmsNotification(phoneNumber.trim(), message);
    }

    public static void sendRegistrationEmail(String toEmail, String customerName, int userId) {
        if(toEmail == null || toEmail.trim().isEmpty()) return;
        String appUrl = getSmtpConfig("APP_URL");
        if(appUrl == null || appUrl.trim().isEmpty()) appUrl = "http://localhost:8080/Daynemic_web";
        if(appUrl.endsWith("/")) appUrl = appUrl.substring(0, appUrl.length() - 1);

        String subject = "Welcome to Z Kitchen! Your Registration is Confirmed";
        String bodyHtml = "<div style='font-family:Arial,sans-serif; padding:20px; color:#333;'>"
            + "<h2 style='color:#ff385c;'>Registration Confirmation — Z Kitchen</h2>"
            + "<p>Dear <strong>" + customerName + "</strong>,</p>"
            + "<p>Thank you for registering with <strong>Z Kitchen Food Ordering System</strong>! Your account has been created successfully.</p>"
            + "<div style='background:#f8fafc; padding:15px; border-radius:8px; border:1px solid #e2e8f0; margin:15px 0;'>"
            + "  <p style='margin:5px 0;'><strong>Customer Name:</strong> " + customerName + "</p>"
            + "  <p style='margin:5px 0;'><strong>User ID:</strong> #" + userId + "</p>"
            + "  <p style='margin:5px 0;'><strong>Registered Email:</strong> " + toEmail + "</p>"
            + "  <p style='margin:5px 0;'><strong>Status:</strong> Registration Verified</p>"
            + "</div>"
            + "<h3>Login Instructions:</h3>"
            + "<p>You can sign in to your account anytime at <a href='" + appUrl + "/login.jsp' style='color:#ff385c;'>Z Kitchen Login</a> using your registered email/phone and password, followed by 2-step OTP verification.</p>"
            + "<p style='font-size:12px; color:#64748b; margin-top:20px;'>Security Note: Z Kitchen will never ask for your password via email. Please keep your credentials secure.</p>"
            + "</div>";

        sendEmailNotification(toEmail, subject, bodyHtml, "REGISTRATION_CONFIRMATION");
    }

    public static void sendOrderConfirmationEmail(String toEmail, String customerName, int orderId, String items, String totalAmount, String deliveryAddress, String paymentMethod, String paymentStatus) {
        if(toEmail == null || toEmail.trim().isEmpty()) return;
        if(paymentMethod == null || paymentMethod.isEmpty()) paymentMethod = "Cash on Delivery";
        if(paymentStatus == null || paymentStatus.isEmpty()) paymentStatus = "PENDING";

        String subject = "Order Confirmed #" + orderId + " — Z Kitchen";
        String statusColor = "PAID".equalsIgnoreCase(paymentStatus) ? "#16a34a" : "#d97706";

        String bodyHtml = "<div style='font-family:Arial,sans-serif; padding:20px; color:#333;'>"
            + "<h2 style='color:#16a34a;'>Order Confirmed! 🎉</h2>"
            + "<p>Dear <strong>" + customerName + "</strong>,</p>"
            + "<p>Your food order has been placed successfully and is now being prepared by our kitchen team!</p>"
            + "<div style='background:#f8fafc; padding:15px; border-radius:8px; border:1px solid #e2e8f0; margin:15px 0;'>"
            + "  <p style='margin:5px 0;'><strong>Order ID:</strong> #ORD-" + orderId + "</p>"
            + "  <p style='margin:5px 0;'><strong>Items Ordered:</strong> " + items + "</p>"
            + "  <p style='margin:5px 0;'><strong>Total Amount:</strong> &#8377; " + totalAmount + "</p>"
            + "  <p style='margin:5px 0;'><strong>Payment Method:</strong> " + paymentMethod + "</p>"
            + "  <p style='margin:5px 0;'><strong>Payment Status:</strong> <span style='color:" + statusColor + "; font-weight:bold;'>" + paymentStatus + "</span></p>"
            + "  <p style='margin:5px 0;'><strong>Delivery Address:</strong> " + deliveryAddress + "</p>"
            + "  <p style='margin:5px 0;'><strong>Order Status:</strong> <span style='color:#16a34a; font-weight:bold;'>Order Confirmed</span></p>"
            + "</div>"
            + "<p>We will notify you once your order is out for delivery. Thank you for choosing Z Kitchen!</p>"
            + "</div>";

        sendEmailNotification(toEmail, subject, bodyHtml, "ORDER_CONFIRMATION");
    }

    public static void sendOrderConfirmationEmail(String toEmail, String customerName, int orderId, String items, String totalAmount, String deliveryAddress) {
        sendOrderConfirmationEmail(toEmail, customerName, orderId, items, totalAmount, deliveryAddress, "Cash on Delivery", "PENDING");
    }

    public static void sendOrderDeliveredEmail(String toEmail, String customerName, int orderId, String totalAmount, String deliveryAddress) {
        if(toEmail == null || toEmail.trim().isEmpty()) return;
        String appUrl = getSmtpConfig("APP_URL");
        if(appUrl == null || appUrl.trim().isEmpty()) appUrl = "http://localhost:8080/Daynemic_web";
        if(appUrl.endsWith("/")) appUrl = appUrl.substring(0, appUrl.length() - 1);

        String subject = "Order Delivered #" + orderId + " — Z Kitchen";
        String bodyHtml = "<div style='font-family:Arial,sans-serif; padding:20px; color:#333;'>"
            + "<h2 style='color:#2563eb;'>Order Delivered Successfully! 🛵</h2>"
            + "<p>Dear <strong>" + customerName + "</strong>,</p>"
            + "<p>Your food order <strong>#ORD-" + orderId + "</strong> has been successfully delivered to your address!</p>"
            + "<div style='background:#f8fafc; padding:15px; border-radius:8px; border:1px solid #e2e8f0; margin:15px 0;'>"
            + "  <p style='margin:5px 0;'><strong>Order ID:</strong> #ORD-" + orderId + "</p>"
            + "  <p style='margin:5px 0;'><strong>Final Amount:</strong> &#8377; " + totalAmount + "</p>"
            + "  <p style='margin:5px 0;'><strong>Delivery Address:</strong> " + deliveryAddress + "</p>"
            + "  <p style='margin:5px 0;'><strong>Status:</strong> <span style='color:#2563eb; font-weight:bold;'>Delivered</span></p>"
            + "</div>"
            + "<p>We hope you enjoy your meal! Please take a moment to leave us a review on <a href='" + appUrl + "/Reviews.jsp' style='color:#ff385c;'>Z Kitchen Reviews</a>.</p>"
            + "</div>";

        sendEmailNotification(toEmail, subject, bodyHtml, "ORDER_DELIVERED");
    }

    public static synchronized Connection getDbConnection() {
        try {
            if(!resourcesAutoCopied) {
                try {
                    String path1 = "c:/Program Files/Apache Software Foundation/Tomcat 9.0/webapps/Daynemic_web";
                    String path2 = "c:/xampp/tomcat/webapps/Daynemic_web";

                    // Copy Driver JAR
                    File srcJar = new File(path1, "mysql-connector-java-5.1.49.jar");
                    if(!srcJar.exists()) srcJar = new File(path2, "mysql-connector-java-5.1.49.jar");

                    if(srcJar.exists()) {
                        String[] targets = {
                            path1 + "/WEB-INF/lib/mysql-connector-java-5.1.49.jar",
                            path2 + "/WEB-INF/lib/mysql-connector-java-5.1.49.jar",
                            "c:/Program Files/Apache Software Foundation/Tomcat 9.0/lib/mysql-connector-java-5.1.49.jar",
                            "c:/xampp/tomcat/lib/mysql-connector-java-5.1.49.jar"
                        };
                        for(String t : targets) {
                            File f = new File(t);
                            if(!f.exists()) {
                                f.getParentFile().mkdirs();
                                Files.copy(srcJar.toPath(), f.toPath(), StandardCopyOption.REPLACE_EXISTING);
                            }
                        }
                    }

                    // Copy Product Images
                    File srcImgDir = new File(path1, "images");
                    File destImgDir = new File(path2, "images");
                    if(srcImgDir.exists() && srcImgDir.isDirectory()) {
                        destImgDir.mkdirs();
                        File[] imgFiles = srcImgDir.listFiles();
                        if(imgFiles != null) {
                            for(File img : imgFiles) {
                                if(img.isFile()) {
                                    File destImg = new File(destImgDir, img.getName());
                                    if(!destImg.exists()) {
                                        Files.copy(img.toPath(), destImg.toPath(), StandardCopyOption.REPLACE_EXISTING);
                                    }
                                }
                            }
                        }
                    }
                } catch(Throwable ignore) {}
                resourcesAutoCopied = true;
            }

            // Driver Registration
            try {
                Driver driver = (Driver) Class.forName("com.mysql.jdbc.Driver").getDeclaredConstructor().newInstance();
                DriverManager.registerDriver(new DriverShim(driver));
            } catch (Throwable t1) {
                try {
                    Driver driver = (Driver) Class.forName("com.mysql.cj.jdbc.Driver").getDeclaredConstructor().newInstance();
                    DriverManager.registerDriver(new DriverShim(driver));
                } catch (Throwable t2) {
                    String[] searchPaths = {
                        "c:/xampp/tomcat/webapps/Daynemic_web/mysql-connector-java-5.1.49.jar",
                        "c:/Program Files/Apache Software Foundation/Tomcat 9.0/webapps/Daynemic_web/mysql-connector-java-5.1.49.jar",
                        "c:/xampp/tomcat/webapps/Daynemic_web/WEB-INF/lib/mysql-connector-java-5.1.49.jar"
                    };

                    for(String p : searchPaths) {
                        File jarFile = new File(p);
                        if(jarFile.exists()) {
                            try {
                                URLClassLoader ucl = new URLClassLoader(new URL[]{ jarFile.toURI().toURL() }, Thread.currentThread().getContextClassLoader());
                                Class<?> driverClass = Class.forName("com.mysql.jdbc.Driver", true, ucl);
                                Driver d = (Driver) driverClass.getDeclaredConstructor().newInstance();
                                DriverManager.registerDriver(new DriverShim(d));
                                break;
                            } catch(Throwable ex) {}
                        }
                    }
                }
             String dbHost = getSmtpConfig("DB_HOST");
            String dbPort = getSmtpConfig("DB_PORT");
            String dbName = getSmtpConfig("DB_NAME");
            String dbUser = getSmtpConfig("DB_USER");
            String dbPass = getSmtpConfig("DB_PASSWORD");

            Connection conn = null;

            if(dbHost != null && !dbHost.trim().isEmpty()) {
                if(dbPort == null || dbPort.isEmpty()) dbPort = "3306";
                if(dbName == null || dbName.isEmpty()) dbName = "food";
                String cloudUrl = "jdbc:mysql://" + dbHost + ":" + dbPort + "/" + dbName + "?useUnicode=true&characterEncoding=UTF-8&connectTimeout=3000&socketTimeout=3000&allowPublicKeyRetrieval=true&useSSL=false&createDatabaseIfNotExist=true";
                try {
                    conn = DriverManager.getConnection(cloudUrl, dbUser != null ? dbUser : "root", dbPass != null ? dbPass : "");
                    if(conn != null) lastDbError = null;
                } catch(SQLException sqle) {
                    lastDbError = sqle.getMessage();
                }
            }

            String url = "jdbc:mysql://localhost:3306/food?useUnicode=true&characterEncoding=UTF-8&connectTimeout=1000&socketTimeout=1000&allowPublicKeyRetrieval=true&useSSL=false&createDatabaseIfNotExist=true";
            
            if(conn == null && cachedDbPassword != null) {
                try {
                    conn = DriverManager.getConnection(url, "root", cachedDbPassword);
                    lastDbError = null;
                } catch(SQLException sqle) {
                    cachedDbPassword = null;
                }
            }

            if(conn == null) {
                String[] passwords = {"", "root", "1234", "123456", "admin"};
                for(String pass : passwords) {
                    try {
                        conn = DriverManager.getConnection(url, "root", pass);
                        cachedDbPassword = pass;
                        lastDbError = null;
                        break;
                    } catch(SQLException sqle) {
                        lastDbError = sqle.getMessage();
                    }
                }
            }

            setSecurityHeaders(response);
            if(conn != null) {
                if(!dbTablesUpgraded) {
                    try {
                        Statement st = conn.createStatement();
                        // Auto Create & Upgrade Tables
                        st.executeUpdate("CREATE TABLE IF NOT EXISTS users (user_id INT AUTO_INCREMENT PRIMARY KEY, full_name VARCHAR(100) NOT NULL, email VARCHAR(100) UNIQUE, phone_number VARCHAR(30) UNIQUE, password_hash VARCHAR(255), google_id VARCHAR(100), registration_method VARCHAR(20) DEFAULT 'EMAIL', role VARCHAR(20) DEFAULT 'CUSTOMER', email_verified TINYINT(1) DEFAULT 0, phone_verified TINYINT(1) DEFAULT 0, account_status VARCHAR(20) DEFAULT 'ACTIVE', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, last_login TIMESTAMP NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
                        
                        st.executeUpdate("CREATE TABLE IF NOT EXISTS user_otps (id INT AUTO_INCREMENT PRIMARY KEY, user_identifier VARCHAR(100) NOT NULL, user_id INT DEFAULT NULL, otp_code VARCHAR(100) NOT NULL, otp_type VARCHAR(20) DEFAULT 'REGISTRATION', expires_at TIMESTAMP NOT NULL, attempts INT DEFAULT 0, verified TINYINT(1) DEFAULT 0, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
                        
                        st.executeUpdate("CREATE TABLE IF NOT EXISTS login_activity (login_id INT AUTO_INCREMENT PRIMARY KEY, user_id INT DEFAULT NULL, user_identifier VARCHAR(100) NOT NULL, login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP, otp_verified TINYINT(1) DEFAULT 0, login_status VARCHAR(30) DEFAULT 'PENDING_OTP', logout_time TIMESTAMP NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
                        
                        st.executeUpdate("CREATE TABLE IF NOT EXISTS user_addresses (id INT AUTO_INCREMENT PRIMARY KEY, user_id INT NOT NULL, address_line TEXT NOT NULL, city VARCHAR(50) NOT NULL, pincode VARCHAR(20) NOT NULL, is_default TINYINT(1) DEFAULT 1, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
                        
                        st.executeUpdate("CREATE TABLE IF NOT EXISTS orfood (id INT AUTO_INCREMENT PRIMARY KEY, user_id INT DEFAULT NULL, nm VARCHAR(255) NOT NULL, rs VARCHAR(100) NOT NULL, cname VARCHAR(100) NOT NULL, email VARCHAR(100) NOT NULL, monumber VARCHAR(100) NOT NULL, comm TEXT NOT NULL, order_status VARCHAR(50) DEFAULT 'Pending', subtotal VARCHAR(50) DEFAULT NULL, delivery_charge VARCHAR(50) DEFAULT NULL, latitude VARCHAR(50) DEFAULT NULL, longitude VARCHAR(50) DEFAULT NULL, house_building VARCHAR(255) DEFAULT NULL, street_area VARCHAR(255) DEFAULT NULL, city VARCHAR(100) DEFAULT NULL, state VARCHAR(100) DEFAULT NULL, pincode VARCHAR(20) DEFAULT NULL, delivered_email_sent TINYINT(1) DEFAULT 0, order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
                        
                        st.executeUpdate("CREATE TABLE IF NOT EXISTS contact (id INT AUTO_INCREMENT PRIMARY KEY, nam VARCHAR(100) NOT NULL, email VARCHAR(100) NOT NULL, number VARCHAR(50) NOT NULL, comment TEXT NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
                        
                        st.executeUpdate("CREATE TABLE IF NOT EXISTS products (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100) NOT NULL, price INT NOT NULL, category VARCHAR(50) DEFAULT 'Fast Food', rating DECIMAL(2,1) DEFAULT 4.5, image VARCHAR(200) DEFAULT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
                        
                        st.executeUpdate("CREATE TABLE IF NOT EXISTS reviews (id INT AUTO_INCREMENT PRIMARY KEY, user_id INT DEFAULT NULL, order_id INT DEFAULT NULL, name VARCHAR(100) NOT NULL, rating INT NOT NULL DEFAULT 5, comment TEXT NOT NULL, status VARCHAR(20) DEFAULT 'APPROVED', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

                        st.executeUpdate("CREATE TABLE IF NOT EXISTS order_status_history (history_id INT AUTO_INCREMENT PRIMARY KEY, order_id INT NOT NULL, old_status VARCHAR(50), new_status VARCHAR(50) NOT NULL, changed_by VARCHAR(100) DEFAULT 'ADMIN', changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

                        st.executeUpdate("CREATE TABLE IF NOT EXISTS email_logs (log_id INT AUTO_INCREMENT PRIMARY KEY, recipient_email VARCHAR(100) NOT NULL, subject VARCHAR(255) NOT NULL, email_type VARCHAR(50) NOT NULL, status VARCHAR(20) NOT NULL, error_message TEXT, sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

                        st.executeUpdate("CREATE TABLE IF NOT EXISTS sms_logs (log_id INT AUTO_INCREMENT PRIMARY KEY, recipient_phone VARCHAR(50) NOT NULL, message_text TEXT NOT NULL, status VARCHAR(20) NOT NULL, error_message TEXT, sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

                        // SAFELY ALTER EXISTING TABLES FOR MISSING COLUMNS
                        try { st.executeUpdate("ALTER TABLE users CHANGE COLUMN id user_id INT AUTO_INCREMENT"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE users ADD COLUMN user_id INT"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE users ADD COLUMN full_name VARCHAR(100)"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE users ADD COLUMN phone_number VARCHAR(30)"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE users ADD COLUMN password_hash VARCHAR(255)"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE users ADD COLUMN google_id VARCHAR(100)"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE users ADD COLUMN registration_method VARCHAR(20) DEFAULT 'EMAIL'"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE users ADD COLUMN role VARCHAR(20) DEFAULT 'CUSTOMER'"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE users ADD COLUMN email_verified TINYINT(1) DEFAULT 0"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE users ADD COLUMN phone_verified TINYINT(1) DEFAULT 0"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE users ADD COLUMN account_status VARCHAR(20) DEFAULT 'ACTIVE'"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE users ADD COLUMN last_login TIMESTAMP NULL"); } catch(Exception ignore){}

                        try { st.executeUpdate("ALTER TABLE user_otps ADD COLUMN user_id INT DEFAULT NULL"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE user_otps ADD COLUMN otp_type VARCHAR(20) DEFAULT 'REGISTRATION'"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE user_otps ADD COLUMN attempts INT DEFAULT 0"); } catch(Exception ignore){}

                        try { st.executeUpdate("ALTER TABLE orfood ADD COLUMN user_id INT DEFAULT NULL"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE orfood ADD COLUMN order_status VARCHAR(50) DEFAULT 'Pending'"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE orfood ADD COLUMN subtotal VARCHAR(50)"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE orfood ADD COLUMN delivery_charge VARCHAR(50)"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE orfood ADD COLUMN latitude VARCHAR(50)"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE orfood ADD COLUMN longitude VARCHAR(50)"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE orfood ADD COLUMN house_building VARCHAR(255)"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE orfood ADD COLUMN street_area VARCHAR(255)"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE orfood ADD COLUMN city VARCHAR(100)"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE orfood ADD COLUMN state VARCHAR(100)"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE orfood ADD COLUMN pincode VARCHAR(20)"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE orfood ADD COLUMN delivered_email_sent TINYINT(1) DEFAULT 0"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE orfood ADD COLUMN payment_method VARCHAR(50) DEFAULT 'Cash on Delivery'"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE orfood ADD COLUMN payment_status VARCHAR(50) DEFAULT 'PENDING'"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE orfood ADD COLUMN razorpay_order_id VARCHAR(100)"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE orfood ADD COLUMN razorpay_payment_id VARCHAR(100)"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE orfood ADD COLUMN payment_verified_at TIMESTAMP NULL"); } catch(Exception ignore){}
                        try { st.executeUpdate("UPDATE orfood SET payment_status = 'PENDING' WHERE payment_status IS NULL OR payment_status = '' OR payment_status = 'null'"); } catch(Exception ignore){}
                        try { st.executeUpdate("UPDATE orfood SET payment_status = 'COMPLETED' WHERE payment_status = 'PAID'"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE reviews ADD COLUMN order_id INT DEFAULT NULL"); } catch(Exception ignore){}
                        try { st.executeUpdate("ALTER TABLE reviews ADD COLUMN status VARCHAR(20) DEFAULT 'APPROVED'"); } catch(Exception ignore){}
                        try { st.executeUpdate("DELETE FROM reviews WHERE comment LIKE '%jsdadn%' OR LOWER(comment) LIKE '%test%'"); } catch(Exception ignore){}

                        st.close();
                        dbTablesUpgraded = true;
                    } catch(Exception ignore) {}
                }
                return conn;
            }

            if(lastDbError == null) {
                lastDbError = "MySQL is not running on localhost:3306. Please start MySQL service in XAMPP!";
            }
            return null;
        } catch(Throwable e) {
            lastDbError = "JDBC Error: " + (e.getMessage() != null ? e.getMessage() : e.toString());
            return null;
        }
    }
%>
