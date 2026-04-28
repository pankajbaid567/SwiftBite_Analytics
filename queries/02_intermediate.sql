-- ============================================================================
-- SwiftBite Analytics — INTERMEDIATE SQL Queries (10 Queries)
-- ============================================================================
-- Level     : Intermediate
-- Concepts  : JOINs, Subqueries, CASE WHEN, HAVING, EXTRACT, Aggregations
-- ============================================================================


-- ============================================================================
-- QUERY 6: Revenue by Cuisine Type
-- ============================================================================
-- PROBLEM: The business strategy team wants to understand which cuisine
--          categories drive the most revenue to prioritize restaurant
--          acquisition in high-demand verticals.
-- CONCEPTS: INNER JOIN, GROUP BY, SUM, ORDER BY
-- ============================================================================

SELECT
    r.cuisine_type,
    COUNT(DISTINCT r.restaurant_id)   AS restaurant_count,
    COUNT(o.order_id)                 AS total_orders,
    ROUND(SUM(o.final_amount), 2)    AS total_revenue,
    ROUND(AVG(o.final_amount), 2)    AS avg_order_value,
    ROUND(SUM(o.final_amount) / COUNT(DISTINCT r.restaurant_id), 2)
                                      AS revenue_per_restaurant
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.status = 'Delivered'
GROUP BY r.cuisine_type
ORDER BY total_revenue DESC;

-- EXPLANATION:
-- Joins orders with restaurants to aggregate revenue by cuisine type. The
-- revenue_per_restaurant metric is critical — it shows which cuisines are
-- most efficient at generating revenue per partner.
--
-- BUSINESS INSIGHT:
-- If Biryani has the highest revenue_per_restaurant but fewer partners,
-- aggressively onboarding biryani restaurants in underserved cities could
-- unlock significant revenue with minimal investment.


-- ============================================================================
-- QUERY 7: Repeat Customers (Ordered More Than 5 Times)
-- ============================================================================
-- PROBLEM: The CRM team wants to identify repeat customers for a loyalty
--          program launch and understand what share of users are "regulars."
-- CONCEPTS: GROUP BY, HAVING, COUNT
-- ============================================================================

SELECT
    u.user_id,
    u.name,
    u.city,
    u.is_premium,
    COUNT(o.order_id)                AS total_orders,
    ROUND(SUM(o.final_amount), 2)   AS total_spent,
    MIN(o.order_date)::DATE          AS first_order,
    MAX(o.order_date)::DATE          AS last_order
FROM orders o
JOIN users u ON o.user_id = u.user_id
WHERE o.status = 'Delivered'
GROUP BY u.user_id, u.name, u.city, u.is_premium
HAVING COUNT(o.order_id) > 5
ORDER BY total_orders DESC;

-- EXPLANATION:
-- Groups delivered orders by user, then filters using HAVING to find users
-- with more than 5 orders. Shows their total spend, first/last order dates
-- for lifecycle analysis.
--
-- BUSINESS INSIGHT:
-- These repeat customers are the "golden cohort." If they represent ~15% of
-- users but ~45% of revenue, investing in their retention (exclusive deals,
-- priority delivery) has 3x the ROI vs acquiring new users.


-- ============================================================================
-- QUERY 8: Month-over-Month Order Growth
-- ============================================================================
-- PROBLEM: The leadership team needs to track monthly order trends to assess
--          growth trajectory for investor reporting.
-- CONCEPTS: DATE_TRUNC, Subquery, GROUP BY
-- ============================================================================

SELECT
    order_month,
    total_orders,
    total_revenue,
    prev_month_orders,
    CASE
        WHEN prev_month_orders IS NOT NULL AND prev_month_orders > 0
        THEN ROUND(100.0 * (total_orders - prev_month_orders) / prev_month_orders, 2)
        ELSE NULL
    END AS order_growth_pct
