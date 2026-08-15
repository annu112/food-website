# 🗄️ Z Kitchen — Database Schema Documentation

Database documentation for the **Z Kitchen** MySQL database (`food`).

---

## 📊 Entity Relationship & Table Overview

The database contains 10 core tables automatically created and updated by `dbconnection.jsp`:

1. `users` — Customer & Admin Accounts
2. `orfood` — Customer Food Orders & Delivery Information
3. `products` — Food Menu Catalog
4. `reviews` — Customer Ratings & Comments
5. `user_otps` — Email & Phone OTP Codes
6. `login_activity` — Audit Log for User Logins
7. `user_addresses` — Customer Saved Delivery Addresses
8. `order_status_history` — Audit Log for Order Status Transitions
9. `contact` — Customer Contact Messages & Inquiries
10. `email_logs` — Email Dispatch Log

---

## 🗂️ Table Schema Definitions

### 1. `users` Table
Stores registered customer and administrator accounts.
```sql
CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE,
  phone_number VARCHAR(30) UNIQUE,
  password_hash VARCHAR(255),
  google_id VARCHAR(100),
  registration_method VARCHAR(20) DEFAULT 'EMAIL',
  role VARCHAR(20) DEFAULT 'CUSTOMER',
  email_verified TINYINT(1) DEFAULT 0,
  phone_verified TINYINT(1) DEFAULT 0,
  account_status VARCHAR(20) DEFAULT 'ACTIVE',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  last_login TIMESTAMP NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

### 2. `orfood` Table
Stores customer food orders, delivery location details, and payment status.
```sql
CREATE TABLE orfood (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT DEFAULT NULL,
  nm VARCHAR(255) NOT NULL,            -- Food items summary & quantities
  rs VARCHAR(100) NOT NULL,            -- Total order amount in INR (e.g. 1740)
  cname VARCHAR(100) NOT NULL,         -- Customer full name
  email VARCHAR(100) NOT NULL,         -- Customer email
  monumber VARCHAR(100) NOT NULL,      -- Customer phone number
  comm TEXT NOT NULL,                  -- Delivery address & instructions
  order_status VARCHAR(50) DEFAULT 'Pending', -- Pending, Confirmed, Preparing, Ready, Out for Delivery, Delivered, Cancelled
  subtotal VARCHAR(50) DEFAULT NULL,
  delivery_charge VARCHAR(50) DEFAULT '40',
  latitude VARCHAR(50) DEFAULT NULL,
  longitude VARCHAR(50) DEFAULT NULL,
  house_building VARCHAR(255) DEFAULT NULL,
  street_area VARCHAR(255) DEFAULT NULL,
  city VARCHAR(100) DEFAULT NULL,
  state VARCHAR(100) DEFAULT NULL,
  pincode VARCHAR(20) DEFAULT NULL,
  payment_method VARCHAR(50) DEFAULT 'Cash on Delivery',
  payment_status VARCHAR(50) DEFAULT 'PENDING',        -- PENDING or COMPLETED
  delivered_email_sent TINYINT(1) DEFAULT 0,
  order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

### 3. `products` Table
Stores food items, prices, categories, ratings, and image filenames.
```sql
CREATE TABLE products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  price INT NOT NULL,
  category VARCHAR(50) DEFAULT 'Fast Food',
  rating DECIMAL(2,1) DEFAULT 4.5,
  image VARCHAR(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

### 4. `reviews` Table
Stores customer ratings and feedback.
```sql
CREATE TABLE reviews (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT DEFAULT NULL,
  order_id INT DEFAULT NULL,
  name VARCHAR(100) NOT NULL,
  rating INT NOT NULL DEFAULT 5,
  comment TEXT NOT NULL,
  status VARCHAR(20) DEFAULT 'APPROVED',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

### 5. `order_status_history` Table
Logs all order status changes for auditing and tracking.
```sql
CREATE TABLE order_status_history (
  history_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  old_status VARCHAR(50),
  new_status VARCHAR(50) NOT NULL,
  changed_by VARCHAR(100) DEFAULT 'ADMIN',
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```
