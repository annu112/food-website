-- Z Kitchen Food Ordering System - Complete Master Database Schema SQL
-- Database Name: food

CREATE DATABASE IF NOT EXISTS `food` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `food`;

-- 1. Contact Messages Table
CREATE TABLE IF NOT EXISTS `contact` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `nam` VARCHAR(100) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `number` VARCHAR(50) NOT NULL,
  `comment` TEXT NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Core Users Table
CREATE TABLE IF NOT EXISTS `users` (
  `user_id` INT(11) NOT NULL AUTO_INCREMENT,
  `full_name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(100) DEFAULT NULL UNIQUE,
  `phone_number` VARCHAR(30) DEFAULT NULL UNIQUE,
  `password_hash` VARCHAR(255) DEFAULT NULL,
  `google_id` VARCHAR(100) DEFAULT NULL,
  `registration_method` VARCHAR(20) DEFAULT 'EMAIL',
  `role` VARCHAR(20) DEFAULT 'CUSTOMER',
  `email_verified` TINYINT(1) DEFAULT 0,
  `phone_verified` TINYINT(1) DEFAULT 0,
  `account_status` VARCHAR(20) DEFAULT 'ACTIVE',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_login` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  INDEX `idx_email` (`email`),
  INDEX `idx_phone` (`phone_number`),
  INDEX `idx_google_id` (`google_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. OTP Verifications Table
CREATE TABLE IF NOT EXISTS `user_otps` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `user_identifier` VARCHAR(100) NOT NULL,
  `user_id` INT(11) DEFAULT NULL,
  `otp_code` VARCHAR(100) NOT NULL,
  `otp_type` VARCHAR(20) NOT NULL DEFAULT 'REGISTRATION',
  `expires_at` TIMESTAMP NOT NULL,
  `attempts` INT(11) NOT NULL DEFAULT 0,
  `verified` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_identifier` (`user_identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Login Activity Log Table
CREATE TABLE IF NOT EXISTS `login_activity` (
  `login_id` INT(11) NOT NULL AUTO_INCREMENT,
  `user_id` INT(11) DEFAULT NULL,
  `user_identifier` VARCHAR(100) NOT NULL,
  `login_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `otp_verified` TINYINT(1) DEFAULT 0,
  `login_status` VARCHAR(30) DEFAULT 'PENDING_OTP',
  `logout_time` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`login_id`),
  INDEX `idx_user_login` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. User Delivery Addresses Table
CREATE TABLE IF NOT EXISTS `user_addresses` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `user_id` INT(11) NOT NULL,
  `address_line` TEXT NOT NULL,
  `city` VARCHAR(50) NOT NULL,
  `pincode` VARCHAR(20) NOT NULL,
  `is_default` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_address_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. Food Orders Table
CREATE TABLE IF NOT EXISTS `orfood` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `user_id` INT(11) DEFAULT NULL,
  `nm` VARCHAR(255) NOT NULL,
  `rs` VARCHAR(100) NOT NULL,
  `cname` VARCHAR(100) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `monumber` VARCHAR(100) NOT NULL,
  `comm` TEXT NOT NULL,
  `order_status` VARCHAR(50) DEFAULT 'Pending',
  `subtotal` VARCHAR(50) DEFAULT NULL,
  `delivery_charge` VARCHAR(50) DEFAULT NULL,
  `latitude` VARCHAR(50) DEFAULT NULL,
  `longitude` VARCHAR(50) DEFAULT NULL,
  `house_building` VARCHAR(255) DEFAULT NULL,
  `street_area` VARCHAR(255) DEFAULT NULL,
  `city` VARCHAR(100) DEFAULT NULL,
  `state` VARCHAR(100) DEFAULT NULL,
  `pincode` VARCHAR(20) DEFAULT NULL,
  `delivered_email_sent` TINYINT(1) DEFAULT 0,
  `order_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. Order Status Audit History Table
CREATE TABLE IF NOT EXISTS `order_status_history` (
  `history_id` INT(11) NOT NULL AUTO_INCREMENT,
  `order_id` INT(11) NOT NULL,
  `old_status` VARCHAR(50) DEFAULT NULL,
  `new_status` VARCHAR(50) NOT NULL,
  `changed_by` VARCHAR(100) DEFAULT 'ADMIN',
  `changed_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`history_id`),
  INDEX `idx_order_hist` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. Food Products Table
CREATE TABLE IF NOT EXISTS `products` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `price` INT(11) NOT NULL,
  `category` VARCHAR(50) DEFAULT 'Fast Food',
  `rating` DECIMAL(2,1) DEFAULT 4.5,
  `image` VARCHAR(200) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 9. Customer Reviews Table
CREATE TABLE IF NOT EXISTS `reviews` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `user_id` INT(11) DEFAULT NULL,
  `order_id` INT(11) DEFAULT NULL,
  `name` VARCHAR(100) NOT NULL,
  `rating` INT(11) NOT NULL DEFAULT 5,
  `comment` TEXT NOT NULL,
  `status` VARCHAR(20) DEFAULT 'APPROVED',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_user_review` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 10. Email Service Dispatch Logs Table
CREATE TABLE IF NOT EXISTS `email_logs` (
  `log_id` INT(11) NOT NULL AUTO_INCREMENT,
  `recipient_email` VARCHAR(100) NOT NULL,
  `subject` VARCHAR(255) NOT NULL,
  `email_type` VARCHAR(50) NOT NULL,
  `status` VARCHAR(20) NOT NULL,
  `error_message` TEXT DEFAULT NULL,
  `sent_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  INDEX `idx_recipient` (`recipient_email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Initial Product Seed Data
INSERT INTO `products` (`id`, `name`, `price`, `category`, `image`) VALUES
(1, 'Chicken Nuggets', 200, 'Starters', 'chicken nuggets.png'),
(2, 'Garlic Bread', 150, 'Starters', 'Garlic bread.png'),
(3, 'Chole Kulche', 250, 'Main Course', 'Chole Kulche.png'),
(4, 'Fried Rice', 180, 'Main Course', 'Pineapple_Fried_Rice.png'),
(5, 'Paneer Special', 300, 'Main Course', 'paneer.png'),
(6, 'Crispy Chicken', 270, 'Fast Food', 'crispy_fried.png'),
(7, 'Dahi Vada', 100, 'Starters', 'Dahi vada.png'),
(8, 'Seekh Kabab', 250, 'Starters', 'Lyulya_kebab.png'),
(9, 'Super Burger', 350, 'Fast Food', 'burger.png'),
(10, 'Butter Chicken', 400, 'Main Course', 'butter chicken.jpeg'),
(11, 'Biryani', 500, 'Main Course', 'Biryani.jpeg'),
(12, 'Italian Pizza', 350, 'Fast Food', 'pizza.png')
ON DUPLICATE KEY UPDATE `id`=`id`;
