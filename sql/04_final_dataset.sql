CREATE OR REPLACE VIEW final_customer_features AS
SELECT
    c.customer_id,
    r.recency_days,
    f.total_orders,
    m.total_spend,
    a.avg_order_value,
    COALESCE(cl.churn, 1) AS churn
FROM customers c
LEFT JOIN customer_recency r USING(customer_id)
LEFT JOIN customer_frequency f USING(customer_id)
LEFT JOIN customer_monetary m USING(customer_id)
LEFT JOIN customer_aov a USING(customer_id)
LEFT JOIN churn_labels cl USING(customer_id);