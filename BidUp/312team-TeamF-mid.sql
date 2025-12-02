-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Nov 04, 2025 at 03:38 PM
-- Server version: 9.1.0
-- PHP Version: 8.3.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `auction_system`
--

-- --------------------------------------------------------

--
-- Table structure for table `auction_rules`
--

DROP TABLE IF EXISTS `auction_rules`;
CREATE TABLE IF NOT EXISTS `auction_rules` (
  `rule_id` int NOT NULL AUTO_INCREMENT,
  `min_bid_increment` decimal(10,2) DEFAULT '10.00',
  `max_duration_hours` int DEFAULT '168',
  `min_duration_hours` int DEFAULT '24',
  `max_schedule_days` int DEFAULT '3',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`rule_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `auction_rules`
--

INSERT INTO `auction_rules` (`rule_id`, `min_bid_increment`, `max_duration_hours`, `min_duration_hours`, `max_schedule_days`, `updated_at`) VALUES
(1, 10.00, 168, 1, 3, '2025-11-02 16:04:18');

-- --------------------------------------------------------

--
-- Table structure for table `bids`
--

DROP TABLE IF EXISTS `bids`;
CREATE TABLE IF NOT EXISTS `bids` (
  `bid_id` int NOT NULL AUTO_INCREMENT,
  `item_id` int NOT NULL,
  `bidder_id` int NOT NULL,
  `bid_amount` decimal(10,2) NOT NULL,
  `bid_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`bid_id`),
  KEY `idx_item` (`item_id`),
  KEY `idx_bidder` (`bidder_id`),
  KEY `idx_amount` (`bid_amount` DESC)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `bids`
--

INSERT INTO `bids` (`bid_id`, `item_id`, `bidder_id`, `bid_amount`, `bid_time`) VALUES
(3, 2, 3, 80009.00, '2025-11-01 16:34:27'),
(4, 2, 2, 81000.00, '2025-11-01 16:36:33'),
(5, 2, 5, 82000.00, '2025-11-01 16:37:07'),
(6, 2, 2, 83000.00, '2025-11-01 16:37:39'),
(7, 3, 4, 1010.00, '2025-11-01 16:59:37'),
(8, 4, 4, 1510.00, '2025-11-01 16:59:50'),
(9, 4, 5, 1600.00, '2025-11-01 17:12:06'),
(10, 4, 4, 1700.00, '2025-11-01 17:29:25'),
(11, 9, 3, 810.00, '2025-11-02 05:22:31'),
(12, 4, 2, 6700.00, '2025-11-02 14:39:04'),
(13, 4, 4, 7000.00, '2025-11-02 15:45:41'),
(14, 14, 5, 610.00, '2025-11-02 16:30:28'),
(15, 14, 4, 620.00, '2025-11-02 16:30:48'),
(16, 14, 5, 650.00, '2025-11-02 16:31:13'),
(17, 14, 2, 700.00, '2025-11-02 16:31:32'),
(18, 13, 2, 600.00, '2025-11-02 17:02:00'),
(19, 13, 4, 700.00, '2025-11-02 17:04:40'),
(20, 15, 2, 41000.00, '2025-11-02 17:16:27'),
(21, 15, 4, 42000.00, '2025-11-02 17:16:37'),
(22, 15, 2, 43000.00, '2025-11-02 17:16:52'),
(23, 15, 3, 45000.00, '2025-11-02 17:17:26'),
(24, 16, 3, 21000.00, '2025-11-02 18:07:47'),
(25, 16, 5, 22000.00, '2025-11-02 18:08:26'),
(26, 16, 4, 23000.00, '2025-11-02 18:09:16'),
(27, 17, 2, 2050.00, '2025-11-02 18:34:04'),
(30, 5, 5, 50000.00, '2025-11-04 09:59:28'),
(31, 5, 5, 70000.00, '2025-11-04 10:03:03'),
(32, 10, 2, 50000.00, '2025-11-04 10:03:55'),
(33, 10, 5, 60000.00, '2025-11-04 10:40:15'),
(34, 5, 5, 71000.00, '2025-11-04 10:40:32'),
(35, 20, 4, 110000.00, '2025-11-04 11:10:38'),
(36, 20, 4, 111000.00, '2025-11-04 11:12:19'),
(37, 21, 3, 110000.00, '2025-11-04 12:28:56'),
(38, 22, 2, 1600.00, '2025-11-04 15:11:23'),
(39, 22, 5, 1700.00, '2025-11-04 15:12:31');

-- --------------------------------------------------------

--
-- Table structure for table `items`
--

