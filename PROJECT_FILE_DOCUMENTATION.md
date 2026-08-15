# 📜 Z Kitchen — Detailed File Documentation

Detailed documentation of all key files, JSPs, servlets, and scripts in the **Z Kitchen** web application.

---

## 🌐 Customer Pages & Processors

| File Name | Description | Key Functions & Responsibilities |
| :--- | :--- | :--- |
| `index.jsp` | Home Page | Displays hero banner, featured food items, chef recommendations, and navigation bar. |
| `Menu.jsp` | Food Menu | Renders categorized menu items (Starters, Main Course, Fast Food) with search and Add to Cart buttons. |
| `Order.jsp` | Checkout Page | Displays Order Details summary table (items, quantities, subtotals, ₹40 delivery charge) and collects customer delivery address for Cash on Delivery. |
| `ordprocess.jsp` | Order Processor | Server-side script that parses cart items, calculates totals, inserts order into `orfood` table with `payment_method = 'Cash on Delivery'` and `payment_status = 'PENDING'`, clears session cart, and dispatches email confirmations. |
| `my_orders.jsp` | Order History | Displays past & live customer orders with real-time tracking stepper and color-coded payment status badges (`PENDING` = Orange, `COMPLETED` = Green). |
| `dbconnection.jsp` | Database & Core Utilities | Manages MySQL JDBC connection pooling, environment configuration loading (`.env`), password hashing (SHA-256), native socket SMTP client, XSS sanitization, and auto-schema migrations. |
| `login.jsp` / `loginprocess.jsp` | Authentication | Renders user login form and processes authentication credentials against `users` table. |
| `register.jsp` / `regprocess.jsp` | Registration | Handles new user signup, validation, password hashing, and dispatches OTP codes. |
| `verify_otp.jsp` | OTP Verification | Validates 6-digit OTP code before activating user accounts. |
| `profile.jsp` | User Profile | Allows customers to view and edit personal information and default delivery addresses. |

---

## 👑 Admin Panel Pages (`admin/`)

| File Name | Description | Key Functions & Responsibilities |
| :--- | :--- | :--- |
| `admin/dashbord.jsp` | Dashboard Overview | Summarizes total sales, order count, registered customers, inquiry count, and recent 6 orders. |
| `admin/orders.jsp` | Order & Payment Management | Interactive table displaying customer orders, contact information, GPS location, order status dropdown (*Pending, Confirmed, Preparing, Ready, Out for Delivery, Delivered, Cancelled*), and **Mark Payment Completed** action for Cash on Delivery payments. |
| `admin/products.jsp` | Catalog Management | Interface to add, update, or remove food items, prices, categories, and images. |
| `admin/users.jsp` | Customer Management | View registered users, account status, and role assignments. |
| `admin/login_activity.jsp` | Audit Logging | Displays system login activity, timestamps, and IP/OTP verification records. |
| `admin/reviews.jsp` | Review Moderation | View and moderate customer ratings and comments. |

---

## 🎨 Asset Files (`js/`, `images/`, `style.css`)

| Path | Description |
| :--- | :--- |
| `js/main.js` | Core client-side script managing multi-key cart storage (`zk_cart`, `z_kitchen_cart`, `cart`, `cart_items`), badge updates, quantity increment/decrement, and checkout sync. |
| `style.css` | Primary custom CSS stylesheet defining theme colors (Primary Red `#ff385c`, Dark `#0f172a`, Light `#f8fafc`), card shadows, buttons, and animations. |
| `admin/style.css` | Admin dashboard styling for sidebar navigation, data tables, metrics cards, and status badges. |
