-- =====================================================
-- 02_load_data.sql : loads the 8 Olist CSV files
-- Prerequisite: local_infile enabled on server AND client
--   SET GLOBAL local_infile = 1;
--   connection setting: OPT_LOCAL_INFILE=1
-- Update the folder path below if your files live elsewhere.
-- Run the whole file, then read the Output panel after every load:
--   expect "Skipped: 0  Warnings: 0" (reviews: see note)
-- =====================================================
USE olist;

-- 1. orders (blank dates become NULL)
TRUNCATE TABLE orders;
LOAD DATA LOCAL INFILE 'C:/Users/ritik/OneDrive/Desktop/projects/supply_chain/olist/Data/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, customer_id, order_status,
 @purchase, @approved, @carrier, @delivered, @estimated)
SET
 order_purchase_timestamp      = NULLIF(@purchase, ''),
 order_approved_at             = NULLIF(@approved, ''),
 order_delivered_carrier_date  = NULLIF(@carrier, ''),
 order_delivered_customer_date = NULLIF(@delivered, ''),
 order_estimated_delivery_date = NULLIF(@estimated, '');

-- 2. customers
TRUNCATE TABLE customers;
LOAD DATA LOCAL INFILE 'C:/Users/ritik/OneDrive/Desktop/projects/supply_chain/olist/Data/olist_customers_dataset.csv'
INTO TABLE customers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 3. sellers
TRUNCATE TABLE sellers;
LOAD DATA LOCAL INFILE 'C:/Users/ritik/OneDrive/Desktop/projects/supply_chain/olist/Data/olist_sellers_dataset.csv'
INTO TABLE sellers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 4. order_items
TRUNCATE TABLE order_items;
LOAD DATA LOCAL INFILE 'C:/Users/ritik/OneDrive/Desktop/projects/supply_chain/olist/Data/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 5. order_reviews
-- This file has Windows line endings, so '\r\n' is required.
-- Expect 1 known row with 3 warnings (malformed record), fixed in step 5b.
TRUNCATE TABLE order_reviews;
LOAD DATA LOCAL INFILE 'C:/Users/ritik/OneDrive/Desktop/projects/supply_chain/olist/Data/olist_order_reviews_dataset.csv'
INTO TABLE order_reviews
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- 5b. Fix the one malformed review row: keep score and order link,
--     set the two unreadable dates to NULL.
SET SQL_SAFE_UPDATES = 0;
UPDATE order_reviews
SET review_creation_date    = NULL,
    review_answer_timestamp = NULL
WHERE review_id = '636b237e87574ba29654deaba9eb9797'
  AND order_id  = 'd7361a834a2dd8db2f6f133ce291ab6b';
SET SQL_SAFE_UPDATES = 1;

-- 6. products (blank numbers and categories become NULL)
TRUNCATE TABLE products;
LOAD DATA LOCAL INFILE 'C:/Users/ritik/OneDrive/Desktop/projects/supply_chain/olist/Data/olist_products_dataset.csv'
INTO TABLE products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_id, @category, @name_len, @desc_len, @photos,
 @weight, @length, @height, @width)
SET
 product_category_name      = NULLIF(@category, ''),
 product_name_length        = NULLIF(@name_len, ''),
 product_description_length = NULLIF(@desc_len, ''),
 product_photos_qty         = NULLIF(@photos, ''),
 product_weight_g           = NULLIF(@weight, ''),
 product_length_cm          = NULLIF(@length, ''),
 product_height_cm          = NULLIF(@height, ''),
 product_width_cm           = NULLIF(@width, '');

-- 7. category translation
TRUNCATE TABLE product_category_translation;
LOAD DATA LOCAL INFILE 'C:/Users/ritik/OneDrive/Desktop/projects/supply_chain/olist/Data/product_category_name_translation.csv'
INTO TABLE product_category_translation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 8. geolocation (about 1 million rows, takes roughly 20 seconds)
TRUNCATE TABLE geolocation;
LOAD DATA LOCAL INFILE 'C:/Users/ritik/OneDrive/Desktop/projects/supply_chain/olist/Data/olist_geolocation_dataset.csv'
INTO TABLE geolocation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;