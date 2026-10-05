SELECT 
    COUNT(*) AS total_orders,
    ROUND(SUM(o.quantity * p.price * (1 - COALESCE(o.discount_pct, 0) / 100)), 2) AS total_revenue,
    ROUND(AVG(o.quantity * p.price * (1 - COALESCE(o.discount_pct, 0) / 100)), 2) AS avg_order_value
FROM orders o
JOIN products p ON o.product_id = p.product_id;


SELECT 
    COUNT(*) AS total_rows,
    COUNT(rating) AS rated_orders,
    (COUNT(*) - COUNT(rating)) AS unrated
FROM orders;

-- Query 1: LEFT JOIN se zero orders wale customer dhoondhna
SELECT 
    c.customer_id, 
    c.name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(o.order_id) = 0;

-- Query 2: NOT IN subquery se confirm karna
SELECT 
    customer_id, 
    name
FROM customers
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id 
    FROM orders 
    WHERE customer_id IS NOT NULL
);

SELECT 
    c.city,
    COUNT(o.order_id) AS total_orders,
    SUM(CASE WHEN o.returned = 1 THEN 1 ELSE 0 END) AS returned_orders,
    ROUND((SUM(CASE WHEN o.returned = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(o.order_id)), 1) AS return_rate_pct
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.city
HAVING return_rate_pct > 20
ORDER BY return_rate_pct DESC;

-- Query 1: Top 5 customers (LIMIT 5)
SELECT 
    c.customer_id,
    c.name,
    ROUND(SUM(o.quantity * p.price * (1 - COALESCE(o.discount_pct, 0) / 100)), 2) AS total_spend
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id
GROUP BY c.customer_id, c.name
ORDER BY total_spend DESC, c.customer_id ASC
LIMIT 5;

-- Query 2: Ranks 3 to 5 (LIMIT 3 OFFSET 2)
SELECT 
    c.customer_id,
    c.name,
    ROUND(SUM(o.quantity * p.price * (1 - COALESCE(o.discount_pct, 0) / 100)), 2) AS total_spend
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id
GROUP BY c.customer_id, c.name
ORDER BY total_spend DESC, c.customer_id ASC
LIMIT 3 OFFSET 2;

SELECT 
    p.category,
    COUNT(o.order_id) AS order_count,
    ROUND(SUM(o.quantity * p.price * (1 - COALESCE(o.discount_pct, 0) / 100)), 2) AS category_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY p.category
ORDER BY category_revenue DESC;

SELECT * 
FROM customers
WHERE name LIKE 'A%';

SELECT DISTINCT acquisition_source
FROM customers
ORDER BY acquisition_source ASC;

-- Step 1: Column Add Karein
ALTER TABLE customers 
ADD COLUMN loyalty_tier VARCHAR(10);

-- Step 2: Values Update Karein
UPDATE customers
SET loyalty_tier = CASE 
    WHEN city_tier = 1 THEN 'Gold' 
    ELSE 'Silver' 
END;

-- Safe updates off karein
SET SQL_SAFE_UPDATES = 0;

-- Step 2: UPDATE chalayein
UPDATE customers
SET loyalty_tier = CASE 
    WHEN city_tier = 1 THEN 'Gold' 
    ELSE 'Silver' 
END;

-- Safe updates off karein
SET SQL_SAFE_UPDATES = 0;

-- Step 2: UPDATE chalayein
UPDATE customers
SET loyalty_tier = CASE 
    WHEN city_tier = 1 THEN 'Gold' 
    ELSE 'Silver' 
END;

-- Safe updates off karein
SET SQL_SAFE_UPDATES = 0;

-- Step 2: UPDATE chalayein
UPDATE customers
SET loyalty_tier = CASE 
    WHEN city_tier = 1 THEN 'Gold' 
    ELSE 'Silver' 
END;

SET SQL_SAFE_UPDATES = 0;
UPDATE customers
SET loyalty_tier = CASE 
    WHEN city_tier = 1 THEN 'Gold' 
    ELSE 'Silver' 
END;
SELECT loyalty_tier, COUNT(*) 
FROM customers 
GROUP BY loyalty_tier;




