-- =====================================================
-- 08_model_checks.sql : checks on the model dataset (read-only)
-- Requires 08_model_data.sql
-- =====================================================
USE olist;

-- 1. Distance feature health (all 96,470 orders, before exclusions)
SELECT COUNT(*)                   AS rows_,
       COUNT(DISTINCT order_id)   AS distinct_orders,
       SUM(distance_km IS NULL)   AS no_distance,
       ROUND(AVG(distance_km), 0) AS avg_km,
       ROUND(MIN(distance_km), 0) AS min_km,
       ROUND(MAX(distance_km), 0) AS max_km
FROM vw_model_data;

-- 2. Where are the 480 orders with no distance?
SELECT customer_state,
       COUNT(*)                                       AS orders,
       ROUND(100 * SUM(target_is_late) / COUNT(*), 2) AS late_pct
FROM vw_model_data
WHERE distance_km IS NULL
GROUP BY customer_state
ORDER BY orders DESC
LIMIT 10;

-- 3. Which side's ZIP prefix is missing? (expect 265 customer, 216 seller)
SELECT SUM(gc.zip_prefix IS NULL) AS customer_zip_missing,
       SUM(gs.zip_prefix IS NULL) AS seller_zip_missing
FROM vw_model_data m
JOIN orders o             ON o.order_id    = m.order_id
JOIN customers c          ON c.customer_id = o.customer_id
JOIN vw_order_items_agg a ON a.order_id    = m.order_id
JOIN sellers s            ON s.seller_id   = a.seller_id
LEFT JOIN geo_zip gc      ON gc.zip_prefix = c.customer_zip_code_prefix
LEFT JOIN geo_zip gs      ON gs.zip_prefix = s.seller_zip_code_prefix
WHERE m.distance_km IS NULL;

-- 4. Does lateness rise with distance?
SELECT CASE
           WHEN distance_km <  100 THEN '1. under 100 km'
           WHEN distance_km <  500 THEN '2. 100-500 km'
           WHEN distance_km < 1000 THEN '3. 500-1,000 km'
           WHEN distance_km < 2000 THEN '4. 1,000-2,000 km'
           ELSE                         '5. 2,000+ km'
       END                                              AS distance_band,
       COUNT(*)                                         AS orders,
       ROUND(100 * SUM(target_is_late) / COUNT(*), 2)   AS late_pct,
       ROUND(AVG(promised_days), 1)                     AS avg_promised
FROM vw_model_data
WHERE distance_km IS NOT NULL
GROUP BY distance_band
ORDER BY distance_band;