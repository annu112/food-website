-- Database setup script for Z Kitchen Food Ordering Application
CREATE DATABASE IF NOT EXISTS `food` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `food`;

-- Table structure for table `contact`
CREATE TABLE IF NOT EXISTS `contact` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nam` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `number` varchar(50) NOT NULL,
  `comment` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table structure for table `customers`
CREATE TABLE IF NOT EXISTS `customers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `password` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table structure for table `orfood`
CREATE TABLE IF NOT EXISTS `orfood` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nm` varchar(100) NOT NULL,
  `rs` varchar(100) NOT NULL,
  `cname` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `monumber` varchar(100) NOT NULL,
  `comm` text NOT NULL,
  `order_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table structure for table `products`
CREATE TABLE IF NOT EXISTS `products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `price` int(11) NOT NULL,
  `category` varchar(50) DEFAULT 'Fast Food',
  `rating` decimal(2,1) DEFAULT 4.5,
  `image` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table structure for table `reviews`
CREATE TABLE IF NOT EXISTS `reviews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `rating` int(11) NOT NULL DEFAULT 5,
  `comment` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Seed Data for `products`
TRUNCATE TABLE `products`;
INSERT INTO `products` (`id`, `name`, `price`, `category`, `rating`, `image`) VALUES
(1, 'Chicken Nuggets', 200, 'Starters', 4.8, 'chicken nuggets.png'),
(2, 'Garlic Bread', 150, 'Starters', 4.5, 'Garlic bread.png'),
(3, 'Chole Kulche', 250, 'Main Course', 4.7, 'Chole Kulche.png'),
(4, 'Fried Rice', 180, 'Main Course', 4.6, 'Pineapple_Fried_Rice.png'),
(5, 'Paneer Special', 300, 'Main Course', 4.9, 'paneer.png'),
(6, 'Crispy Chicken', 270, 'Fast Food', 4.8, 'crispy_fried.png'),
(7, 'Dahi Vada', 100, 'Starters', 4.4, 'Dahi vada.png'),
(8, 'Seekh Kabab', 250, 'Starters', 4.7, 'Lyulya_kebab.png'),
(9, 'Super Cheese Burger', 350, 'Fast Food', 4.9, 'burger.png'),
(10, 'Special Butter Chicken', 400, 'Main Course', 5.0, 'butter chicken.jpeg'),
(11, 'Hyderabadi Biryani', 500, 'Main Course', 4.9, 'Biryani.jpeg'),
(12, 'Loaded Italian Pizza', 350, 'Fast Food', 4.8, 'pizza.png');

-- Seed Data for `reviews`
TRUNCATE TABLE `reviews`;
INSERT INTO `reviews` (`name`, `rating`, `comment`) VALUES
('Anas Munshi', 5, 'The Butter Chicken and Garlic Bread were absolute perfection! Delivery was super fast!'),
('Adil Nai', 5, 'Best Biryani in town! Fresh ingredients, authentic aroma, and amazing packaging.'),
('Priya Sharma', 5, 'Super Cheese Burger was juicy and flavorful. Z Kitchen is my go-to restaurant!'),
('Rahul Verma', 4, 'Paneer Special had top notch taste. Highly recommended for family dinners.');
