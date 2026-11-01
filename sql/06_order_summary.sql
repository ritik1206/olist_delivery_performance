USE olist;

-- A. Late rate by customer state (window 2017-01 to 2018-08, states with 200+ orders)
SELECT customer_state,
       COUNT(*)                                AS orders,
       SUM(is_late)                            AS late_orders,
       ROUND(100 * SUM(is_late) / COUNT(*), 2) AS late_pct,
       ROUND(AVG(carrier_transit_days), 1)     AS avg_transit_days
FROM vw_order_summary
WHERE order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp <  '2018-09-01'
GROUP BY customer_state
HAVING COUNT(*) >= 200
ORDER BY late_pct DESC;

-- B. Promise buffer by customer state (tests the "tight promise" hypothesis)
SELECT customer_state,
       COUNT(*)                                                   AS orders,
       ROUND(100 * SUM(is_late) / COUNT(*), 2)                    AS late_pct,
       ROUND(AVG(seller_handling_days), 1)                        AS avg_handling,
       ROUND(AVG(carrier_transit_days), 1)                        AS avg_transit,
       ROUND(AVG(promised_days), 1)                               AS avg_promised,
       ROUND(AVG(promised_days - seller_handling_days
                               - carrier_transit_days), 1)        AS avg_buffer
FROM vw_order_summary
WHERE timeline_ok = 1
  AND order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp <  '2018-09-01'
GROUP BY customer_state
HAVING COUNT(*) >= 200
ORDER BY late_pct DESC;

-- C. Top lanes (seller state to customer state) by number of late orders
SELECT seller_state, customer_state,
       COUNT(*)                                                   AS orders,
       SUM(is_late)                                               AS late_orders,
       ROUND(100 * SUM(is_late) / COUNT(*), 2)                    AS late_pct,
       ROUND(AVG(carrier_transit_days), 1)                        AS avg_transit,
       ROUND(AVG(promised_days), 1)                               AS avg_promised,
       ROUND(AVG(promised_days - seller_handling_days
                               - carrier_transit_days), 1)        AS avg_buffer
FROM vw_order_summary
WHERE n_sellers = 1
  AND timeline_ok = 1
  AND seller_state IS NOT NULL
  AND order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp <  '2018-09-01'
GROUP BY seller_state, customer_state
HAVING COUNT(*) >= 300
ORDER BY late_orders DESC
LIMIT 15;

-- D. Monthly late % for SP, RJ and MG customers (structural problem or spike?)
SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS purchase_month,
       ROUND(100 * SUM(CASE WHEN customer_state = 'SP' THEN is_late END)
                 / SUM(customer_state = 'SP'), 2)      AS sp_late_pct,
       ROUND(100 * SUM(CASE WHEN customer_state = 'RJ' THEN is_late END)
                 / SUM(customer_state = 'RJ'), 2)      AS rj_late_pct,
       ROUND(100 * SUM(CASE WHEN customer_state = 'MG' THEN is_late END)
                 / SUM(customer_state = 'MG'), 2)      AS mg_late_pct
FROM vw_order_summary
WHERE order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp <  '2018-09-01'
GROUP BY purchase_month
ORDER BY purchase_month;

SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m')               AS purchase_month,
       COUNT(*)                                                     AS orders,
       SUM(is_late)                                                 AS late_orders,
       ROUND(100 * SUM(is_late) / COUNT(*), 2)                      AS late_pct,
       ROUND(AVG(seller_handling_days), 1)                          AS avg_handling,
       ROUND(AVG(carrier_transit_days), 1)                          AS avg_transit,
       ROUND(AVG(promised_days), 1)                                 AS avg_promised,
       ROUND(AVG(promised_days - seller_handling_days
                               - carrier_transit_days), 1)          AS avg_buffer
FROM vw_order_summary
WHERE customer_state = 'RJ'
  AND timeline_ok = 1
  AND order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp <  '2018-09-01'
GROUP BY purchase_month
ORDER BY purchase_month;

SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m')                    AS purchase_month,
       CASE WHEN customer_state = 'RJ' THEN 'RJ' ELSE 'rest of Brazil' END AS region,
       COUNT(*)                                                           AS orders,
       ROUND(100 * SUM(is_late) / COUNT(*), 2)                            AS late_pct,
       ROUND(AVG(carrier_transit_days), 1)                                AS avg_transit,
       ROUND(AVG(promised_days - seller_handling_days
                               - carrier_transit_days), 1)                AS avg_buffer
FROM vw_order_summary
WHERE timeline_ok = 1
  AND order_purchase_timestamp >= '2017-09-01'
  AND order_purchase_timestamp <  '2018-06-01'
GROUP BY purchase_month, region
ORDER BY purchase_month, region;

-- E. Same state vs different state (all of Brazil)
SELECT CASE WHEN same_state = 1 THEN 'same state' ELSE 'different state' END AS route,
       COUNT(*)                                AS orders,
       ROUND(100 * SUM(is_late) / COUNT(*), 2) AS late_pct,
       ROUND(AVG(carrier_transit_days), 1)     AS avg_transit_days
FROM vw_order_summary
WHERE same_state IS NOT NULL AND n_sellers = 1 AND timeline_ok = 1
  AND order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp <  '2018-09-01'
GROUP BY route;

-- F. Same vs different state, controlling for customer state (SP, RJ, MG)
SELECT customer_state,
       CASE WHEN same_state = 1 THEN 'same state' ELSE 'different state' END AS route,
       COUNT(*)                                AS orders,
       ROUND(100 * SUM(is_late) / COUNT(*), 2) AS late_pct,
       ROUND(AVG(carrier_transit_days), 1)     AS avg_transit_days
FROM vw_order_summary
WHERE customer_state IN ('SP', 'RJ', 'MG')
  AND same_state IS NOT NULL AND n_sellers = 1 AND timeline_ok = 1
  AND order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp <  '2018-09-01'
GROUP BY customer_state, route
ORDER BY customer_state, route;

-- G. Which seller states ship to RJ customers
SELECT seller_state,
       COUNT(*)                                AS orders,
       ROUND(100 * SUM(is_late) / COUNT(*), 2) AS late_pct,
       ROUND(AVG(seller_handling_days), 1)     AS avg_handling,
       ROUND(AVG(carrier_transit_days), 1)     AS avg_transit
FROM vw_order_summary
WHERE customer_state = 'RJ' AND n_sellers = 1 AND timeline_ok = 1
  AND order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp <  '2018-09-01'
GROUP BY seller_state
HAVING COUNT(*) >= 100
ORDER BY orders DESC;