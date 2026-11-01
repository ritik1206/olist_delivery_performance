USE olist;

-- 1. Check the review table
SELECT COUNT(*)                     AS rows_loaded,
       COUNT(DISTINCT review_id)    AS distinct_review_ids,
       COUNT(DISTINCT order_id)     AS distinct_orders,
       SUM(review_creation_date IS NULL OR review_answer_timestamp IS NULL) AS null_date_rows
FROM order_reviews;

-- 2. Grain check: how many reviews does each order have?
SELECT reviews_per_order, COUNT(*) AS orders
FROM (
    SELECT order_id, COUNT(*) AS reviews_per_order
    FROM order_reviews
    GROUP BY order_id
) AS per_order
GROUP BY reviews_per_order
ORDER BY reviews_per_order;

-- 2b. Verify the view: both numbers should equal distinct_orders from query 1
SELECT COUNT(*) AS rows_in_view, COUNT(DISTINCT order_id) AS distinct_orders
FROM vw_review_one;

-- 3. Late vs on-time: average score and share of 1-star reviews
SELECT CASE WHEN d.is_late = 1 THEN 'late' ELSE 'on time' END AS delivery,
       COUNT(*)                                               AS orders,
       ROUND(AVG(r.review_score), 2)                          AS avg_score,
       ROUND(100 * SUM(r.review_score = 1) / COUNT(*), 1)     AS pct_1_star
FROM vw_delivery_base d
JOIN vw_review_one r ON r.order_id = d.order_id
GROUP BY delivery;

-- 4. Does the size of the delay matter?
SELECT CASE
           WHEN d.delay_days <= 0 THEN '1. on time or early'
           WHEN d.delay_days <= 3 THEN '2. 1-3 days late'
           WHEN d.delay_days <= 7 THEN '3. 4-7 days late'
           ELSE                        '4. 8+ days late'
       END                                                AS delay_bucket,
       COUNT(*)                                           AS orders,
       ROUND(AVG(r.review_score), 2)                      AS avg_score,
       ROUND(100 * SUM(r.review_score = 1) / COUNT(*), 1) AS pct_1_star
FROM vw_delivery_base d
JOIN vw_review_one r ON r.order_id = d.order_id
GROUP BY delay_bucket
ORDER BY delay_bucket;

SELECT COUNT(*) AS delivered_without_review
FROM vw_delivery_base d
LEFT JOIN vw_review_one r ON r.order_id = d.order_id
WHERE r.order_id IS NULL;