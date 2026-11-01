-- =====================================================
-- 03_views.sql : saved definitions the analysis queries read from
-- Run the whole file top to bottom. Order matters: a view must exist
-- before another view reads from it.
-- =====================================================
USE olist;

-- 1. Delivered orders with delay and stage measures (one row per order)
CREATE OR REPLACE VIEW vw_delivery_base AS
SELECT
    order_id,
    customer_id,
    order_purchase_timestamp,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    DATEDIFF(DATE(order_delivered_customer_date),
             DATE(order_estimated_delivery_date))               AS delay_days,
    DATEDIFF(DATE(order_estimated_delivery_date),
             DATE(order_purchase_timestamp))                    AS promised_days,
    (DATE(order_delivered_customer_date) >
     DATE(order_estimated_delivery_date))                       AS is_late,
    DATEDIFF(DATE(order_delivered_carrier_date),
             DATE(order_purchase_timestamp))                    AS seller_handling_days,
    DATEDIFF(DATE(order_delivered_customer_date),
             DATE(order_delivered_carrier_date))                AS carrier_transit_days,
    CASE
        WHEN order_delivered_carrier_date IS NULL THEN 0
        WHEN DATE(order_delivered_carrier_date) < DATE(order_purchase_timestamp) THEN 0
        WHEN DATE(order_delivered_customer_date) < DATE(order_delivered_carrier_date) THEN 0
        ELSE 1
    END                                                         AS timeline_ok
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;

-- 2. One review per order (newest review wins)
CREATE OR REPLACE VIEW vw_review_one AS
SELECT order_id, review_id, review_score
FROM (
    SELECT order_id, review_id, review_score,
           ROW_NUMBER() OVER (
               PARTITION BY order_id
               ORDER BY review_creation_date DESC, review_answer_timestamp DESC
           ) AS rn
    FROM order_reviews
) AS ranked
WHERE rn = 1;

-- 3. Items collapsed to one row per order
CREATE OR REPLACE VIEW vw_order_items_agg AS
SELECT order_id,
       COUNT(*)                     AS n_items,
       COUNT(DISTINCT seller_id)    AS n_sellers,
       MIN(seller_id)               AS seller_id,
       ROUND(SUM(price), 2)         AS items_value,
       ROUND(SUM(freight_value), 2) AS freight_total
FROM order_items
GROUP BY order_id;

-- 4. Order summary: one row per delivered order
CREATE OR REPLACE VIEW vw_order_summary AS
SELECT d.order_id,
       d.order_purchase_timestamp,
       d.delay_days,
       d.promised_days,
       d.is_late,
       d.seller_handling_days,
       d.carrier_transit_days,
       d.timeline_ok,
       c.customer_state,
       s.seller_state,
       (c.customer_state = s.seller_state)                         AS same_state,
       a.n_items,
       a.n_sellers,
       a.items_value,
       a.freight_total,
       ROUND(a.freight_total / NULLIF(a.items_value, 0), 3)        AS freight_ratio,
       r.review_score
FROM vw_delivery_base d
LEFT JOIN customers          c ON c.customer_id = d.customer_id
LEFT JOIN vw_order_items_agg a ON a.order_id    = d.order_id
LEFT JOIN sellers            s ON s.seller_id   = a.seller_id
LEFT JOIN vw_review_one      r ON r.order_id    = d.order_id;




