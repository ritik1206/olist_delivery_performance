-- =====================================================
-- 01_create_tables.sql : creates the olist database and its 8 tables
-- Safe to re-run (IF NOT EXISTS). Run first, then 02_load_data.sql.
-- =====================================================

CREATE DATABASE IF NOT EXISTS olist;
USE olist;

CREATE TABLE IF NOT EXISTS orders (
    order_id                       VARCHAR(32) PRIMARY KEY,
    customer_id                    VARCHAR(32),
    order_status                   VARCHAR(20),
    order_purchase_timestamp       DATETIME,
    order_approved_at              DATETIME,
    order_delivered_carrier_date   DATETIME,
    order_delivered_customer_date  DATETIME,
    order_estimated_delivery_date  DATETIME,
    INDEX idx_orders_purchase (order_purchase_timestamp)
);

CREATE TABLE IF NOT EXISTS customers (
    customer_id               VARCHAR(32) PRIMARY KEY,
    customer_unique_id        VARCHAR(32),
    customer_zip_code_prefix  VARCHAR(10),
    customer_city             VARCHAR(100),
    customer_state            CHAR(2)
);

CREATE TABLE IF NOT EXISTS sellers (
    seller_id               VARCHAR(32) PRIMARY KEY,
    seller_zip_code_prefix  VARCHAR(10),
    seller_city             VARCHAR(100),
    seller_state            CHAR(2)
);

CREATE TABLE IF NOT EXISTS order_items (
    order_id             VARCHAR(32),
    order_item_id        INT,
    product_id           VARCHAR(32),
    seller_id            VARCHAR(32),
    shipping_limit_date  DATETIME,
    price                DECIMAL(10,2),
    freight_value        DECIMAL(10,2),
    PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE IF NOT EXISTS order_reviews (
    review_id                VARCHAR(32),
    order_id                 VARCHAR(32),
    review_score             TINYINT,
    review_comment_title     VARCHAR(255),
    review_comment_message   TEXT,
    review_creation_date     DATETIME,
    review_answer_timestamp  DATETIME
);

CREATE TABLE IF NOT EXISTS products (
    product_id                  VARCHAR(32) PRIMARY KEY,
    product_category_name       VARCHAR(100),
    product_name_length         INT,
    product_description_length  INT,
    product_photos_qty          INT,
    product_weight_g            INT,
    product_length_cm           INT,
    product_height_cm           INT,
    product_width_cm            INT
);

CREATE TABLE IF NOT EXISTS product_category_translation (
    product_category_name          VARCHAR(100) PRIMARY KEY,
    product_category_name_english  VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS geolocation (
    geolocation_zip_code_prefix  VARCHAR(10),
    geolocation_lat              DOUBLE,
    geolocation_lng              DOUBLE,
    geolocation_city             VARCHAR(100),
    geolocation_state            CHAR(2)
);

