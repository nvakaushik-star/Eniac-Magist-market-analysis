USE magist;

-- -----------------------------------------------------------------------------
-- ENIAC × MAGIST MARKET ANALYSIS
-- Purpose: evaluate marketplace scale, tech-market fit, seller economics and
-- delivery performance to support Eniac's Brazil market-entry decision.
-- -----------------------------------------------------------------------------

-- 1. How many orders are there in the dataset?
SELECT 
    COUNT(order_id) AS order_count
FROM orders;
-- Result: 99,441


-- 2. Are orders actually delivered?
SELECT 
    order_status,
    COUNT(order_id) AS order_count,
    ROUND(
        100 * COUNT(order_id) / (SELECT COUNT(order_id) FROM orders),
        2
    ) AS order_count_pct
FROM orders
GROUP BY order_status;
-- Observation: most orders were delivered (~97%).


-- 3. Is Magist having user/order growth?
SELECT 
    YEAR(order_purchase_timestamp) AS order_year,
    MONTH(order_purchase_timestamp) AS order_month,
    COUNT(order_id) AS order_count
FROM orders
GROUP BY order_year, order_month
ORDER BY order_year, order_month;
-- Observation: sudden drop after September 2018; likely dataset-boundary effect.


-- 4. How many products are there?
SELECT 
    COUNT(DISTINCT product_id) AS products_count
FROM products;
-- Result: 32,951


-- 5. Which categories have the most products?
SELECT 
    pt.product_category_name_english,
    COUNT(DISTINCT p.product_id) AS product_count
FROM product_category_name_translation pt
JOIN products p USING (product_category_name)
GROUP BY pt.product_category_name_english
ORDER BY product_count DESC
LIMIT 5;
-- Top categories: bed_bath_table, sports_leisure, furniture_decor,
-- health_beauty, housewares.


-- 6. What percentage of products were present in actual transactions?
SELECT 
    ROUND(
        100 * COUNT(DISTINCT oi.product_id) /
        (SELECT COUNT(DISTINCT product_id) FROM products),
        2
    ) AS active_product_pct
FROM order_items oi
JOIN products p USING (product_id);
-- Observation: all products appear in transactions.


-- 7. Most expensive and cheapest sold products
SELECT 
    MAX(price) AS max_price,
    MIN(price) AS min_price
FROM order_items;
-- Result: max 6,735; min 0.85


-- 8. Highest and lowest payment values
SELECT 
    MAX(payment_value) AS max_payment,
    MIN(payment_value) AS min_payment
FROM order_payments;
-- Result: max 13,664.10; min 0


-- 9. Which categories are treated as technology categories?
SELECT DISTINCT
    pt.product_category_name_english
FROM product_category_name_translation pt
JOIN products p USING (product_category_name)
WHERE
    pt.product_category_name_english LIKE '%computer%'
    OR pt.product_category_name_english LIKE '%pc%'
    OR pt.product_category_name_english LIKE '%phon%'
    OR pt.product_category_name_english LIKE '%electr%'
    OR pt.product_category_name_english LIKE '%consoles%'
    OR pt.product_category_name_english LIKE '%audio%'
    OR pt.product_category_name_english LIKE '%tablet%';
-- Identified categories include audio, consoles_games, electronics,
-- computers_accessories, pc_gamer, computers, tablets_printing_image,
-- telephony and fixed_telephony.


-- 10. How many technology products were sold and what share of units is that?
SELECT 
    COUNT(oi.product_id) AS tech_products_sold,
    ROUND(
        100 * COUNT(oi.product_id) /
        (SELECT COUNT(product_id) FROM order_items),
        2
    ) AS tech_products_sold_pct
FROM product_category_name_translation pt
JOIN products p USING (product_category_name)
JOIN order_items oi USING (product_id)
WHERE pt.product_category_name_english IN (
    'audio',
    'consoles_games',
    'electronics',
    'computers_accessories',
    'pc_gamer',
    'computers',
    'tablets_printing_image',
    'telephony'
);
-- Result: 16,935 tech units, 15.03% of all sold units.

SELECT 
    COUNT(product_id) AS total_products_sold
FROM order_items;
-- Result: 112,650 total units.


-- 11. Average sold-product price
SELECT 
    AVG(price) AS avg_price
FROM order_items;
-- Result: 120.65


-- 12. Are expensive technology products popular?
-- Use the top 15% of the tech price distribution as the "High" price tier.
WITH ranked AS (
    SELECT 
        pt.product_category_name_english,
        oi.order_id,
        CUME_DIST() OVER (ORDER BY oi.price) AS cd
    FROM product_category_name_translation pt
    JOIN products p USING (product_category_name)
    JOIN order_items oi USING (product_id)
    WHERE pt.product_category_name_english IN (
        'audio',
        'consoles_games',
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony'
    )
)
SELECT 
    CASE
        WHEN cd >= 0.85 THEN 'High'
        WHEN cd >= 0.50 THEN 'Medium'
        ELSE 'Low'
    END AS price_category,
    COUNT(DISTINCT o.customer_id) AS customers_count,
    ROUND(
        100 * COUNT(DISTINCT o.customer_id) /
        (SELECT COUNT(DISTINCT customer_id) FROM orders),
        2
    ) AS customer_count_pct
