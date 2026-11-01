USE olist;
-- 1. Headline KPI: delivered orders, late orders, late %, problem rows
SELECT COUNT(*)                                AS delivered_orders,
       SUM(is_late)                            AS late_orders,
       ROUND(100 * SUM(is_late) / COUNT(*), 2) AS late_pct,
       SUM(timeline_ok = 0)                    AS timeline_problem_rows
FROM vw_delivery_base;
SELECT
  SUM(DATE(order_delivered_carrier_date) < DATE(order_purchase_timestamp))     AS pickup_before_purchase,
  SUM(DATE(order_delivered_customer_date) < DATE(order_delivered_carrier_date)) AS delivery_before_pickup
FROM vw_delivery_base;

SELECT
  ROUND(100 * SUM(order_delivered_customer_date > order_estimated_delivery_date) / COUNT(*), 2) AS late_pct_timestamp,
  ROUND(100 * SUM(is_late) / COUNT(*), 2)                                                      AS late_pct_date_level
FROM vw_delivery_base;

SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS purchase_month,
       COUNT(*)                                       AS orders,
       ROUND(100 * SUM(is_late) / COUNT(*), 2)        AS late_pct
FROM vw_delivery_base
GROUP BY purchase_month
ORDER BY purchase_month;

SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m')                    AS purchase_month,
       COUNT(*)                                                          AS orders,
       ROUND(AVG(seller_handling_days), 2)                               AS avg_handling_days,
       ROUND(AVG(carrier_transit_days), 2)                               AS avg_transit_days,
       ROUND(AVG(DATEDIFF(DATE(order_estimated_delivery_date),
                          DATE(order_purchase_timestamp))), 2)           AS avg_promised_days,
       ROUND(100 * SUM(is_late) / COUNT(*), 2)                           AS late_pct
FROM vw_delivery_base
WHERE timeline_ok = 1
  AND order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp <  '2018-09-01'
GROUP BY purchase_month
ORDER BY purchase_month;