DROP TABLE IF EXISTS `items`;
CREATE TABLE IF NOT EXISTS `items` (
  `item_id` int NOT NULL AUTO_INCREMENT,
  `owner_id` int NOT NULL,
  `title` varchar(200) NOT NULL,
  `description` text NOT NULL,
  `image_path` varchar(255) DEFAULT NULL,
  `category` varchar(50) NOT NULL,
  `starting_price` decimal(10,2) NOT NULL,
  `current_price` decimal(10,2) NOT NULL,
  `status` enum('pending','approved','active','ended','rejected') DEFAULT 'pending',
  `manually_ended` tinyint(1) DEFAULT '0',
  `winner_id` int DEFAULT NULL,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `duration_hours` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`item_id`),
  KEY `idx_status` (`status`),
  KEY `idx_owner` (`owner_id`),
  KEY `idx_end_time` (`end_time`),
  KEY `idx_winner` (`winner_id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `items`
--

INSERT INTO `items` (`item_id`, `owner_id`, `title`, `description`, `image_path`, `category`, `starting_price`, `current_price`, `status`, `manually_ended`, `winner_id`, `start_time`, `end_time`, `duration_hours`, `created_at`) VALUES
(2, 4, 'Nissan Silvia S15 Spec-R', '2002 Model', 'uploads/69063644e2e4f_nissan silvia s15.jpg', 'Electronics', 79999.00, 83000.00, 'ended', 1, 2, '2025-11-01 16:33:08', '2025-11-02 22:34:28', 24, '2025-11-01 16:33:08'),
(3, 3, 'Preloved Justin Nabunturan T-Shirt', '1 time use', 'uploads/6906383679bb9_540052998_122116761626961569_2941641845410148088_n.jpg', 'Fashion', 1000.00, 1010.00, 'ended', 1, 4, '2025-11-01 16:41:26', '2025-11-02 23:51:40', 24, '2025-11-01 16:41:26'),
(4, 3, 'iPhone 16', 'Brand New Sealed', 'uploads/6906386999287_iPhone 16.jpg', 'Electronics', 1500.00, 7000.00, 'ended', 1, 4, '2025-11-01 16:42:17', '2025-11-02 23:46:17', 48, '2025-11-01 16:42:17'),
(5, 4, 'Honda Giorno+ 2024', 'ODO 2k', 'uploads/69063c619b744_honda-giorno-plus-2024-launch-01-1693389608.jpeg', 'Electronics', 5000.00, 71000.00, 'ended', 1, 5, '2025-11-01 16:59:13', '2025-11-02 16:59:13', 24, '2025-11-01 16:59:13'),
(9, 5, 'new item', 'new new', '', 'Collectibles', 800.00, 810.00, 'ended', 1, 3, '2025-11-02 05:20:39', '2025-11-02 23:39:12', 24, '2025-11-02 05:20:39'),
(10, 2, '123', '123', '', 'Art', 700.00, 60000.00, 'ended', 1, 5, '2025-11-02 08:39:15', '2025-11-02 09:39:15', 1, '2025-11-02 08:39:15'),
(13, 3, 'Brand New Tshirt', 'T-Shirt Large', 'uploads/690781c5efd3c_Screenshot 2025-11-03 000624.png', 'Fashion', 500.00, 700.00, 'ended', 1, 4, '2025-11-02 16:07:33', '2025-11-03 01:06:09', 1, '2025-11-02 16:07:33'),
(14, 3, 'TShirt', 'new', 'uploads/690786e9b3bd4_Screenshot 2025-11-03 000624.png', 'Fashion', 500.00, 700.00, 'ended', 1, 2, '2025-11-02 16:29:29', '2025-11-03 00:31:49', 24, '2025-11-02 16:29:29'),
(15, 5, 'Shiny Charizard Card', 'Holy Grail from the year 1999.\\r\\n\\r\\nGem Mint Condition', 'uploads/6907918e754ff_chari.png', 'Collectibles', 40000.00, 45000.00, 'ended', 1, 3, '2025-11-02 17:14:54', '2025-11-03 01:17:50', 24, '2025-11-02 17:14:54'),
(16, 6, 'Black Lotus Card - MAGIC: The Gathering', '7/10 condition', 'uploads/69079d9e5c501_Black-Lotus-2ED-672.jpg', 'Collectibles', 20000.00, 23000.00, 'ended', 1, 4, '2025-11-02 18:06:22', '2025-11-03 02:10:16', 24, '2025-11-02 18:06:22'),
(17, 4, 'Kalabaw', 'Easy to handle, Fully Vaccinated, 2 years old', 'uploads/6907a3b5c8b45_kalabaw.jpg', 'Other', 2000.00, 2050.00, 'ended', 1, 2, '2025-11-02 18:32:21', '2025-11-03 02:34:20', 24, '2025-11-02 18:32:21'),
(20, 3, 'Samsung S24', 'BRAND NEW', 'uploads/1762254501_samsung.jpg', 'Electronics', 100000.00, 111000.00, 'ended', 1, 4, NULL, NULL, 0, '2025-11-04 11:08:21'),
(21, 2, 'Jordan 1 High OG', '1984', 'uploads/1762259144_jordan1.jpg', 'Fashion', 100000.00, 110000.00, 'ended', 1, 3, NULL, NULL, 0, '2025-11-04 12:25:44'),
(22, 4, 'Berserk, Vol. 1', 'Deluxe Version', 'uploads/1762268058_BERSERK deluxe edition.jpg', 'Art', 1500.00, 1700.00, 'ended', 1, 5, NULL, NULL, 0, '2025-11-04 14:54:18');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
CREATE TABLE IF NOT EXISTS `notifications` (
  `notification_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `item_id` int DEFAULT NULL,
  `message` text NOT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notification_id`),
  KEY `item_id` (`item_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_read` (`is_read`)
) ENGINE=InnoDB AUTO_INCREMENT=123 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`notification_id`, `user_id`, `item_id`, `message`, `is_read`, `created_at`) VALUES
(1, 5, NULL, 'Your item \'iphone\' has been approved by admin', 1, '2025-11-01 14:45:32'),
(2, 5, NULL, 'New bid of $6,565,656.00 placed on your item: iphone', 1, '2025-11-01 16:22:13'),
(3, 5, NULL, 'New bid of $6,456,456,546.00 placed on your item: iphone', 1, '2025-11-01 16:23:23'),
(4, 2, NULL, 'You have been outbid on: iphone', 0, '2025-11-01 16:23:23'),
(5, 5, NULL, 'Your item \'iphone\' has been removed by admin. Reason: 123', 1, '2025-11-01 16:27:15'),
(6, 4, 2, 'Your item \'Nissan Silvia S15 Spec-R\' has been approved by admin', 1, '2025-11-01 16:33:37'),
(7, 4, 2, 'New bid of $80,009.00 placed on your item: Nissan Silvia S15 Spec-R', 1, '2025-11-01 16:34:27'),
(8, 4, 2, 'New bid of $81,000.00 placed on your item: Nissan Silvia S15 Spec-R', 1, '2025-11-01 16:36:33'),
(9, 3, 2, 'You have been outbid on: Nissan Silvia S15 Spec-R', 0, '2025-11-01 16:36:33'),
(10, 4, 2, 'New bid of $82,000.00 placed on your item: Nissan Silvia S15 Spec-R', 1, '2025-11-01 16:37:07'),
(11, 2, 2, 'You have been outbid on: Nissan Silvia S15 Spec-R', 1, '2025-11-01 16:37:07'),
(12, 4, 2, 'New bid of $83,000.00 placed on your item: Nissan Silvia S15 Spec-R', 1, '2025-11-01 16:37:39'),
(13, 5, 2, 'You have been outbid on: Nissan Silvia S15 Spec-R', 1, '2025-11-01 16:37:39'),
(14, 3, 3, 'Your item \'Preloved Justin Nabunturan T-Shirt\' has been approved by admin', 0, '2025-11-01 16:57:15'),
(15, 3, 4, 'Your item \'iPhone 16\' has been approved by admin', 0, '2025-11-01 16:57:20'),
(16, 3, 3, 'New bid of $1,010.00 placed on your item: Preloved Justin Nabunturan T-Shirt', 0, '2025-11-01 16:59:37'),
(17, 3, 4, 'New bid of $1,510.00 placed on your item: iPhone 16', 0, '2025-11-01 16:59:50'),
(18, 3, 4, 'New bid of $1,600.00 placed on your item: iPhone 16', 0, '2025-11-01 17:12:06'),
(19, 4, 4, 'You have been outbid on: iPhone 16', 1, '2025-11-01 17:12:06'),
(20, 3, 4, 'New bid of $1,700.00 placed on your item: iPhone 16', 1, '2025-11-01 17:29:25'),
(21, 5, 4, 'You have been outbid on: iPhone 16', 1, '2025-11-01 17:29:25'),
(22, 5, NULL, 'Your item \'1234\' has been approved by admin', 1, '2025-11-02 05:16:24'),
(23, 5, 9, 'Your item \'new item\' has been approved by admin', 1, '2025-11-02 05:21:03'),
(24, 5, NULL, 'Your item \'test item\' has been removed by admin. Reason: invalid', 1, '2025-11-02 05:21:34'),
(25, 5, NULL, 'Your item \'1234\' has been removed by admin. Reason: invalid item', 1, '2025-11-02 05:21:48'),
(26, 5, NULL, 'Your item \'123\' has been removed by admin. Reason: invalid item', 1, '2025-11-02 05:21:57'),
(27, 5, 9, 'New bid of $810.00 placed on your item: new item', 1, '2025-11-02 05:22:31'),
(28, 2, 2, '🎉 Congratulations! You won the auction for \'Nissan Silvia S15 Spec-R\' with a bid of $83,000.00. The owner has ended the bidding. Please proceed to payment.', 1, '2025-11-02 14:34:28'),
(29, 3, 2, 'The auction for \'Nissan Silvia S15 Spec-R\' has ended. Unfortunately, you did not win this auction.', 0, '2025-11-02 14:34:28'),
(30, 5, 2, 'The auction for \'Nissan Silvia S15 Spec-R\' has ended. Unfortunately, you did not win this auction.', 1, '2025-11-02 14:34:28'),
(31, 3, 4, 'New bid of $6,700.00 placed on your item: iPhone 16', 0, '2025-11-02 14:39:04'),
(32, 4, 4, 'You have been outbid on: iPhone 16', 1, '2025-11-02 14:39:04'),
(33, 2, 2, 'Payment of $83,000.00 for \'Nissan Silvia S15 Spec-R\' has been processed successfully via GCASH. Transaction ref: GCASH-20251102-2-2438', 0, '2025-11-02 15:33:41'),
(34, 4, 2, 'You have received payment of $83,000.00 from John Doe (john_user) for your item \'Nissan Silvia S15 Spec-R\' via GCASH. Transaction ref: GCASH-20251102-2-2438', 1, '2025-11-02 15:33:41'),
(35, 3, 9, '🎉 Congratulations! You won the auction for \'new item\' with a bid of $810.00. The owner has ended the bidding. Please proceed to payment.', 0, '2025-11-02 15:39:12'),
(36, 3, 9, 'Payment of $810.00 for \'new item\' has been processed successfully via DEBIT. Transaction ref: DEBIT-20251102-9-6355', 0, '2025-11-02 15:40:11'),
(37, 5, 9, 'You have received payment of $810.00 from Jane Smith (jane_user) for your item \'new item\' via DEBIT. Transaction ref: DEBIT-20251102-9-6355', 1, '2025-11-02 15:40:11'),
(38, 4, 5, 'Your item \'Honda Giorno+ 2024\' has been approved by admin', 0, '2025-11-02 15:43:07'),
(39, 3, 4, 'New bid of $7,000.00 placed on your item: iPhone 16', 0, '2025-11-02 15:45:41'),
(40, 2, 4, 'You have been outbid on: iPhone 16', 0, '2025-11-02 15:45:41'),
(41, 4, 4, '🎉 Congratulations! You won the auction for \'iPhone 16\' with a bid of $7,000.00. The owner has ended the bidding. Please proceed to payment.', 0, '2025-11-02 15:46:17'),
(42, 5, 4, 'The auction for \'iPhone 16\' has ended. Unfortunately, you did not win this auction.', 1, '2025-11-02 15:46:17'),
(43, 2, 4, 'The auction for \'iPhone 16\' has ended. Unfortunately, you did not win this auction.', 0, '2025-11-02 15:46:17'),
(44, 4, 4, 'Payment of $7,000.00 for \'iPhone 16\' has been processed successfully via GCASH. Transaction ref: GCASH-20251102-4-7406', 0, '2025-11-02 15:49:22'),
(45, 3, 4, 'You have received payment of $7,000.00 from Michael Brown (michael_user) for your item \'iPhone 16\' via GCASH. Transaction ref: GCASH-20251102-4-7406', 1, '2025-11-02 15:49:22'),
(46, 4, 3, '🎉 Congratulations! You won the auction for \'Preloved Justin Nabunturan T-Shirt\' with a bid of $1,010.00. The owner has ended the bidding. Please proceed to payment.', 0, '2025-11-02 15:51:40'),
(47, 4, 3, 'Payment of $1,010.00 for \'Preloved Justin Nabunturan T-Shirt\' has been processed successfully via DEBIT. Transaction ref: DEBIT-20251102-3-2296', 0, '2025-11-02 15:55:35'),
(48, 3, 3, 'You have received payment of $1,010.00 from Michael Brown (michael_user) for your item \'Preloved Justin Nabunturan T-Shirt\' via DEBIT. Transaction ref: DEBIT-20251102-3-2296', 1, '2025-11-02 15:55:35'),
(49, 2, 10, 'Your item \'123\' has been approved by admin', 0, '2025-11-02 16:04:33'),
(50, 4, NULL, 'Your item \'600\' has been approved by admin', 0, '2025-11-02 16:04:49'),
(51, 3, 14, 'Your item \'TShirt\' has been approved by admin', 0, '2025-11-02 16:30:04'),
(52, 3, 14, 'New bid of $610.00 placed on your item: TShirt', 0, '2025-11-02 16:30:28'),
(53, 3, 14, 'New bid of $620.00 placed on your item: TShirt', 0, '2025-11-02 16:30:48'),
(54, 5, 14, 'You have been outbid on: TShirt', 1, '2025-11-02 16:30:48'),
(55, 3, 14, 'New bid of $650.00 placed on your item: TShirt', 0, '2025-11-02 16:31:13'),
(56, 4, 14, 'You have been outbid on: TShirt', 0, '2025-11-02 16:31:13'),
(57, 3, 14, 'New bid of $700.00 placed on your item: TShirt', 0, '2025-11-02 16:31:32'),
(58, 5, 14, 'You have been outbid on: TShirt', 1, '2025-11-02 16:31:32'),
(59, 2, 14, '🎉 Congratulations! You won the auction for \'TShirt\' with a bid of $700.00. The owner has ended the bidding. Please proceed to payment.', 0, '2025-11-02 16:31:49'),
(60, 5, 14, 'The auction for \'TShirt\' has ended. Unfortunately, you did not win this auction.', 1, '2025-11-02 16:31:49'),
(61, 4, 14, 'The auction for \'TShirt\' has ended. Unfortunately, you did not win this auction.', 0, '2025-11-02 16:31:49'),
(62, 2, 14, 'Payment of $700.00 for \'TShirt\' has been processed successfully via GCASH. Transaction ref: GCASH-20251102-14-2904', 0, '2025-11-02 16:32:32'),
(63, 3, 14, 'You have received payment of $700.00 from John Doe (john_user) for your item \'TShirt\' via GCASH. Transaction ref: GCASH-20251102-14-2904', 0, '2025-11-02 16:32:32'),
(64, 3, 13, 'Your item \'Brand New Tshirt\' has been approved by admin', 0, '2025-11-02 17:01:39'),
(65, 3, 13, 'New bid of $600.00 placed on your item: Brand New Tshirt', 0, '2025-11-02 17:02:00'),
(66, 3, 13, 'New bid of $700.00 placed on your item: Brand New Tshirt', 0, '2025-11-02 17:04:40'),
(67, 2, 13, 'You have been outbid on: Brand New Tshirt', 0, '2025-11-02 17:04:40'),
(68, 4, 13, '🎉 Congratulations! You won the auction for \'Brand New Tshirt\' with a bid of $700.00. The owner has ended the bidding. Please proceed to payment.', 1, '2025-11-02 17:06:09'),
(69, 2, 13, 'The auction for \'Brand New Tshirt\' has ended. Unfortunately, you did not win this auction.', 0, '2025-11-02 17:06:09'),
(70, 4, 13, 'Payment of $700.00 for \'Brand New Tshirt\' has been processed successfully via GCASH. Transaction ref: GCASH-20251102-13-2820', 0, '2025-11-02 17:06:50'),
(71, 3, 13, 'You have received payment of $700.00 from Michael Brown (michael_user) for your item \'Brand New Tshirt\' via GCASH. Transaction ref: GCASH-20251102-13-2820', 1, '2025-11-02 17:06:50'),
(72, 4, NULL, 'Your item \'600\' has been removed by admin. Reason: invalid', 0, '2025-11-02 17:11:17'),
(73, 4, NULL, 'Your item \'2323\' has been removed by admin. Reason: invalid', 0, '2025-11-02 17:11:23'),
(74, 5, 15, 'Your item \'Shiny Charizard Card\' has been approved by admin', 0, '2025-11-02 17:15:05'),
(75, 5, 15, 'New bid of $41,000.00 placed on your item: Shiny Charizard Card', 0, '2025-11-02 17:16:27'),
(76, 5, 15, 'New bid of $42,000.00 placed on your item: Shiny Charizard Card', 0, '2025-11-02 17:16:37'),
(77, 2, 15, 'You have been outbid on: Shiny Charizard Card', 0, '2025-11-02 17:16:37'),
(78, 5, 15, 'New bid of $43,000.00 placed on your item: Shiny Charizard Card', 0, '2025-11-02 17:16:52'),
(79, 4, 15, 'You have been outbid on: Shiny Charizard Card', 1, '2025-11-02 17:16:52'),
(80, 5, 15, 'New bid of $45,000.00 placed on your item: Shiny Charizard Card', 0, '2025-11-02 17:17:26'),
(81, 2, 15, 'You have been outbid on: Shiny Charizard Card', 0, '2025-11-02 17:17:26'),
(82, 3, 15, '🎉 Congratulations! You won the auction for \'Shiny Charizard Card\' with a bid of $45,000.00. The owner has ended the bidding. Please proceed to payment.', 0, '2025-11-02 17:17:50'),
(83, 2, 15, 'The auction for \'Shiny Charizard Card\' has ended. Unfortunately, you did not win this auction.', 0, '2025-11-02 17:17:50'),
(84, 4, 15, 'The auction for \'Shiny Charizard Card\' has ended. Unfortunately, you did not win this auction.', 1, '2025-11-02 17:17:50'),
(85, 3, 15, 'Payment of $45,000.00 for \'Shiny Charizard Card\' has been processed successfully via CREDIT. Transaction ref: CREDIT-20251102-15-8463', 0, '2025-11-02 17:18:24'),
(86, 5, 15, 'You have received payment of $45,000.00 from Jane Smith (jane_user) for your item \'Shiny Charizard Card\' via CREDIT. Transaction ref: CREDIT-20251102-15-8463', 1, '2025-11-02 17:18:24'),
(87, 6, 16, 'Your item \'Black Lotus Card - MAGIC: The Gathering\' has been approved by admin', 0, '2025-11-02 18:06:55'),
(88, 6, 16, 'New bid of $21,000.00 placed on your item: Black Lotus Card - MAGIC: The Gathering', 0, '2025-11-02 18:07:47'),
(89, 6, 16, 'New bid of $22,000.00 placed on your item: Black Lotus Card - MAGIC: The Gathering', 1, '2025-11-02 18:08:26'),
(90, 3, 16, 'You have been outbid on: Black Lotus Card - MAGIC: The Gathering', 0, '2025-11-02 18:08:26'),
(91, 6, 16, 'New bid of $23,000.00 placed on your item: Black Lotus Card - MAGIC: The Gathering', 1, '2025-11-02 18:09:16'),
(92, 5, 16, 'You have been outbid on: Black Lotus Card - MAGIC: The Gathering', 0, '2025-11-02 18:09:16'),
(93, 4, 16, '🎉 Congratulations! You won the auction for \'Black Lotus Card - MAGIC: The Gathering\' with a bid of $23,000.00. The owner has ended the bidding. Please proceed to payment.', 1, '2025-11-02 18:10:16'),
(94, 3, 16, 'The auction for \'Black Lotus Card - MAGIC: The Gathering\' has ended. Unfortunately, you did not win this auction.', 0, '2025-11-02 18:10:16'),
(95, 5, 16, 'The auction for \'Black Lotus Card - MAGIC: The Gathering\' has ended. Unfortunately, you did not win this auction.', 0, '2025-11-02 18:10:16'),
(96, 4, 16, 'Payment of $23,000.00 for \'Black Lotus Card - MAGIC: The Gathering\' has been processed successfully via DEBIT. Transaction ref: DEBIT-20251102-16-7346', 1, '2025-11-02 18:11:10'),
(97, 6, 16, 'You have received payment of $23,000.00 from Michael Brown (michael_user) for your item \'Black Lotus Card - MAGIC: The Gathering\' via DEBIT. Transaction ref: DEBIT-20251102-16-7346', 1, '2025-11-02 18:11:10'),
(98, 4, 17, 'Your item \'Kalabaw\' has been approved by admin', 0, '2025-11-02 18:33:15'),
(99, 4, 17, 'New bid of $2,050.00 placed on your item: Kalabaw', 0, '2025-11-02 18:34:04'),
(100, 2, 17, '🎉 Congratulations! You won the auction for \'Kalabaw\' with a bid of $2,050.00. The owner has ended the bidding. Please proceed to payment.', 0, '2025-11-02 18:34:20'),
(101, 4, 5, 'New bid of ₱50,000.00 placed on your item: Honda Giorno+ 2024', 0, '2025-11-04 09:59:28'),
(102, 4, 5, 'New bid of ₱70,000.00 placed on your item: Honda Giorno+ 2024', 0, '2025-11-04 10:03:03'),
(103, 2, 10, 'New bid of ₱50,000.00 placed on your item: 123', 0, '2025-11-04 10:03:55'),
(104, 2, 10, 'New bid of ₱60,000.00 placed on your item: 123', 0, '2025-11-04 10:40:15'),
(105, 4, 5, 'New bid of ₱71,000.00 placed on your item: Honda Giorno+ 2024', 0, '2025-11-04 10:40:32'),
(106, 5, 5, '🎉 Congratulations! You won the auction for \'Honda Giorno+ 2024\' with a bid of ₱71,000.00. The owner has ended the bidding. Please proceed to payment.', 0, '2025-11-04 11:09:36'),
(107, 3, 20, 'New bid of ₱110,000.00 placed on your item: Samsung S24', 0, '2025-11-04 11:10:38'),
(108, 3, 20, 'New bid of ₱111,000.00 placed on your item: Samsung S24', 0, '2025-11-04 11:12:19'),
(109, 4, 20, '🎉 Congratulations! You won the auction for \'Samsung S24\' with a bid of ₱111,000.00. The owner has ended the bidding. Please proceed to payment.', 0, '2025-11-04 11:13:17'),
(110, 2, 21, 'New bid of ₱110,000.00 placed on your item: Jordan 1 High OG', 0, '2025-11-04 12:28:56'),
(111, 3, 21, '🎉 Congratulations! You won the auction for \'Jordan 1 High OG\' with a bid of ₱110,000.00. The owner has ended the bidding. Please proceed to payment.', 0, '2025-11-04 12:29:51'),
(112, 5, 10, '🎉 Congratulations! You won the auction for \'123\' with a bid of ₱60,000.00. The owner has ended the bidding. Please proceed to payment.', 0, '2025-11-04 13:13:57'),
(113, 2, 10, 'The auction for \'123\' has ended. Unfortunately, you did not win this auction.', 0, '2025-11-04 13:13:57'),
(114, 3, 20, 'You have received payment of ₱111,000.00 from Michael Brown for your item \'Samsung S24\' via MAYA. Transaction ref: MAYA-20251104-20-7515', 0, '2025-11-04 14:34:28'),
(115, 4, 20, 'Payment of ₱111,000.00 for \'Samsung S24\' has been processed successfully via MAYA. Transaction ref: MAYA-20251104-20-7515', 0, '2025-11-04 14:34:28'),
(116, 4, 22, 'New bid of ₱1,600.00 placed on your item: Berserk, Vol. 1', 0, '2025-11-04 15:11:23'),
(117, 4, 22, 'New bid of ₱1,700.00 placed on your item: Berserk, Vol. 1', 0, '2025-11-04 15:12:31'),
(118, 2, 22, 'You have been outbid on: Berserk, Vol. 1', 0, '2025-11-04 15:12:31'),
(119, 5, 22, '🎉 Congratulations! You won the auction for \'Berserk, Vol. 1\' with a bid of ₱1,700.00. The owner has ended the bidding. Please proceed to payment.', 0, '2025-11-04 15:16:53'),
(120, 2, 22, 'The auction for \'Berserk, Vol. 1\' has ended. Unfortunately, you did not win this auction.', 0, '2025-11-04 15:16:53'),
(121, 4, 22, 'You have received payment of ₱1,700.00 from Sarah Wilson for your item \'Berserk, Vol. 1\' via DEBIT. Transaction ref: DEBIT-20251104-22-4953', 0, '2025-11-04 15:23:12'),
(122, 5, 22, 'Payment of ₱1,700.00 for \'Berserk, Vol. 1\' has been processed successfully via DEBIT. Transaction ref: DEBIT-20251104-22-4953', 0, '2025-11-04 15:23:12');

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
CREATE TABLE IF NOT EXISTS `payments` (
  `payment_id` int NOT NULL AUTO_INCREMENT,
  `bid_id` int NOT NULL,
  `owner_id` int NOT NULL,
  `owner_name` varchar(100) NOT NULL,
  `owner_email` varchar(100) NOT NULL,
  `owner_contact` varchar(50) DEFAULT NULL,
  `item_title` varchar(200) NOT NULL,
  `payment_method` enum('gcash','maya','debit','credit','qrph') NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_status` enum('pending','completed','failed') DEFAULT 'pending',
  `transaction_ref` varchar(100) DEFAULT NULL,
  `payment_proof` varchar(255) DEFAULT NULL,
  `payment_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`payment_id`),
  UNIQUE KEY `transaction_ref` (`transaction_ref`),
  KEY `idx_bid` (`bid_id`),
  KEY `idx_owner` (`owner_id`),
  KEY `idx_status` (`payment_status`),
  KEY `idx_transaction` (`transaction_ref`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `payments`
--

INSERT INTO `payments` (`payment_id`, `bid_id`, `owner_id`, `owner_name`, `owner_email`, `owner_contact`, `item_title`, `payment_method`, `amount`, `payment_status`, `transaction_ref`, `payment_proof`, `payment_date`) VALUES
(1, 6, 4, 'Michael Brown', 'michael@email.com', '', 'Nissan Silvia S15 Spec-R', 'gcash', 83000.00, 'completed', 'GCASH-20251102-2-2438', NULL, '2025-11-02 15:33:41'),
(2, 11, 5, 'Sarah Wilson', 'sarah@email.com', '', 'new item', 'debit', 810.00, 'completed', 'DEBIT-20251102-9-6355', NULL, '2025-11-02 15:40:11'),
(3, 13, 3, 'Jane Smith', 'jane@email.com', '', 'iPhone 16', 'gcash', 7000.00, 'completed', 'GCASH-20251102-4-7406', NULL, '2025-11-02 15:49:22'),
(4, 7, 3, 'Jane Smith', 'jane@email.com', '', 'Preloved Justin Nabunturan T-Shirt', 'debit', 1010.00, 'completed', 'DEBIT-20251102-3-2296', NULL, '2025-11-02 15:55:35'),
(5, 17, 3, 'Jane Smith', 'jane@email.com', '', 'TShirt', 'gcash', 700.00, 'completed', 'GCASH-20251102-14-2904', NULL, '2025-11-02 16:32:32'),
(6, 19, 3, 'Jane Smith', 'jane@email.com', '', 'Brand New Tshirt', 'gcash', 700.00, 'completed', 'GCASH-20251102-13-2820', NULL, '2025-11-02 17:06:50'),
(7, 23, 5, 'Sarah Wilson', 'sarah@email.com', '', 'Shiny Charizard Card', 'credit', 45000.00, 'completed', 'CREDIT-20251102-15-8463', NULL, '2025-11-02 17:18:24'),
(8, 26, 6, 'Justin Nabunturan', 'jnabun@gmail.com', 'NULL', 'Black Lotus Card - MAGIC: The Gathering', 'debit', 23000.00, 'completed', 'DEBIT-20251102-16-7346', NULL, '2025-11-02 18:11:10'),
(9, 36, 3, 'Jane Smith', 'jane@email.com', 'N/A', 'Samsung S24', '', 111000.00, 'completed', 'MAYA-20251104-20-7515', NULL, '2025-11-04 14:34:28'),
(10, 39, 4, 'Michael Brown', 'michael@email.com', 'N/A', 'Berserk, Vol. 1', '', 1700.00, 'completed', 'DEBIT-20251104-22-4953', NULL, '2025-11-04 15:23:12');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `user_type` enum('user','admin') NOT NULL DEFAULT 'user',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_username` (`username`),
  KEY `idx_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `password`, `email`, `full_name`, `phone`, `user_type`, `created_at`) VALUES
(1, 'admin', 'admin123', 'admin@auction.com', 'Admin User', NULL, 'admin', '2025-11-01 14:37:51'),
(2, 'john_user', 'password123', 'john@email.com', 'John Doe', NULL, 'user', '2025-11-01 14:37:51'),
(3, 'jane_user', 'password123', 'jane@email.com', 'Jane Smith', NULL, 'user', '2025-11-01 14:37:51'),
(4, 'michael_user', 'password123', 'michael@email.com', 'Michael Brown', NULL, 'user', '2025-11-01 14:37:51'),
(5, 'sarah_user', 'password123', 'sarah@email.com', 'Sarah Wilson', NULL, 'user', '2025-11-01 14:37:51'),
(6, 'justin', 'nabunturanishere', 'jnabun@gmail.com', 'Justin Nabunturan', 'NULL', 'user', '2025-11-01 14:37:51');

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bids`
--
ALTER TABLE `bids`
  ADD CONSTRAINT `bids_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`item_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `bids_ibfk_2` FOREIGN KEY (`bidder_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `items`
--
ALTER TABLE `items`
  ADD CONSTRAINT `fk_winner_user` FOREIGN KEY (`winner_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `items_ibfk_1` FOREIGN KEY (`owner_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `notifications_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `items` (`item_id`) ON DELETE SET NULL;

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`bid_id`) REFERENCES `bids` (`bid_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `payments_ibfk_2` FOREIGN KEY (`owner_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
