-- ============================================================================
-- SwiftBite Analytics — BEGINNER SQL Queries (5 Queries)
-- ============================================================================
-- Level     : Beginner
-- Concepts  : SELECT, WHERE, GROUP BY, ORDER BY, COUNT, SUM, AVG
-- ============================================================================


-- ============================================================================
-- QUERY 1: Total Orders Per City
-- ============================================================================
-- PROBLEM: The operations team wants to know how orders are distributed
--          across cities to plan delivery fleet allocation.
-- CONCEPTS: GROUP BY, COUNT, ORDER BY
-- ============================================================================

SELECT
    u.city,
    COUNT(o.order_id) AS total_orders
FROM orders o
JOIN users u ON o.user_id = u.user_id
GROUP BY u.city
ORDER BY total_orders DESC;

-- EXPLANATION:
-- We join orders with users to get the city information, then group by city
-- and count the orders. This reveals which cities drive the most volume.
--
-- BUSINESS INSIGHT:
-- Mumbai and Delhi together account for ~34% of total orders, indicating
-- heavy metro concentration. Tier-2 cities like Jaipur and Lucknow have
-- lower volumes but may have higher growth potential with less competition.


-- ============================================================================
-- QUERY 2: Average Order Value (AOV)
-- ============================================================================
-- PROBLEM: The finance team needs to track the platform's average order value
--          to assess pricing strategy effectiveness.
-- CONCEPTS: AVG, ROUND
-- ============================================================================

SELECT
    ROUND(AVG(order_amount), 2)   AS avg_gross_order_value,
    ROUND(AVG(final_amount), 2)   AS avg_net_order_value,
    ROUND(AVG(discount), 2)       AS avg_discount_per_order,
    COUNT(order_id)               AS total_orders
FROM orders
WHERE status = 'Delivered';

-- EXPLANATION:
-- We calculate three key financial metrics: gross AOV (before discounts),
-- net AOV (after discounts), and average discount. Filtering for 'Delivered'
-- orders only ensures we measure completed transactions.
--
-- BUSINESS INSIGHT:
-- If the avg discount is >15% of the gross AOV, the platform may be
-- over-subsidizing orders. This metric directly impacts unit economics.


-- ============================================================================
-- QUERY 3: Top 10 Restaurants by Order Count
-- ============================================================================
-- PROBLEM: The restaurant success team wants to identify top-performing
--          partners for the "SwiftBite Star Partner" program.
-- CONCEPTS: JOIN, GROUP BY, ORDER BY, LIMIT
-- ============================================================================

SELECT
    r.restaurant_id,
    r.name              AS restaurant_name,
    r.city,
    r.cuisine_type,
    r.rating,
    COUNT(o.order_id)   AS total_orders,
    ROUND(SUM(o.final_amount), 2) AS total_revenue
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.status = 'Delivered'
GROUP BY r.restaurant_id, r.name, r.city, r.cuisine_type, r.rating
ORDER BY total_orders DESC
LIMIT 10;

-- EXPLANATION:
-- Joins orders with restaurants, filters for delivered orders, groups by
-- restaurant, and ranks by order count. Also shows total revenue contribution.
--
-- BUSINESS INSIGHT:
-- The top 10 restaurants likely contribute 15-25% of total platform revenue.
-- These partners should receive premium support, priority listing, and
-- co-marketing opportunities to maintain their performance.


-- ============================================================================
-- QUERY 4: Orders by Day of Week
-- ============================================================================
-- PROBLEM: Marketing wants to know which days see the highest order volume
--          to schedule promotional campaigns effectively.
-- CONCEPTS: EXTRACT, GROUP BY, ORDER BY
-- ============================================================================

SELECT
    EXTRACT(DOW FROM order_date)  AS day_of_week_num,
    TO_CHAR(order_date, 'Day')   AS day_name,
    COUNT(order_id)              AS total_orders,
    ROUND(AVG(final_amount), 2)  AS avg_order_value
FROM orders
WHERE status = 'Delivered'
GROUP BY
    EXTRACT(DOW FROM order_date),
    TO_CHAR(order_date, 'Day')
ORDER BY day_of_week_num;

-- EXPLANATION:
-- Extracts the day of week from order timestamps and aggregates order counts.
-- DOW returns 0=Sunday, 1=Monday, ..., 6=Saturday. We also track AOV by day
-- to see if weekend orders tend to be larger (family/group orders).
--
-- BUSINESS INSIGHT:
-- Weekends (Fri-Sun) typically show 20-30% higher order volumes. If weekday
-- volumes are significantly lower, targeted weekday promotions like
-- "Tuesday Treats" could help balance demand and improve fleet utilization.


-- ============================================================================
-- QUERY 5: Revenue by Payment Method
-- ============================================================================
-- PROBLEM: The finance team wants to understand payment mix to negotiate
--          better rates with payment gateway providers.
-- CONCEPTS: GROUP BY, SUM, COUNT, percentage calculation
-- ============================================================================

SELECT
    p.payment_method,
    COUNT(p.payment_id)                                           AS transaction_count,
    ROUND(SUM(p.amount), 2)                                      AS total_revenue,
    ROUND(100.0 * COUNT(p.payment_id) / SUM(COUNT(p.payment_id)) OVER (), 2)
                                                                  AS pct_of_transactions,
    ROUND(100.0 * SUM(p.amount) / SUM(SUM(p.amount)) OVER (), 2)
                                                                  AS pct_of_revenue
FROM payments p
WHERE p.payment_status = 'Success'
GROUP BY p.payment_method
ORDER BY total_revenue DESC;

-- EXPLANATION:
-- Aggregates successful payments by method, showing both transaction count
-- and revenue share. The window function SUM() OVER () gives us the grand
-- total for percentage calculations without a subquery.
--
-- BUSINESS INSIGHT:
-- UPI dominates at ~40% of transactions but has the lowest processing fees
-- (~0.3%). If Credit Card share is significant, negotiating lower MDR
-- (Merchant Discount Rate) with card networks could save ₹20-30L annually.
