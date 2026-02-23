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