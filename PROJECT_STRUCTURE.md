# 📂 Z Kitchen — Project Structure Documentation

This document describes the directory tree and architectural layout of the **Z Kitchen** web application.

```
Daynemic_web/
├── admin/                     # Admin Management Panel Pages & Assets
│   ├── contect.jsp            # Contact Messages Management
│   ├── customers.jsp          # Customer List View
│   ├── dashbord.jsp           # Admin Analytics Dashboard & Recent Orders
│   ├── index.jsp              # Admin Landing & Redirection
│   ├── login.jsp              # Admin Login Interface
│   ├── login_activity.jsp     # System Audit Log for Logins
│   ├── orders.jsp             # Customer Orders & Payment Status Management
│   ├── products.jsp           # Catalog & Food Product Management
│   ├── reg_activity.jsp        # Registration Audit Logs
│   ├── reviews.jsp           # Customer Reviews Management
│   ├── style.css              # Admin Dashboard Custom CSS
│   └── user_detail.jsp        # Detailed Customer Profile View
│
├── images/                    # Product Images & Branding Assets
│   ├── burger.png
│   ├── butter chicken.jpeg
│   ├── pizza.png
│   └── z kitchen.jpeg
│
├── js/                        # Client-Side JavaScript Files
│   └── main.js                # Cart Management, Multi-Key Persistence, UI Handlers
│
├── WEB-INF/                   # Protected Web Server Configuration & Dependencies
│   ├── .env.example           # Template for Environment Configuration
│   ├── .env                   # Environment Secrets (Ignored by Git)
│   └── lib/                   # Java Libraries (JDBC Drivers, Mail Jars)
│
├── About.jsp                  # About Us Page
├── Contact.jsp                # Customer Contact & Feedback Page
├── Menu.jsp                   # Categorized Food Menu & Item Card Display
├── Order.jsp                  # Checkout Page & COD Delivery Form
├── Reviews.jsp                # Customer Testimonials & Reviews Page
├── dbconnection.jsp           # Central JDBC Connection, Mail Engine & Migration Utilities
├── index.jsp                  # Customer Home Page & Featured Specials
├── login.jsp                  # User Sign-In Page
├── loginprocess.jsp           # Authentication Handler
├── logout.jsp                 # Session Termination Handler
├── my_orders.jsp              # Customer Order History & Live Status Stepper
├── ordprocess.jsp             # Order Insertion & Backend Calculation Servlet
├── profile.jsp                # User Profile Management
├── register.jsp               # New Customer Registration Page
├── regprocess.jsp             # Registration Processing Handler
├── schema.sql                 # Complete MySQL Database DDL Script
├── style.css                  # Customer Portal Stylesheet
├── sync_cart.jsp              # Session-to-Storage Cart Synchronizer
├── verify_otp.jsp             # Email OTP Verification Interface
└── README.md                  # Project Overview & Setup Guide
```
