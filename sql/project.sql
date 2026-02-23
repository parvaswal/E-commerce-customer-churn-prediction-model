create database Ecommerce_churn ;
use Ecommerce_churn;
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    orede_estimated_delivery_date DATETIME,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DOUBLE,
    freight_value DOUBLE,
    PRIMARY KEY(order_id, order_item_id)
);
CREATE TABLE payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DOUBLE
);
SHOW VARIABLES LIKE 'secure_file_priv';
SET GLOBAL local_infile = 1;
CREATE  VIEW customer_recency AS
SELECT
    customer_id,
    DATEDIFF(
        (SELECT DATE_SUB(MAX(order_purchase_timestamp), INTERVAL 60 DAY) FROM orders),
        MAX(order_purchase_timestamp)
    ) AS recency_days
FROM orders
WHERE order_purchase_timestamp <
      (SELECT DATE_SUB(MAX(order_purchase_timestamp), INTERVAL 60 DAY) FROM orders)
GROUP BY customer_id;
CREATE OR REPLACE VIEW customer_frequency AS
SELECT
    customer_id,
    COUNT(order_id) AS total_orders
FROM orders
WHERE order_purchase_timestamp <
      (SELECT DATE_SUB(MAX(order_purchase_timestamp), INTERVAL 60 DAY) FROM orders)
GROUP BY customer_id;
CREATE OR REPLACE VIEW customer_monetary AS
SELECT
    o.customer_id,
    SUM(oi.price) AS total_spend
FROM orders o
JOIN order_items oi 
    ON o.order_id = oi.order_id
WHERE o.order_purchase_timestamp <
      (SELECT DATE_SUB(MAX(order_purchase_timestamp), INTERVAL 60 DAY) FROM orders)
GROUP BY o.customer_id;

CREATE VIEW customer_aov AS
SELECT
    o.customer_id,
    SUM(oi.price) / COUNT(DISTINCT o.order_id) AS avg_order_value
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY o.customer_id;
CREATE OR REPLACE VIEW churn_labels AS
SELECT
    c.customer_id,
    CASE
        WHEN COUNT(o.order_id) = 0 THEN 1
        ELSE 0
    END AS churn
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
    AND o.order_purchase_timestamp >=
        (SELECT DATE_SUB(MAX(order_purchase_timestamp), INTERVAL 60 DAY) FROM orders)
GROUP BY c.customer_id;
CREATE VIEW final_customer_features AS
SELECT
    c.customer_id,
    r.recency_days,
    f.total_orders,
    m.total_spend,
    a.avg_order_value,
    COALESCE(cl.churn, 1) AS churn
FROM customers c
LEFT JOIN customer_recency r ON c.customer_id = r.customer_id
LEFT JOIN customer_frequency f ON c.customer_id = f.customer_id
LEFT JOIN customer_monetary m ON c.customer_id = m.customer_id
LEFT JOIN customer_aov a ON c.customer_id = a.customer_id
LEFT JOIN churn_labels cl ON c.customer_id = cl.customer_id;
SELECT COUNT(*) FROM final_customer_features;
SELECT churn, COUNT(*)
FROM final_customer_features
GROUP BY churn;
SELECT * FROM final_customer_features;
SELECT MAX(order_purchase_timestamp) FROM orders;
SELECT churn, COUNT(*)
FROM final_customer_features
GROUP BY churn;
