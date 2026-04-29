-- Syncora DB Schema (Revisi Final) - MySQL/MariaDB
-- Generated: 2026-04-16

CREATE DATABASE IF NOT EXISTS syncora_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE syncora_db;

-- 3.1 Users
CREATE TABLE IF NOT EXISTS users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  phone_number VARCHAR(20) NOT NULL,
  avatar_url VARCHAR(255) NULL,
  address TEXT NULL,
  ktp_photo_url VARCHAR(255) NULL,
  role ENUM('admin','user') NOT NULL DEFAULT 'user',
  status ENUM('active','suspended') NOT NULL DEFAULT 'active',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 3.2 Categories
CREATE TABLE IF NOT EXISTS categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(100) NOT NULL,
  description TEXT NOT NULL
) ENGINE=InnoDB;

-- 3.3 Products
CREATE TABLE IF NOT EXISTS products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  category_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT NOT NULL,
  image_url VARCHAR(255) NULL,
  can_sell BOOLEAN NOT NULL DEFAULT FALSE,
  can_rent BOOLEAN NOT NULL DEFAULT FALSE,
  price_sell DECIMAL(15,2) NULL,
  price_rent DECIMAL(15,2) NULL,
  deposit_percentage DECIMAL(5,2) NULL,
  stock INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_products_category
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 3.4 Carts
CREATE TABLE IF NOT EXISTS carts (
  cart_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL UNIQUE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_carts_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 3.5 Cart_Items
CREATE TABLE IF NOT EXISTS cart_items (
  cart_item_id INT AUTO_INCREMENT PRIMARY KEY,
  cart_id INT NOT NULL,
  product_id INT NOT NULL,
  item_type ENUM('sell','rent') NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  rent_start_date DATE NULL,
  rent_end_date DATE NULL,
  CONSTRAINT fk_cart_items_cart
    FOREIGN KEY (cart_id) REFERENCES carts(cart_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_cart_items_product
    FOREIGN KEY (product_id) REFERENCES products(product_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 3.6 Orders
CREATE TABLE IF NOT EXISTS orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  order_type ENUM('purchase','rental') NOT NULL,
  total_price DECIMAL(15,2) NOT NULL DEFAULT 0,
  payment_method VARCHAR(50) NOT NULL DEFAULT 'manual',
  payment_status ENUM('pending','success','failed') NOT NULL DEFAULT 'pending',
  status ENUM('pending','paid','active','overdue','returned','completed','cancelled') NOT NULL DEFAULT 'pending',
  order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_orders_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 3.7 Order_Details
CREATE TABLE IF NOT EXISTS order_details (
  order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  price DECIMAL(15,2) NOT NULL DEFAULT 0,
  rent_start_date DATE NULL,
  rent_end_date DATE NULL,
  pickup_date DATETIME NULL,
  pickup_confirmed_by INT NULL,
  actual_return_date DATE NULL,
  deposit_amount DECIMAL(15,2) NULL,
  deposit_status ENUM('held','returned','deducted') NULL,
  late_days INT NOT NULL DEFAULT 0,
  late_fee DECIMAL(15,2) NOT NULL DEFAULT 0,
  damage_fee DECIMAL(15,2) NOT NULL DEFAULT 0,
  CONSTRAINT fk_order_details_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_order_details_product
    FOREIGN KEY (product_id) REFERENCES products(product_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_order_details_pickup_admin
    FOREIGN KEY (pickup_confirmed_by) REFERENCES users(user_id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- 3.8 System_Settings (single row)
CREATE TABLE IF NOT EXISTS system_settings (
  setting_id INT PRIMARY KEY,
  late_fee_percentage DECIMAL(5,2) NOT NULL DEFAULT 10.00,
  minimum_deposit_percentage DECIMAL(5,2) NOT NULL DEFAULT 20.00,
  max_active_rental INT NOT NULL DEFAULT 2,
  max_rent_duration INT NOT NULL DEFAULT 14,
  damage_fee_rate DECIMAL(5,2) NOT NULL DEFAULT 15.00
) ENGINE=InnoDB;

INSERT IGNORE INTO system_settings (setting_id) VALUES (1);

-- Optional: seed basic categories
INSERT INTO categories (category_name, description) VALUES
  ('Gitar', 'Alat musik dawai: gitar akustik/elektrik'),
  ('Drum', 'Alat musik perkusi: drum set dan accessories'),
  ('Keyboard', 'Keyboard dan synthesizer')
ON DUPLICATE KEY UPDATE category_name = VALUES(category_name);

