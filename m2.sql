-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 13, 2024 at 11:50 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `m2`
--

-- --------------------------------------------------------

--
-- Table structure for table `borrow`
--

CREATE TABLE `borrow` (
  `id` int(11) NOT NULL,
  `movie_id` int(11) DEFAULT NULL,
  `borrower` int(5) NOT NULL,
  `approver` int(5) DEFAULT NULL,
  `admin` int(5) DEFAULT NULL,
  `date_start` date DEFAULT NULL,
  `date_end` date DEFAULT NULL,
  `status` int(11) DEFAULT 2
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `borrow`
--

INSERT INTO `borrow` (`id`, `movie_id`, `borrower`, `approver`, `admin`, `date_start`, `date_end`, `status`) VALUES
(26, 41, 20, NULL, NULL, '2024-11-13', '2024-11-30', 2);

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `cate_id` int(10) NOT NULL,
  `categorie` varchar(15) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`cate_id`, `categorie`) VALUES
(1, 'Drama'),
(2, 'Comedy'),
(3, 'Thriller'),
(4, 'Crime'),
(5, 'Fantasy'),
(6, 'History'),
(7, 'Romantic'),
(8, 'Action');

-- --------------------------------------------------------

--
-- Table structure for table `movies`
--

CREATE TABLE `movies` (
  `id` int(11) NOT NULL,
  `movie_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `categorie` int(10) NOT NULL,
  `status_movie` int(11) NOT NULL,
  `pic` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `movies`
--

INSERT INTO `movies` (`id`, `movie_name`, `description`, `categorie`, `status_movie`, `pic`) VALUES
(1, 'Avenger Endgame', 'After the devastating events of Avengers: Infinity War (2018), the universe is in ruins. With the help of remaining allies, the Avengers assemble once more in order to reverse Thanos\' actions and restore balance to the universe.', 5, 1, 'Assets/image/Recommend_2.jpg'),
(2, 'SARASIN OF LOVE', NULL, 7, 4, 'Assets/image/R0004.jpg'),
(6, 'CIVIL WAR', NULL, 5, 2, 'Assets/image/A0009.jpg'),
(7, 'HOW TOO TING', NULL, 1, 1, 'Assets/image/D0001.jpg'),
(8, 'TEE YOD', NULL, 3, 1, 'Assets/image/T0003.jpg'),
(20, 'THE DARK KNIGHT', NULL, 5, 1, 'Assets/image/Recommend_5.jpg'),
(21, 'WAKANDA FOREVER', NULL, 5, 1, 'Assets/image/Recommend_4.jpg'),
(22, 'FRIEND ZONE', NULL, 7, 1, 'Assets/image/R0003.jpg'),
(23, 'FAN DAY', NULL, 1, 4, 'Assets/image/M0002.jpg'),
(24, 'MONEY HEIGHT', NULL, 4, 1, 'Assets/image/C0001.jpg'),
(25, 'LAN MA', NULL, 1, 2, 'Assets/image/D0003.jpg'),
(26, 'DEADPOOL1', NULL, 8, 1, 'Assets/image/Deadpool1.jpg'),
(27, 'AMAZING SPIDERMAN', NULL, 5, 1, 'Assets/image/F0009.jpg'),
(28, 'TSCHERNOBYL', NULL, 6, 1, 'Assets/image/H0001.jpg'),
(29, 'PEE MAK', NULL, 7, 1, 'Assets/image/H0003.jpg'),
(30, 'LUANG PEE TENG', NULL, 2, 4, 'Assets/image/Y0001.jpg'),
(31, 'RANG ZONG', NULL, 3, 1, 'Assets/image/T0005.jpg'),
(32, '18 AGAIN', NULL, 7, 2, 'Assets/image/R0005.jpg'),
(33, 'CRASH LANDING ', NULL, 7, 2, 'Assets/image/R0006.jpg'),
(34, 'PARASITE', NULL, 1, 4, 'Assets/image/D0004.jpg'),
(35, 'ANNABELLE 1', NULL, 3, 1, 'Assets/image/T0004.jpg'),
(36, 'JOHN WICK1', NULL, 8, 1, 'Assets/image/A0001.jpg'),
(37, 'PIRATES CARIBBEAN', NULL, 8, 1, 'Assets/image/A0002.jpg'),
(38, 'JACK REACHER', NULL, 8, 1, 'Assets/image/A0004.jpg'),
(39, '007 SKYFALL', NULL, 8, 1, 'Assets/image/A0005.jpg'),
(40, 'FAST&FURIOUS 7', NULL, 8, 4, 'Assets/image/A0007.jpg'),
(41, 'PRISON BREAK', NULL, 4, 3, 'Assets/image/C00002.jpg'),
(42, 'SILENT NIGHT', NULL, 4, 2, 'Assets/image/C0004.jpg'),
(43, 'BREAKING BAD', NULL, 4, 1, 'Assets/image/C0005.jpg'),
(44, 'THE REVENANT', NULL, 6, 1, 'Assets/image/H0005.jpg'),
(45, 'THE NORTHMAN', NULL, 6, 1, 'Assets/image/H0006.jpg'),
(46, 'ELIZABETH', NULL, 6, 3, 'Assets/image/H0007.jpg'),
(47, 'TIT NOAEY', '', 6, 1, 'Assets/image/H0004.jpg'),
(48, 'LUANG PEE JAZZ', '', 2, 2, 'Assets/image/Co0001.jpg');

-- --------------------------------------------------------

--
-- Table structure for table `movie_status`
--

CREATE TABLE `movie_status` (
  `status_id` int(11) NOT NULL,
  `status_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `movie_status`
--

INSERT INTO `movie_status` (`status_id`, `status_name`) VALUES
(1, 'available'),
(2, 'unavailable'),
(3, 'pending'),
(4, 'borrowed');

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `role_id` int(11) NOT NULL,
  `role_name` varchar(15) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`role_id`, `role_name`) VALUES
