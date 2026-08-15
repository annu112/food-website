<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ include file="dbconnection.jsp" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verify OTP - Z Kitchen</title>
    
    <!-- STYLE CSS LINK -->
    <link rel="stylesheet" href="style.css">
    <!-- BOOTSTRAP CDN LINK -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FONT AWESOME CDN -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">

    <style>
      .auth-card {
        background: #ffffff;
        border-radius: 24px;
        padding: 40px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 20px 40px rgba(15, 23, 42, 0.08);
      }
      .otp-box-group {
        display: flex;
        gap: 10px;
        justify-content: center;
        margin: 25px 0;
      }
      .otp-field {
        width: 48px;
        height: 58px;
        text-align: center;
        font-size: 24px;
        font-weight: 800;
        border-radius: 12px;
        border: 2px solid #cbd5e1;
        outline: none;
        transition: all 0.2s ease;
      }
      .otp-field:focus {
        border-color: #ff385c;
        box-shadow: 0 0 0 4px rgba(255, 56, 92, 0.15);
      }
      .demo-otp-banner {
        background: #ecfdf5;
        border: 1px solid #6ee7b7;
        color: #065f46;
        padding: 16px;
        border-radius: 16px;
        margin-bottom: 25px;
        text-align: center;
      }
    </style>
</head>
<body class="bg-light">

<!-- Navbar Start -->
<nav class="navbar navbar-expand-lg" id="navbar">
  <div class="container-fluid">
    <a href="index.jsp" class="navbar-brand" id="logo">
      <img src="./images/z kitchen.jpeg" alt="Z Kitchen Logo">
    </a>
  </div>
</nav>
<!-- Navbar End -->

<%
  String identifier = request.getParameter("identifier");
  String redirect = request.getParameter("redirect");
  String error = request.getParameter("error");
  if(redirect == null) redirect = "";
  if(identifier == null) identifier = "";

  String safeIdentifier = sanitizeHtml(identifier);
  String safeRedirect = sanitizeHtml(redirect);
  String safeError = sanitizeHtml(error);
%>

<section class="container py-5" style="margin-top: 90px; min-height: 80vh;">
  <div class="row justify-content-center">
    <div class="col-lg-5 col-md-7">
      <div class="auth-card">
        <div class="text-center mb-4">
          <div class="mb-3">
            <span class="badge bg-danger p-3 rounded-circle text-white shadow"><i class="fa-solid fa-shield-halved fs-3"></i></span>
          </div>
          <h2 class="fw-bold">OTP Verification</h2>
          <p class="text-muted small">Enter the 6-digit verification code sent to <br><strong class="text-dark"><%= safeIdentifier %></strong></p>
        </div>

        <% if(safeError != null && !safeError.isEmpty()) { %>
        <div class="alert alert-danger rounded-3 fs-6 p-3 mb-4 d-flex align-items-center gap-2">
          <i class="fa-solid fa-triangle-exclamation text-danger fs-5"></i>
          <div><%= safeError %></div>
        </div>
        <% } %>

        <% if("1".equals(request.getParameter("smtpError"))) { %>
        <div class="alert alert-warning rounded-3 fs-6 p-3 mb-4 d-flex align-items-center gap-2">
          <i class="fa-solid fa-envelope-circle-check text-warning fs-5"></i>
          <div><strong>Notice:</strong> Email dispatch failed. Please configure <code>SMTP_USER</code> and <code>SMTP_PASSWORD</code> in <code>WEB-INF/.env</code> for live Gmail delivery.</div>
        </div>
        <% } %>

        <form method="post" action="otpprocess.jsp" onsubmit="return combineOtp()">
          <input type="hidden" name="identifier" value="<%= safeIdentifier %>">
          <input type="hidden" name="redirect" value="<%= safeRedirect %>">
          <input type="hidden" name="otp" id="finalOtpInput">

          <div class="otp-box-group">
            <input type="text" class="otp-field" maxlength="1" pattern="[0-9]" required onkeyup="otpInputKey(this, 1)" id="otp1">
            <input type="text" class="otp-field" maxlength="1" pattern="[0-9]" required onkeyup="otpInputKey(this, 2)" id="otp2">
            <input type="text" class="otp-field" maxlength="1" pattern="[0-9]" required onkeyup="otpInputKey(this, 3)" id="otp3">
            <input type="text" class="otp-field" maxlength="1" pattern="[0-9]" required onkeyup="otpInputKey(this, 4)" id="otp4">
            <input type="text" class="otp-field" maxlength="1" pattern="[0-9]" required onkeyup="otpInputKey(this, 5)" id="otp5">
            <input type="text" class="otp-field" maxlength="1" pattern="[0-9]" required onkeyup="otpInputKey(this, 6)" id="otp6">
          </div>

          <button type="submit" class="btn-primary-custom w-100 py-3 fw-bold fs-6 mb-3">
            Verify & Continue <i class="fa-solid fa-circle-check ms-2"></i>
          </button>
        </form>

        <div class="d-flex justify-content-between align-items-center mt-3 pt-3 border-top">
          <div class="text-muted small">
            Resend code in: <span id="timer" class="fw-bold text-danger">60</span>s
          </div>
          <form method="post" action="resend_otp.jsp" style="margin:0;">
            <input type="hidden" name="identifier" value="<%= identifier %>">
            <input type="hidden" name="redirect" value="<%= redirect %>">
            <button type="submit" id="resendBtn" class="btn btn-link text-danger fw-bold text-decoration-none p-0 small" disabled>
              Resend OTP
            </button>
          </form>
        </div>
      </div>
    </div>
  </div>
</section>

<!-- Footer Start -->
<footer id="footer">
  <div class="footer-content">
    <div class="footer-logo"><img src="./images/z kitchen.jpeg" alt="Z Kitchen Logo"></div>
  </div>
  <div class="footer-copyright">
    <span>Designed & Developed By <a href="#">Nai Adil / Anas Munshi</a> &copy; 2026 Z Kitchen</span>
  </div>
</footer>
<!-- Footer End -->

<script>
  function otpInputKey(el, index) {
    if(el.value.length === 1 && index < 6) {
      document.getElementById('otp' + (index + 1)).focus();
    }
  }

  function combineOtp() {
    let code = "";
    for(let i=1; i<=6; i++) {
      code += document.getElementById('otp' + i).value;
    }
    if(code.length !== 6) {
      alert("Please enter a valid 6-digit OTP code.");
      return false;
    }
    document.getElementById('finalOtpInput').value = code;
    return true;
  }

  // 60-Second Resend Countdown Timer
  let timeLeft = 60;
  const timerEl = document.getElementById("timer");
  const resendBtn = document.getElementById("resendBtn");

  const countdown = setInterval(() => {
    timeLeft--;
    if(timerEl) timerEl.textContent = timeLeft;
    if(timeLeft <= 0) {
      clearInterval(countdown);
      if(timerEl) timerEl.textContent = "0";
      if(resendBtn) resendBtn.removeAttribute("disabled");
    }
  }, 1000);

  window.onload = function() {
    document.getElementById('otp1').focus();
  };
</script>
</body>
</html>