FROM (
    SELECT
        DATE_TRUNC('month', order_date)::DATE  AS order_month,
        COUNT(order_id)                        AS total_orders,
        ROUND(SUM(final_amount), 2)           AS total_revenue,
        LAG(COUNT(order_id)) OVER (ORDER BY DATE_TRUNC('month', order_date))
                                               AS prev_month_orders
    FROM orders
    WHERE status = 'Delivered'
    GROUP BY DATE_TRUNC('month', order_date)
) monthly_data
ORDER BY order_month;

-- EXPLANATION:
-- The inner query aggregates orders by month and uses LAG() to get the
-- previous month's count. The outer query calculates the growth percentage.
-- This two-layer approach keeps the logic clean and readable.
--
-- BUSINESS INSIGHT:
-- Consistent MoM growth of 8-12% signals healthy organic adoption. If a
-- specific month shows a spike (e.g., festivals) followed by a dip, the
-- marketing team should plan retention campaigns post-festival.


-- ============================================================================
-- QUERY 9: Restaurants with Zero Orders (Inactive Partners)
-- ============================================================================
-- PROBLEM: The restaurant success team wants to identify onboarded
--          restaurants that have never received an order — indicating
--          potential listing quality or visibility issues.
-- CONCEPTS: LEFT JOIN, IS NULL, filtering
-- ============================================================================

SELECT
    r.restaurant_id,
    r.name              AS restaurant_name,
    r.city,
    r.cuisine_type,
    r.rating,
    r.partner_since,
    r.is_active
FROM restaurants r
LEFT JOIN orders o ON r.restaurant_id = o.restaurant_id
WHERE o.order_id IS NULL
ORDER BY r.partner_since;

-- EXPLANATION:
-- LEFT JOIN keeps all restaurants even if they have no orders. The WHERE
-- clause filters for those where no matching order exists (NULL join key).
-- Ordered by partner_since to see how long they've been inactive.
--
-- BUSINESS INSIGHT:
-- Restaurants with 0 orders despite being active for 3+ months have
-- visibility or menu quality issues. The restaurant success team should
-- conduct audits: improve photos, optimize menu pricing, or boost listing
-- placement to activate these dormant partners.


-- ============================================================================
-- QUERY 10: Average Delivery Time by City
-- ============================================================================
-- PROBLEM: The operations team needs to monitor delivery performance across
--          cities to identify SLA breaches and deploy additional fleet.
-- CONCEPTS: JOIN, AVG, GROUP BY, multiple aggregations
-- ============================================================================

SELECT
    u.city,
    COUNT(d.delivery_id)                     AS total_deliveries,
    ROUND(AVG(d.delivery_duration_mins), 1)  AS avg_delivery_mins,
    MIN(d.delivery_duration_mins)             AS fastest_delivery,
    MAX(d.delivery_duration_mins)             AS slowest_delivery,
    ROUND(100.0 * SUM(CASE WHEN d.delivery_status = 'Late' THEN 1 ELSE 0 END)
          / COUNT(d.delivery_id), 2)          AS late_delivery_pct
FROM delivery d
JOIN orders o ON d.order_id = o.order_id
JOIN users u ON o.user_id = u.user_id
GROUP BY u.city
ORDER BY avg_delivery_mins DESC;

-- EXPLANATION:
-- Three-way join (delivery → orders → users) to get city-level delivery
-- metrics. The CASE WHEN inside SUM calculates late delivery percentage
-- without needing a separate query.
--
-- BUSINESS INSIGHT:
-- Cities with avg delivery time >40 mins or late_delivery_pct >25% need
-- immediate attention: either more delivery partners, better routing, or
-- restaurant prep time optimization. Each minute saved in delivery time
-- correlates with a 1.5% improvement in customer satisfaction score.


-- ============================================================================
-- QUERY 11: Orders with Above-Average Order Value
-- ============================================================================
-- PROBLEM: The marketing team wants to study high-value orders to understand
--          what products/cuisines command premium pricing.
-- CONCEPTS: Subquery in WHERE clause, comparison with aggregate
-- ============================================================================

SELECT
    o.order_id,
    u.name            AS customer_name,
    r.name            AS restaurant_name,
    r.cuisine_type,
    o.order_amount,
    o.final_amount,
    o.order_date::DATE AS order_date,
    o.rating