(1, 'user'),
(2, 'admin'),
(3, 'approver');

-- --------------------------------------------------------

--
-- Table structure for table `status`
--

CREATE TABLE `status` (
  `id` int(11) NOT NULL,
  `status_name` varchar(20) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `status`
--

INSERT INTO `status` (`id`, `status_name`) VALUES
(1, 'approved'),
(2, 'pending'),
(3, 'rejected'),
(4, 'returned');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(5) NOT NULL,
  `fullname` varchar(40) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `username` varchar(20) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `password` varchar(60) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `role` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `fullname`, `username`, `password`, `role`) VALUES
(1, 'Nareerak', 'user', '$2b$10$lNchGp5OdM7oL3wx3XIBJOetv0qDgOsxySKsfNzQOY.BWbdCQ6q22', 1),
(2, 'letsgo', 'admin', '$2b$10$C4lOIpvByC62/PLcKUBEM.Bk4tIQu9X.IGkE0TFSG5yrASfMhEuC.', 2),
(3, 'mamamoodeng', 'approver', '$2b$10$YtFZpWQHd7p4be1BMeXI/.qZjUVqnG4mw3Jga5TSptiGDWUOS4U.W', 3),
(8, 'Nareerak', 'kaew', '$2b$10$7XIbhgg6aPOw9AeCofSpqeqOkSygOHXDqkZ727BuhPnD9VIWUlh8.', 1),
(9, 'Nareerak', 'mm', '$2b$10$9kKeNSKZ2KZZQuVzdsQtNO6D1DUsZje4B9IpgtPkKKQu7AG20shxK', 1),
(20, 'user9', 'user9', '$2b$10$VWs509HSb3ds614I3O0YF.208UnEiEOzFHHQSef0mXKgH7KTt3yhK', 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `borrow`
--
ALTER TABLE `borrow`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FK4` (`borrower`),
  ADD KEY `approver` (`approver`),
  ADD KEY `admin` (`admin`),
  ADD KEY `status` (`status`),
  ADD KEY `movie` (`movie_id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`cate_id`);

--
-- Indexes for table `movies`
--
ALTER TABLE `movies`
  ADD PRIMARY KEY (`id`),
  ADD KEY `categorie` (`categorie`),
  ADD KEY `status_movie` (`status_movie`);

--
-- Indexes for table `movie_status`
--
ALTER TABLE `movie_status`
  ADD PRIMARY KEY (`status_id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`role_id`);

--
-- Indexes for table `status`
--
ALTER TABLE `status`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FK1` (`role`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `borrow`
--
ALTER TABLE `borrow`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `cate_id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `movies`
--
ALTER TABLE `movies`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=49;

--
-- AUTO_INCREMENT for table `movie_status`
--
ALTER TABLE `movie_status`
  MODIFY `status_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `borrow`
--
ALTER TABLE `borrow`
  ADD CONSTRAINT `FK4` FOREIGN KEY (`borrower`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `admin` FOREIGN KEY (`admin`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `approver` FOREIGN KEY (`approver`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `movie` FOREIGN KEY (`movie_id`) REFERENCES `movies` (`id`),
  ADD CONSTRAINT `status` FOREIGN KEY (`status`) REFERENCES `status` (`id`);

--
-- Constraints for table `movies`
--
ALTER TABLE `movies`
  ADD CONSTRAINT `FK2` FOREIGN KEY (`categorie`) REFERENCES `categories` (`cate_id`),
  ADD CONSTRAINT `status_movie` FOREIGN KEY (`status_movie`) REFERENCES `movie_status` (`status_id`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `FK1` FOREIGN KEY (`role`) REFERENCES `roles` (`role_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
