CREATE OR REPLACE VIEW customer_recency AS
SELECT
    customer_id,
    DATEDIFF(
        (SELECT DATE_SUB(MAX(order_purchase_timestamp), INTERVAL 180 DAY) FROM orders),
        MAX(order_purchase_timestamp)
    ) AS recency_days
FROM orders
WHERE order_purchase_timestamp <
      (SELECT DATE_SUB(MAX(order_purchase_timestamp), INTERVAL 180 DAY) FROM orders)
GROUP BY customer_id;

CREATE OR REPLACE VIEW customer_frequency AS
SELECT
    customer_id,
    COUNT(*) AS total_orders
FROM orders
WHERE order_purchase_timestamp <
      (SELECT DATE_SUB(MAX(order_purchase_timestamp), INTERVAL 180 DAY) FROM orders)
GROUP BY customer_id;

CREATE OR REPLACE VIEW customer_monetary AS
SELECT
    o.customer_id,
    SUM(oi.price) AS total_spend
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_purchase_timestamp <
      (SELECT DATE_SUB(MAX(order_purchase_timestamp), INTERVAL 180 DAY) FROM orders)
GROUP BY o.customer_id;

CREATE OR REPLACE VIEW customer_aov AS           -- now with the cutoff filter
SELECT
    o.customer_id,
    SUM(oi.price) / COUNT(DISTINCT o.order_id) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_purchase_timestamp <
      (SELECT DATE_SUB(MAX(order_purchase_timestamp), INTERVAL 180 DAY) FROM orders)
GROUP BY o.customer_id;

CREATE OR REPLACE VIEW churn_labels AS
SELECT
    c.customer_id,
    CASE WHEN COUNT(o.order_id) = 0 THEN 1 ELSE 0 END AS churn
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
   AND o.order_purchase_timestamp >=
       (SELECT DATE_SUB(MAX(order_purchase_timestamp), INTERVAL 180 DAY) FROM orders)
GROUP BY c.customer_id;