FROM orders o
JOIN users u ON o.user_id = u.user_id
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.status = 'Delivered'
  AND o.final_amount > (
      SELECT AVG(final_amount)
      FROM orders
      WHERE status = 'Delivered'
  )
ORDER BY o.final_amount DESC
LIMIT 50;

-- EXPLANATION:
-- The subquery calculates the overall average order value. The main query
-- then filters for orders exceeding this threshold. This reveals the
-- characteristics of premium orders.
--
-- BUSINESS INSIGHT:
-- High-value orders often cluster around specific cuisines (Italian,
-- Continental) or times (weekend dinners). Creating "Premium Dining"
-- collections and upselling during these windows can lift AOV by 10-15%.


-- ============================================================================
-- QUERY 12: Customer Lifetime Value (CLV)
-- ============================================================================
-- PROBLEM: The marketing team needs CLV to set appropriate acquisition
--          budgets and identify which user segments deliver the best ROI.
-- CONCEPTS: Multi-table JOIN, complex aggregations, date arithmetic
-- ============================================================================

SELECT
    u.user_id,
    u.name,
    u.city,
    u.is_premium,
    u.signup_date,
    COUNT(o.order_id)                                      AS total_orders,
    ROUND(SUM(o.final_amount), 2)                         AS lifetime_revenue,
    ROUND(AVG(o.final_amount), 2)                         AS avg_order_value,
    MIN(o.order_date)::DATE                                AS first_order,
    MAX(o.order_date)::DATE                                AS last_order,
    (MAX(o.order_date)::DATE - MIN(o.order_date)::DATE)   AS customer_tenure_days,
    CASE
        WHEN (MAX(o.order_date)::DATE - MIN(o.order_date)::DATE) > 0
        THEN ROUND(
            COUNT(o.order_id)::DECIMAL /
            ((MAX(o.order_date)::DATE - MIN(o.order_date)::DATE) / 30.0),
        2)
        ELSE COUNT(o.order_id)
    END                                                    AS orders_per_month
FROM users u
JOIN orders o ON u.user_id = o.user_id
WHERE o.status = 'Delivered'
GROUP BY u.user_id, u.name, u.city, u.is_premium, u.signup_date
HAVING COUNT(o.order_id) >= 2
ORDER BY lifetime_revenue DESC
LIMIT 100;

-- EXPLANATION:
-- Comprehensive CLV calculation including: total revenue, order frequency,
-- customer tenure, and orders-per-month rate. The HAVING clause filters for
-- customers with at least 2 orders for meaningful frequency calculation.
--
-- BUSINESS INSIGHT:
-- If the top 100 customers by CLV are predominantly premium members from
-- metro cities with 10+ orders/month, the acquisition strategy should
-- target similar profiles. CLV:CAC ratio should be ≥ 3:1 for sustainability.


-- ============================================================================
-- QUERY 13: Peak Ordering Hours (Demand Heatmap Data)
-- ============================================================================
-- PROBLEM: Operations needs to understand hourly demand patterns to optimize
--          delivery partner shift scheduling and reduce wait times.
-- CONCEPTS: EXTRACT, GROUP BY, multiple time dimensions
-- ============================================================================

SELECT
    EXTRACT(HOUR FROM order_date)   AS order_hour,
    CASE
        WHEN EXTRACT(DOW FROM order_date) IN (0, 6) THEN 'Weekend'
        ELSE 'Weekday'
    END                              AS day_type,
    COUNT(order_id)                  AS total_orders,
    ROUND(AVG(final_amount), 2)     AS avg_order_value,
    ROUND(SUM(final_amount), 2)     AS total_revenue
FROM orders
WHERE status = 'Delivered'
GROUP BY
    EXTRACT(HOUR FROM order_date),
    CASE WHEN EXTRACT(DOW FROM order_date) IN (0, 6) THEN 'Weekend' ELSE 'Weekday' END
ORDER BY day_type, order_hour;

