-- ============================================================
-- Task 3 — Reports (sql/reports.sql)
-- ============================================================

-- a) Order totals
-- Output:
-- total_orders | total_revenue | avg_order_value
-- -------------+---------------+----------------
-- 180          | 99860.20      | 554.78
SELECT 
    COUNT(*) AS total_orders,
    ROUND(SUM(o.quantity * p.price * (1 - COALESCE(o.discount_pct, 0) / 100)), 2) AS total_revenue,
    ROUND(AVG(o.quantity * p.price * (1 - COALESCE(o.discount_pct, 0) / 100)), 2) AS avg_order_value
FROM orders o
JOIN products p ON o.product_id = p.product_id;


-- b) COUNT(*) vs COUNT(column)
-- Output:
-- total_rows | rated_orders | unrated
-- -----------+--------------+---------
-- 180        | 165          | 15
SELECT 
    COUNT(*) AS total_rows,
    COUNT(rating) AS rated_orders,
    (COUNT(*) - COUNT(rating)) AS unrated
FROM orders;


-- c) LEFT JOIN with a genuine zero-match row
-- Output (Query 1 & Query 2 both return):
-- customer_id | name
-- -------------+--------
-- C045        | Vihaan

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


-- d) GROUP BY + HAVING
-- Output:
-- city      | total_orders | returned_orders | return_rate_pct
-- ----------+--------------+-----------------+----------------
-- Jaipur    | 19           | 8               | 42.1
-- Lucknow   | 49           | 15              | 30.6
-- Bangalore | 33           | 8               | 24.2
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


-- e) Ranking with ORDER BY + LIMIT/OFFSET
-- Tie-break comment: customer_id ASC tie-breaker ensures deterministic ranking when multiple customers have identical total spend.

-- Query 1 Output (Top 5):
-- C043 | Reyansh | 12920.00
-- C026 | Isha    | 8371.60
-- C008 | Meera   | 4564.60
-- C011 | Arjun   | 4111.00
-- C042 | Sanya   | 3785.00
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

-- Query 2 Output (Ranks 3-5):
-- C008 | Meera | 4564.60
-- C011 | Arjun | 4111.00
-- C042 | Sanya | 3785.00
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


-- f) Three-table JOIN with GROUP BY
-- Output:
-- category     | order_count | category_revenue
-- -------------+-------------+-----------------
-- Haircare     | 54          | 44956.10
-- Skincare     | 60          | 27346.00
-- Babycare     | 30          | 16805.00
-- PersonalCare | 36          | 10753.10
SELECT 
    p.category,
    COUNT(o.order_id) AS order_count,
    ROUND(SUM(o.quantity * p.price * (1 - COALESCE(o.discount_pct, 0) / 100)), 2) AS category_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY p.category
ORDER BY category_revenue DESC;


-- g) LIKE pattern match
-- Output: Returns exactly 10 rows (Aarav, Aditi, Ananya, Arjun, Aryan, Anika, Aditya, Aisha, Ayaan, Aria)
SELECT * 
FROM customers
WHERE name LIKE 'A%';


-- h) DISTINCT
-- Output: 4 distinct values (Ad, Organic, Referral, Social)
SELECT DISTINCT acquisition_source
FROM customers
ORDER BY acquisition_source ASC;


-- i) ALTER TABLE + UPDATE with CASE
-- Output:
-- loyalty_tier | COUNT(*)
-- -------------+---------
-- Gold         | 28
-- Silver       | 17

-- Step 1: Column addition
ALTER TABLE customers ADD COLUMN loyalty_tier VARCHAR(10);

-- Step 2: Update with CASE
UPDATE customers
SET loyalty_tier = CASE 
    WHEN city_tier = 1 THEN 'Gold' 
    ELSE 'Silver' 
END;

-- Step 3: Verification Query
SELECT loyalty_tier, COUNT(*) 
FROM customers 
GROUP BY loyalty_tier;
