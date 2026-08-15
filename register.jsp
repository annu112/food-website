<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Account - Z Kitchen</title>
    
    <!-- STYLE CSS LINK -->
    <link rel="stylesheet" href="style.css">
    <!-- BOOTSTRAP CDN LINK -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FONT AWESOME CDN -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <!-- GOOGLE SIGN IN SDK -->
    <script src="https://accounts.google.com/gsi/client" async defer></script>

    <style>
      .auth-card {
        background: #ffffff;
        border-radius: 24px;
        padding: 40px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 20px 40px rgba(15, 23, 42, 0.08);
      }
      .auth-tab-btn {
        border: none;
        background: #f1f5f9;
        color: #64748b;
        font-weight: 700;
        padding: 12px 24px;
        border-radius: 30px;
        transition: all 0.3s ease;
      }
      .auth-tab-btn.active {
        background: #ff385c;
        color: #ffffff;
        box-shadow: 0 6px 18px rgba(255, 56, 92, 0.3);
      }
      .form-control-auth {
        border-radius: 12px;
        padding: 12px 18px;
        border: 1px solid #cbd5e1;
        font-size: 15px;
      }
      .form-control-auth:focus {
        border-color: #ff385c;
        box-shadow: 0 0 0 4px rgba(255, 56, 92, 0.12);
      }
      .google-btn-container {
        display: flex;
        justify-content: center;
        margin-bottom: 20px;
      }
      .field-error-msg {
        color: #dc2626;
        font-size: 13px;
        font-weight: 600;
        margin-top: 4px;
        display: none;
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
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#mynavbar">
      <span><i class="fa-solid fa-bars text-dark fs-4"></i></span>
    </button>
    <div class="collapse navbar-collapse" id="mynavbar">
      <ul class="navbar-nav ms-auto align-items-center">
        <li class="nav-item"><a href="index.jsp" class="nav-link">Home</a></li>
        <li class="nav-item"><a href="Menu.jsp" class="nav-link">Menu</a></li>
        <li class="nav-item"><a href="Reviews.jsp" class="nav-link">Reviews</a></li>
        <li class="nav-item"><a href="About.jsp" class="nav-link">About</a></li>
        <li class="nav-item"><a href="Contact.jsp" class="nav-link">Contact</a></li>
        <li class="nav-item ms-lg-2"><a href="login.jsp" class="nav-link">Login</a></li>
        <li class="nav-item ms-lg-2"><a href="register.jsp" class="nav-link active">Register</a></li>
      </ul>
    </div>
  </div>
</nav>
<!-- Navbar End -->

<section class="container py-5" style="margin-top: 90px; min-height: 80vh;">
  <div class="row justify-content-center">
    <div class="col-lg-6 col-md-8">
      <div class="auth-card">
        <div class="text-center mb-4">
          <span class="text-danger fw-bold text-uppercase tracking-wider">JOIN Z KITCHEN</span>
          <h2 class="fw-bold mt-1">Create Your Account</h2>
          <p class="text-muted small">Sign up to order delicious food & track live orders!</p>
        </div>

        <%
          String error = request.getParameter("error");
          String redirect = request.getParameter("redirect");
          if(redirect == null) redirect = "";
          if(error != null && !error.isEmpty()) {
        %>
        <div class="alert alert-danger rounded-3 fs-6 p-3 mb-4 d-flex align-items-center gap-2">
          <i class="fa-solid fa-triangle-exclamation text-danger fs-5"></i>
          <div><%= error %></div>
        </div>
        <% } %>

        <!-- A. CONTINUE WITH GOOGLE -->
        <div class="text-center mb-4">
          <div id="g_id_onload"
               data-client_id="YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com"
               data-callback="handleCredentialResponse">
          </div>
          <button type="button" class="btn btn-outline-dark w-100 py-2.5 rounded-3 fw-semibold d-flex align-items-center justify-content-center gap-2" onclick="handleGoogleSignInDemo()">
            <img src="https://www.svgrepo.com/show/475656/google-color.svg" alt="Google" style="width:20px;">
            Continue with Google
          </button>
        </div>

        <div class="d-flex align-items-center my-4">
          <hr class="flex-grow-1">
          <span class="px-3 text-muted small fw-semibold">OR REGISTER WITH</span>
          <hr class="flex-grow-1">
        </div>

        <!-- REGISTRATION METHOD TABS -->
        <div class="d-flex justify-content-center gap-2 mb-4">
          <button type="button" class="auth-tab-btn active" id="tabEmailBtn" onclick="switchTab('email')">
            <i class="fa-solid fa-envelope me-1"></i> Email
          </button>
          <button type="button" class="auth-tab-btn" id="tabPhoneBtn" onclick="switchTab('phone')">
            <i class="fa-solid fa-mobile-screen-button me-1"></i> Phone
          </button>
        </div>

        <!-- B. EMAIL REGISTRATION FORM -->
        <form method="post" action="regprocess.jsp" id="emailRegForm" onsubmit="return validateRegForm('email')">
          <input type="hidden" name="regType" value="email">
          <input type="hidden" name="redirect" value="<%= redirect %>">

          <div class="mb-3">
            <label class="form-label fw-semibold">Full Name *</label>
            <input type="text" name="fullName" id="emailFullName" class="form-control form-control-auth" placeholder="e.g. Rahul Patel" required oninput="validateNameInput(this, 'emailNameError')">
            <div class="field-error-msg" id="emailNameError">Name can contain only alphabets and spaces.</div>
          </div>

          <div class="mb-3">
            <label class="form-label fw-semibold">Email Address *</label>
            <input type="email" name="email" class="form-control form-control-auth" placeholder="name@example.com" required>
          </div>

          <div class="mb-3">
            <label class="form-label fw-semibold">Password *</label>
            <div class="position-relative">
              <input type="password" name="password" id="emailPass" class="form-control form-control-auth pe-5" placeholder="Minimum 6 characters" required minlength="6">
              <i class="fa-solid fa-eye position-absolute top-50 end-0 translate-middle-y me-3 text-muted cursor-pointer" onclick="togglePass('emailPass', this)"></i>
            </div>
          </div>

          <div class="mb-4">
            <label class="form-label fw-semibold">Confirm Password *</label>
            <input type="password" name="confirmPassword" id="emailConfirmPass" class="form-control form-control-auth" placeholder="Re-enter password" required minlength="6">
          </div>

          <button type="submit" class="btn-primary-custom w-100 py-3 fw-bold fs-6">
            Register & Send OTP <i class="fa-solid fa-arrow-right ms-2"></i>
          </button>
        </form>

        <!-- C. PHONE REGISTRATION FORM -->
        <form method="post" action="regprocess.jsp" id="phoneRegForm" style="display:none;" onsubmit="return validateRegForm('phone')">
          <input type="hidden" name="regType" value="phone">
          <input type="hidden" name="redirect" value="<%= redirect %>">

          <div class="mb-3">
            <label class="form-label fw-semibold">Full Name *</label>
            <input type="text" name="fullName" id="phoneFullName" class="form-control form-control-auth" placeholder="e.g. Rahul Patel" required oninput="validateNameInput(this, 'phoneNameError')">
            <div class="field-error-msg" id="phoneNameError">Name can contain only alphabets and spaces.</div>
          </div>

          <div class="mb-3">
            <label class="form-label fw-semibold">Country & Phone Number *</label>
            <div class="input-group">
              <select name="countryCode" class="form-select form-control-auth" style="max-width: 120px;">
                <option value="+91">🇮🇳 +91</option>
                <option value="+1">🇺🇸 +1</option>
                <option value="+44">🇬🇧 +44</option>
                <option value="+971">🇦🇪 +971</option>
                <option value="+61">🇦🇺 +61</option>
              </select>
              <input type="tel" name="phoneNumber" class="form-control form-control-auth" placeholder="9876543210" pattern="[0-9]{7,15}" required>
            </div>
          </div>

          <div class="mb-3">
            <label class="form-label fw-semibold">Password *</label>
            <div class="position-relative">
              <input type="password" name="password" id="phonePass" class="form-control form-control-auth pe-5" placeholder="Minimum 6 characters" required minlength="6">
              <i class="fa-solid fa-eye position-absolute top-50 end-0 translate-middle-y me-3 text-muted cursor-pointer" onclick="togglePass('phonePass', this)"></i>
            </div>
          </div>

          <div class="mb-4">
            <label class="form-label fw-semibold">Confirm Password *</label>
            <input type="password" name="confirmPassword" id="phoneConfirmPass" class="form-control form-control-auth" placeholder="Re-enter password" required minlength="6">
          </div>

          <button type="submit" class="btn-primary-custom w-100 py-3 fw-bold fs-6">
            Register & Send OTP <i class="fa-solid fa-arrow-right ms-2"></i>
          </button>
        </form>

        <div class="text-center mt-4 pt-3 border-top">
          <span class="text-muted">Already have an account?</span>
          <a href="login.jsp<%= redirect != null && !redirect.isEmpty() ? "?redirect=" + redirect : "" %>" class="fw-bold text-danger text-decoration-none ms-1">Sign In Here</a>
        </div>
      </div>
    </div>
  </div>
</section>

<!-- Footer Start -->
<footer id="footer">
  <div class="footer-content">
    <div class="footer-logo"><img src="./images/z kitchen.jpeg" alt="Z Kitchen Logo"></div>
    <p class="text-muted small" style="max-width: 400px;">Serving delicious moments and authentic flavors with passion everyday.</p>
  </div>
  <div class="footer-copyright">
    <span>Designed & Developed By <a href="#">Nai Adil / Anas Munshi</a> &copy; 2026 Z Kitchen</span>
  </div>
</footer>
<!-- Footer End -->

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
  function switchTab(type) {
    const tabEmailBtn = document.getElementById("tabEmailBtn");
    const tabPhoneBtn = document.getElementById("tabPhoneBtn");
    const emailForm = document.getElementById("emailRegForm");
    const phoneForm = document.getElementById("phoneRegForm");

    if(type === 'email') {
      tabEmailBtn.classList.add("active");
      tabPhoneBtn.classList.remove("active");
      emailForm.style.display = "block";
      phoneForm.style.display = "none";
    } else {
      tabPhoneBtn.classList.add("active");
      tabEmailBtn.classList.remove("active");
      phoneForm.style.display = "block";
      emailForm.style.display = "none";
    }
  }

  /* STRICT FRONTEND FULL NAME VALIDATION: Alphabets and spaces only! */
  function validateNameInput(input, errorId) {
    const errorEl = document.getElementById(errorId);
    const regex = /^[A-Za-z]+(?: [A-Za-z]+)*$/;
    
    if(input.value.trim() === "") {
      errorEl.style.display = "none";
      return true;
    }

    if(!regex.test(input.value.trim())) {
      errorEl.style.display = "block";
      input.classList.add("is-invalid");
      return false;
    } else {
      errorEl.style.display = "none";
      input.classList.remove("is-invalid");
      return true;
    }
  }

  function validateRegForm(type) {
    let nameInput = type === 'email' ? document.getElementById("emailFullName") : document.getElementById("phoneFullName");
    let errorId = type === 'email' ? 'emailNameError' : 'phoneNameError';
    let passInput = type === 'email' ? document.getElementById("emailPass") : document.getElementById("phonePass");
    let confirmPassInput = type === 'email' ? document.getElementById("emailConfirmPass") : document.getElementById("phoneConfirmPass");

    // Full name check
    const nameRegex = /^[A-Za-z]+(?: [A-Za-z]+)*$/;
    if(!nameRegex.test(nameInput.value.trim())) {
      alert("Name can contain only alphabets and spaces.");
      document.getElementById(errorId).style.display = "block";
      nameInput.focus();
      return false;
    }

    // Password match check
    if(passInput.value !== confirmPassInput.value) {
      alert("Passwords do not match. Please re-enter.");
      confirmPassInput.focus();
      return false;
    }

    return true;
  }

  function togglePass(id, icon) {
    const el = document.getElementById(id);
    if(el.type === 'password') {
      el.type = 'text';
      icon.classList.replace('fa-eye', 'fa-eye-slash');
    } else {
      el.type = 'password';
      icon.classList.replace('fa-eye-slash', 'fa-eye');
    }
  }

  function handleGoogleSignInDemo() {
    let googleEmail = prompt("Enter your Google Account Email to Sign In/Register:", "rahul.patel@gmail.com");
    if(googleEmail && googleEmail.includes("@")) {
      let fullName = prompt("Enter your Full Name (Alphabets only):", "Rahul Patel");
      if(fullName) {
        window.location = "google_login.jsp?email=" + encodeURIComponent(googleEmail) + "&name=" + encodeURIComponent(fullName) + "&google_id=g_" + Date.now();
      }
    }
  }
</script>
</body>
</html>