-- EXPLANATION:
-- Extracts the hour from order timestamps and categorizes days as Weekend
-- or Weekday. This creates a demand heatmap showing when the platform is
-- busiest, broken down by day type.
--
-- BUSINESS INSIGHT:
-- Peak hours (12-2 PM lunch, 7-10 PM dinner) on weekends can see 3x the
-- demand of off-peak weekday mornings. Surge pricing during peaks and
-- discounts during troughs can smooth demand and improve fleet utilization.


-- ============================================================================
-- QUERY 14: Cancellation Rate by Restaurant
-- ============================================================================
-- PROBLEM: The quality assurance team wants to identify restaurants with
--          high cancellation rates that may need operational intervention.
-- CONCEPTS: CASE WHEN inside aggregation, percentage calculation
-- ============================================================================

SELECT
    r.restaurant_id,
    r.name                  AS restaurant_name,
    r.city,
    r.cuisine_type,
    r.rating,
    COUNT(o.order_id)       AS total_orders,
    SUM(CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END)
                            AS cancelled_orders,
    ROUND(
        100.0 * SUM(CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END)
        / COUNT(o.order_id), 2
    )                       AS cancellation_rate_pct
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_id, r.name, r.city, r.cuisine_type, r.rating
HAVING COUNT(o.order_id) >= 10  -- Minimum order threshold for statistical significance
ORDER BY cancellation_rate_pct DESC
LIMIT 20;

-- EXPLANATION:
-- Uses CASE WHEN inside SUM to conditionally count cancelled orders. The
-- HAVING clause ensures we only look at restaurants with enough orders for
-- a meaningful cancellation rate (≥10 orders).
--
-- BUSINESS INSIGHT:
-- Restaurants with cancellation rates >15% are red flags. Common causes:
-- items marked available but actually out of stock, long prep times causing
-- customer cancellations, or kitchen capacity issues. Each cancellation costs
-- the platform ~₹50 in wasted delivery partner time.


-- ============================================================================
-- QUERY 15: New vs Returning Customer Revenue Split
-- ============================================================================
-- PROBLEM: The growth team needs to understand what proportion of revenue
--          comes from new customers (first order) vs returning customers
--          to assess the health of organic retention.
-- CONCEPTS: Subquery, CASE WHEN, conditional aggregation
-- ============================================================================

WITH customer_first_order AS (
    SELECT
        user_id,
        MIN(order_date) AS first_order_date
    FROM orders
    WHERE status = 'Delivered'
    GROUP BY user_id
)
SELECT
    DATE_TRUNC('month', o.order_date)::DATE          AS order_month,
    COUNT(CASE WHEN o.order_date = cfo.first_order_date THEN 1 END)
                                                      AS new_customer_orders,
    COUNT(CASE WHEN o.order_date > cfo.first_order_date THEN 1 END)
                                                      AS returning_customer_orders,
    ROUND(SUM(CASE WHEN o.order_date = cfo.first_order_date THEN o.final_amount ELSE 0 END), 2)
                                                      AS new_customer_revenue,
    ROUND(SUM(CASE WHEN o.order_date > cfo.first_order_date THEN o.final_amount ELSE 0 END), 2)
                                                      AS returning_customer_revenue,
    ROUND(
        100.0 * SUM(CASE WHEN o.order_date > cfo.first_order_date THEN o.final_amount ELSE 0 END)
        / NULLIF(SUM(o.final_amount), 0), 2
    )                                                 AS returning_revenue_pct
FROM orders o
JOIN customer_first_order cfo ON o.user_id = cfo.user_id
WHERE o.status = 'Delivered'
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY order_month;

-- EXPLANATION:
-- First, the CTE identifies each customer's first order date. Then, we
-- classify each subsequent order as "new" or "returning" and aggregate
-- revenue by month. The returning_revenue_pct shows how dependent the
-- platform is on repeat customers.
--
-- BUSINESS INSIGHT:
-- A healthy platform should see returning_revenue_pct >60% by month 6.
-- If new customer revenue dominates, the business is "renting" customers
-- through discounts rather than building loyalty — a red flag for investors.