FROM ranked
JOIN orders o USING (order_id)
GROUP BY price_category;
-- Result: only 2.24% of historical customers ordered expensive tech products.


-- 13. How many months of data are included?
SELECT 
    COUNT(DISTINCT CONCAT(
        YEAR(order_purchase_timestamp),
        '-',
        MONTH(order_purchase_timestamp)
    )) AS months_count
FROM orders;
-- Result: 25 months.


-- 14. How many sellers and technology sellers are there?
SELECT 
    COUNT(DISTINCT seller_id) AS sellers_count
FROM sellers;
-- Result: 3,095 sellers.

WITH sellers_categories AS (
    SELECT 
        s.seller_id,
        pt.product_category_name_english
    FROM sellers s
    JOIN order_items oi USING (seller_id)
    JOIN products p USING (product_id)
    JOIN product_category_name_translation pt USING (product_category_name)
)
SELECT 
    COUNT(DISTINCT seller_id) AS tech_sellers_count,
    ROUND(
        100 * COUNT(DISTINCT seller_id) /
        (SELECT COUNT(DISTINCT seller_id) FROM sellers),
        2
    ) AS tech_sellers_pct
FROM sellers_categories
WHERE product_category_name_english IN (
    'audio',
    'consoles_games',
    'electronics',
    'computers_accessories',
    'pc_gamer',
    'computers',
    'tablets_printing_image',
    'telephony'
);
-- Result: 477 technology sellers (~15% of all sellers).


-- 15. Total marketplace seller revenue vs technology seller revenue
SELECT 
    SUM(price) AS total_earnings
FROM order_items;
-- Result: 13,591,643.70

WITH prices_tech AS (
    SELECT 
        oi.price,
        pt.product_category_name_english
    FROM sellers s
    JOIN order_items oi USING (seller_id)
    JOIN products p USING (product_id)
    JOIN product_category_name_translation pt USING (product_category_name)
    WHERE pt.product_category_name_english IN (
        'audio',
        'consoles_games',
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony'
    )
)
SELECT 
    SUM(price) AS tech_earnings,
    ROUND(
        100 * SUM(price) / (SELECT SUM(price) FROM order_items),
        2
    ) AS tech_earnings_pct
FROM prices_tech;
-- Result: 1,836,059.80; 13.51% of seller revenue.


-- 16a. Average monthly income across all sellers
WITH seller_month_income AS (
    SELECT 
        s.seller_id,
        CONCAT(
            YEAR(o.order_approved_at),
            '-',
            MONTH(o.order_approved_at)
        ) AS year_month,
        SUM(oi.price) AS income_month
    FROM sellers s
    JOIN order_items oi USING (seller_id)
    JOIN orders o USING (order_id)
    GROUP BY s.seller_id, year_month
)
SELECT 
    AVG(income_month) AS avg_monthly_income_per_seller
FROM seller_month_income;
-- Result: 826.28


-- 16b. Average monthly income of technology sellers
WITH seller_month_income_tech AS (
    SELECT 
        s.seller_id,
        CONCAT(
            YEAR(o.order_approved_at),
            '-',
            MONTH(o.order_approved_at)
        ) AS year_month,
        SUM(oi.price) AS income_month
    FROM sellers s
    JOIN order_items oi USING (seller_id)
    JOIN orders o USING (order_id)
    JOIN products p USING (product_id)
    JOIN product_category_name_translation pt USING (product_category_name)
    WHERE pt.product_category_name_english IN (
        'audio',
        'consoles_games',
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony'
    )
    GROUP BY s.seller_id, year_month
)
SELECT 
    AVG(income_month) AS avg_monthly_income_tech_seller
FROM seller_month_income_tech;
-- Result: 792.09, below the marketplace average of 826.28.


-- 17. Average time between order placement and delivery
WITH time_interval AS (
    SELECT 
        TIMESTAMPDIFF(
            DAY,
            order_purchase_timestamp,
            order_delivered_customer_date
        ) AS waiting_time
    FROM orders
)
SELECT 
    AVG(waiting_time) AS avg_waiting_time
FROM time_interval;
-- Result: ~12 days.


-- 18. Orders delivered on time vs delayed
SELECT 
    CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 'On time'
        WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 'Delayed'
        ELSE 'Unknown'
    END AS delivery_status,
    COUNT(order_id) AS order_count,
    ROUND(
        100 * COUNT(order_id) / (SELECT COUNT(order_id) FROM orders),
        2
    ) AS order_count_pct
FROM orders
GROUP BY delivery_status
ORDER BY order_count DESC;
-- Results: 88,649 on time (89.15%); 7,827 delayed (7.87%).


-- 19. Does order weight appear related to delivery delays?
WITH order_status_weight AS (
    SELECT 
        o.order_id,
        CASE
            WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 'On time'
            WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'Delayed'
            ELSE 'Unknown'
        END AS delivery_status,
        SUM(product_weight_g) AS order_weight_g
    FROM orders o
    JOIN order_items oi USING (order_id)
    JOIN products p USING (product_id)
    GROUP BY o.order_id
)
SELECT 
    delivery_status,
    AVG(order_weight_g) AS avg_weight_g
FROM order_status_weight
GROUP BY delivery_status;
-- Observation: weight does not appear to explain late delivery in this analysis.
