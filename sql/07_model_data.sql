-- =====================================================
-- 07_model_data.sql : builds the dataset for the late-delivery model
-- Creates: geo_zip (table), vw_model_data (view), model_data (table)
-- Only features known AT PURCHASE are included (no data leakage).
-- Safe to re-run. Requires 04_views.sql and the loaded tables.
-- =====================================================
USE olist;

-- 1. One average position per ZIP prefix (bounding box drops 42 stray points)
DROP TABLE IF EXISTS geo_zip;

CREATE TABLE geo_zip AS
SELECT geolocation_zip_code_prefix AS zip_prefix,
       AVG(geolocation_lat)        AS lat,
       AVG(geolocation_lng)        AS lng,
       COUNT(*)                    AS n_points
FROM geolocation
WHERE geolocation_lat BETWEEN -34 AND 6
  AND geolocation_lng BETWEEN -74 AND -34
GROUP BY geolocation_zip_code_prefix;

ALTER TABLE geo_zip ADD PRIMARY KEY (zip_prefix);

-- 2. Model dataset: one row per delivered order (all 96,470)
CREATE OR REPLACE VIEW vw_model_data AS
SELECT d.order_id,
       d.order_purchase_timestamp,
       d.is_late                                                  AS target_is_late,
       d.promised_days,
       a.n_items,
       a.n_sellers,
       a.items_value,
       a.freight_total,
       ROUND(a.freight_total / NULLIF(a.items_value, 0), 3)       AS freight_ratio,
       c.customer_state,
       s.seller_state,
       (c.customer_state = s.seller_state)                        AS same_state,
       ROUND(ST_Distance_Sphere(POINT(gc.lng, gc.lat),
                                POINT(gs.lng, gs.lat)) / 1000, 1) AS distance_km,
       MONTH(d.order_purchase_timestamp)                          AS purchase_month,
       DAYOFWEEK(d.order_purchase_timestamp)                      AS purchase_dow
FROM vw_delivery_base d
JOIN customers          c  ON c.customer_id = d.customer_id
JOIN vw_order_items_agg a  ON a.order_id    = d.order_id
JOIN sellers            s  ON s.seller_id   = a.seller_id
LEFT JOIN geo_zip       gc ON gc.zip_prefix = c.customer_zip_code_prefix
LEFT JOIN geo_zip       gs ON gs.zip_prefix = s.seller_zip_code_prefix;

-- 3. Model table: orders with a known distance only (480 excluded, see DECISIONS D10)
DROP TABLE IF EXISTS model_data;

CREATE TABLE model_data AS
SELECT * FROM vw_model_data
WHERE distance_km IS NOT NULL;

ALTER TABLE model_data ADD PRIMARY KEY (order_id);

-- 4. Verification (expect rows_kept = 95,990)
SELECT COUNT(*) AS rows_kept FROM model_data;