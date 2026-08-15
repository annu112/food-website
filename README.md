# 🍔 Z Kitchen — Online Food Ordering & Management System

Z Kitchen is a full-featured, responsive dynamic food ordering and web management application built with **Java Server Pages (JSP)**, **Servlets**, **JavaScript**, **Bootstrap 5**, and **MySQL**. It features real-time shopping cart synchronization, email OTP user authentication, interactive menu filtering, order tracking, and a dedicated admin management dashboard.

---

## 🚀 Key Features

### 🛒 Customer Features
- **Dynamic Food Menu**: Categorized menu filtering (Starters, Main Course, Fast Food, Drinks) with real-time search.
- **Interactive Shopping Cart**: Client-side & server-side synchronized cart supporting quantity adjustments, item subtotals, delivery fee calculation, and multi-key storage persistence.
- **Cash on Delivery (COD) Checkout**: Streamlined checkout process requiring customer contact details and delivery location address.
- **Real-Time Order Tracking**: Multi-step live order status stepper (*Placed → Confirmed → Preparing → On the Way → Delivered*).
- **Secure Authentication**: User registration and login with SHA-256 password hashing, email OTP verification, and Google sign-in integration.
- **Customer Reviews**: Rate and review food items and service.

### 👑 Admin Features
- **Admin Dashboard**: Comprehensive overview of total orders, revenue sales, product counts, and customer inquiries.
- **Order Management**: Real-time customer order management with status update controls (*Pending, Confirmed, Preparing, Ready, Out for Delivery, Delivered, Cancelled*).
- **Payment Info Management**: Dedicated Cash on Delivery (COD) payment status tracking with **Mark Payment Completed** action (*PENDING → COMPLETED*).
- **Product & Category Management**: Add, update, and manage food catalog items, prices, and images.
- **Activity & Security Logs**: View user registration logs and login activity records.

---

## 🛠️ Technology Stack

- **Frontend**: HTML5, CSS3, Vanilla JavaScript (ES6+), Bootstrap 5, FontAwesome 6
- **Backend**: JSP (Java Server Pages), Java Servlets, JDBC
- **Database**: MySQL Server (5.7+ / 8.0+)
- **Server**: Apache Tomcat 9.0+
- **Security**: SHA-256 Hashing, PreparedStatements, XSS Sanitization, Session-Based Role Control

---

## 📋 Prerequisites & Local Setup

### 1. Requirements
- **JDK**: Java Development Kit 8 or higher
- **Web Server**: Apache Tomcat 9.0 or XAMPP (with Tomcat & MySQL)
- **Database**: MySQL Server

### 2. Database Configuration
1. Start your MySQL Server (e.g., via XAMPP Control Panel or MySQL Workbench).
2. Create a database named `food`:
   ```sql
   CREATE DATABASE food;
   ```
3. Import the `schema.sql` file provided in the repository:
   ```bash
   mysql -u root -p food < schema.sql
   ```
   *(Note: The application automatically creates and updates required tables on startup if they do not exist).*

### 3. Environment Configuration
1. In `WEB-INF/`, copy `.env.example` to `.env`:
   ```bash
   cp WEB-INF/.env.example WEB-INF/.env
   ```
2. Update `.env` with your local database and SMTP configuration:
   ```env
   # OTP Test Mode (set false for production email dispatch)
   OTP_TEST_MODE=true

   # MySQL Database Configuration
   DB_HOST=localhost
   DB_PORT=3306
   DB_NAME=food
   DB_USER=root
   DB_PASSWORD=

   # Email (SMTP) Configuration
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=587
   SMTP_USER=your-email@gmail.com
   SMTP_PASSWORD=your-16-digit-app-password
   ```

### 4. Running Locally
1. Deploy `Daynemic_web` folder into Apache Tomcat's `webapps/` directory:
   ```
   C:\Program Files\Apache Software Foundation\Tomcat 9.0\webapps\Daynemic_web
   ```
   or XAMPP:
   ```
   C:\xampp\tomcat\webapps\Daynemic_web
   ```
2. Start Apache Tomcat Server.
3. Access the web application in your browser:
   - **Customer Portal**: `http://localhost:8080/Daynemic_web/`
   - **Admin Panel**: `http://localhost:8080/Daynemic_web/admin/dashbord.jsp`

---

## 🔒 Security Best Practices
- Sensitive configuration files (`WEB-INF/.env`) are excluded from Git repository tracking via `.gitignore`.
- Database operations use parameterized `PreparedStatement` queries to eliminate SQL injection risks.
- Admin management endpoints enforce backend role checks (`isAdminSession`).

---

## 📄 License & Attribution
Designed & Developed for **Z Kitchen**. All rights reserved &copy; 2026.
