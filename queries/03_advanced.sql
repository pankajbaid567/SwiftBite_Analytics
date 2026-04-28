-- ============================================================================
-- SwiftBite Analytics — ADVANCED SQL Queries (15 Queries)
-- ============================================================================
-- Level     : Advanced
-- Concepts  : Window Functions, CTEs, Cohort/Retention/Funnel Analysis,
--             RFM Segmentation, Pareto Analysis
-- ============================================================================


-- ============================================================================
-- QUERY 16: Rank Restaurants by Revenue Within Each City
-- ============================================================================
-- PROBLEM: Identify the top 3 revenue-generating restaurants per city for
--          the "City Champions" marketing campaign.
-- CONCEPTS: RANK() window function, PARTITION BY

WITH restaurant_revenue AS (
    SELECT
        r.restaurant_id,
        r.name AS restaurant_name,
        r.city,
        r.cuisine_type,
        ROUND(SUM(o.final_amount), 2) AS total_revenue,
        COUNT(o.order_id) AS total_orders,
        RANK() OVER (
            PARTITION BY r.city
            ORDER BY SUM(o.final_amount) DESC
        ) AS city_rank
    FROM orders o
    JOIN restaurants r ON o.restaurant_id = r.restaurant_id
    WHERE o.status = 'Delivered'
    GROUP BY r.restaurant_id, r.name, r.city, r.cuisine_type
)
SELECT * FROM restaurant_revenue
WHERE city_rank <= 3
ORDER BY city, city_rank;

-- INSIGHT: Top 3 restaurants per city typically capture 30-40% of that
-- city's total revenue. These are the partners to protect at all costs.


-- ============================================================================
-- QUERY 17: Running Total of Daily Revenue
-- ============================================================================
-- PROBLEM: Finance needs a cumulative revenue tracker for board reporting.
-- CONCEPTS: SUM() OVER with ORDER BY (running window)

SELECT
    order_date::DATE AS day,
    COUNT(order_id) AS daily_orders,
    ROUND(SUM(final_amount), 2) AS daily_revenue,
    ROUND(SUM(SUM(final_amount)) OVER (ORDER BY order_date::DATE), 2)
        AS cumulative_revenue
FROM orders
WHERE status = 'Delivered'
GROUP BY order_date::DATE
ORDER BY day;

-- INSIGHT: The cumulative curve's slope indicates growth velocity. A
-- flattening curve signals saturation; a steepening curve signals virality.


-- ============================================================================
-- QUERY 18: Customer RFM Segmentation
-- ============================================================================
-- PROBLEM: Segment customers into actionable groups (Champions, At Risk,
--          Lost) using Recency, Frequency, Monetary framework.
-- CONCEPTS: CTE, NTILE window function, CASE WHEN

WITH rfm_base AS (
    SELECT
        u.user_id, u.name, u.city, u.is_premium,
        ('2025-12-31'::DATE - MAX(o.order_date)::DATE) AS recency_days,
        COUNT(o.order_id) AS frequency,
        ROUND(SUM(o.final_amount), 2) AS monetary
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    WHERE o.status = 'Delivered'
    GROUP BY u.user_id, u.name, u.city, u.is_premium
),
rfm_scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency) AS f_score,
        NTILE(5) OVER (ORDER BY monetary) AS m_score
    FROM rfm_base
)
SELECT *,
    (r_score + f_score + m_score) AS rfm_total,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'New Customers'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost'
        ELSE 'Need Attention'
    END AS customer_segment
FROM rfm_scores
ORDER BY rfm_total DESC;

-- INSIGHT: Champions (~10% of users) drive ~40% of revenue. "At Risk"
-- customers need immediate win-back campaigns before they become "Lost."


-- ============================================================================
-- QUERY 19: Month-over-Month Revenue Growth Rate
-- ============================================================================
-- PROBLEM: Track MoM revenue growth for investor dashboards.
-- CONCEPTS: LAG() window function, percentage calculation

WITH monthly AS (
    SELECT
        DATE_TRUNC('month', order_date)::DATE AS month,
        ROUND(SUM(final_amount), 2) AS revenue,
        COUNT(order_id) AS orders
    FROM orders WHERE status = 'Delivered'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT
    month,
    revenue,
    orders,
    LAG(revenue) OVER (ORDER BY month) AS prev_revenue,
    ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
          / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 2)
        AS revenue_growth_pct
FROM monthly ORDER BY month;

-- INSIGHT: Sustainable growth is 5-10% MoM. Spikes >20% during festivals
-- are expected but should be followed by stable (not declining) months.


-- ============================================================================
-- QUERY 20: Top 3 Items Per Restaurant by Quantity Sold
-- ============================================================================
-- PROBLEM: Help restaurants optimize their menus by identifying bestsellers.
-- CONCEPTS: ROW_NUMBER() with PARTITION BY

WITH item_sales AS (
    SELECT
        r.name AS restaurant_name,
        mi.item_name,
        mi.category,
        SUM(oi.quantity) AS total_qty_sold,
        ROUND(SUM(oi.subtotal), 2) AS total_item_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY r.restaurant_id
            ORDER BY SUM(oi.quantity) DESC
        ) AS item_rank
    FROM order_items oi
    JOIN menu_items mi ON oi.item_id = mi.item_id
    JOIN restaurants r ON mi.restaurant_id = r.restaurant_id
    GROUP BY r.restaurant_id, r.name, mi.item_name, mi.category
)
SELECT * FROM item_sales WHERE item_rank <= 3
ORDER BY restaurant_name, item_rank;

-- INSIGHT: The #1 item per restaurant typically accounts for 35-50% of
-- that restaurant's orders. Stock-outs of this item directly impact revenue.


-- ============================================================================
-- QUERY 21: Customer Cohort Analysis by Signup Month
-- ============================================================================
-- PROBLEM: Track how different signup cohorts behave over time to measure
--          the impact of marketing campaigns on customer quality.
-- CONCEPTS: CTE, DATE_TRUNC, cohort modeling

WITH cohort AS (
    SELECT
        u.user_id,
        DATE_TRUNC('month', u.signup_date)::DATE AS cohort_month,
        DATE_TRUNC('month', o.order_date)::DATE AS order_month
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    WHERE o.status = 'Delivered'
),
cohort_size AS (
    SELECT cohort_month, COUNT(DISTINCT user_id) AS cohort_users
    FROM cohort GROUP BY cohort_month
),
cohort_activity AS (
    SELECT
        c.cohort_month,
        c.order_month,
        (EXTRACT(YEAR FROM c.order_month) - EXTRACT(YEAR FROM c.cohort_month)) * 12
        + (EXTRACT(MONTH FROM c.order_month) - EXTRACT(MONTH FROM c.cohort_month))
            AS month_offset,
        COUNT(DISTINCT c.user_id) AS active_users
    FROM cohort c GROUP BY c.cohort_month, c.order_month
)
SELECT
    ca.cohort_month,
    cs.cohort_users,
    ca.month_offset,
    ca.active_users,
    ROUND(100.0 * ca.active_users / cs.cohort_users, 2) AS retention_pct
FROM cohort_activity ca
JOIN cohort_size cs ON ca.cohort_month = cs.cohort_month
WHERE ca.month_offset BETWEEN 0 AND 11
ORDER BY ca.cohort_month, ca.month_offset;

-- INSIGHT: If Month-1 retention is ~30% and Month-6 is ~10%, there's a
-- massive drop-off. The steepest drop (usually Month 1→2) is where
-- onboarding improvements have the highest impact.


-- ============================================================================
-- QUERY 22: 30-Day Retention Analysis
-- ============================================================================
-- PROBLEM: What percentage of customers place a second order within 30 days?
-- CONCEPTS: Self-join, CTE, date arithmetic

WITH first_orders AS (
    SELECT user_id, MIN(order_date) AS first_order_date
    FROM orders WHERE status = 'Delivered' GROUP BY user_id
),
second_orders AS (
    SELECT
        fo.user_id,
        fo.first_order_date,
        MIN(o.order_date) AS second_order_date
    FROM first_orders fo
    JOIN orders o ON fo.user_id = o.user_id
        AND o.order_date > fo.first_order_date
        AND o.status = 'Delivered'
    GROUP BY fo.user_id, fo.first_order_date
)
SELECT
    COUNT(DISTINCT fo.user_id) AS total_customers,
    COUNT(DISTINCT so.user_id) AS retained_within_30d,
    COUNT(DISTINCT CASE
        WHEN so.second_order_date <= fo.first_order_date + INTERVAL '30 days'
        THEN so.user_id END) AS retained_30d,
    ROUND(100.0 * COUNT(DISTINCT CASE
        WHEN so.second_order_date <= fo.first_order_date + INTERVAL '30 days'
        THEN so.user_id END) / COUNT(DISTINCT fo.user_id), 2)
        AS retention_rate_30d
FROM first_orders fo
LEFT JOIN second_orders so ON fo.user_id = so.user_id;

-- INSIGHT: Industry benchmark for food delivery 30-day retention is 25-35%.
-- Below 20% signals serious onboarding or first-experience issues.


-- ============================================================================
-- QUERY 23: Order Funnel Analysis
-- ============================================================================
-- PROBLEM: Track conversion through the order lifecycle to find drop-off points.
-- CONCEPTS: CTE, conditional aggregation, funnel metrics

WITH funnel AS (
    SELECT
        COUNT(*) AS total_placed,
        SUM(CASE WHEN status IN ('Confirmed','Preparing','Out for Delivery','Delivered')
            THEN 1 ELSE 0 END) AS confirmed,
        SUM(CASE WHEN status IN ('Preparing','Out for Delivery','Delivered')
            THEN 1 ELSE 0 END) AS preparing,
        SUM(CASE WHEN status IN ('Out for Delivery','Delivered')
            THEN 1 ELSE 0 END) AS out_for_delivery,
        SUM(CASE WHEN status = 'Delivered' THEN 1 ELSE 0 END) AS delivered,
        SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled
    FROM orders
)
SELECT
    total_placed,
    confirmed,
    ROUND(100.0 * confirmed / total_placed, 2) AS confirmed_pct,
    delivered,
    ROUND(100.0 * delivered / total_placed, 2) AS delivered_pct,
    cancelled,
    ROUND(100.0 * cancelled / total_placed, 2) AS cancellation_pct
FROM funnel;

-- INSIGHT: Every 1% reduction in cancellation rate saves ~₹2.5L/month
-- in wasted delivery partner time and customer refund processing costs.


-- ============================================================================
-- QUERY 24: Pareto Analysis — Top 20% Customers Driving Revenue
-- ============================================================================
-- PROBLEM: Validate the 80/20 rule — do top 20% of customers drive 80% revenue?
-- CONCEPTS: CTE, PERCENT_RANK window function, cumulative distribution

WITH customer_revenue AS (
    SELECT
        user_id,
        ROUND(SUM(final_amount), 2) AS total_revenue,
        PERCENT_RANK() OVER (ORDER BY SUM(final_amount) DESC) AS pct_rank
    FROM orders WHERE status = 'Delivered'
    GROUP BY user_id
),
pareto AS (
    SELECT
        CASE
            WHEN pct_rank <= 0.05 THEN 'Top 5%'
            WHEN pct_rank <= 0.20 THEN 'Top 6-20%'
            WHEN pct_rank <= 0.50 THEN 'Top 21-50%'
            ELSE 'Bottom 50%'
        END AS customer_tier,
        COUNT(*) AS customer_count,
        ROUND(SUM(total_revenue), 2) AS tier_revenue
    FROM customer_revenue GROUP BY 1
)
SELECT
    customer_tier, customer_count, tier_revenue,
    ROUND(100.0 * tier_revenue / SUM(tier_revenue) OVER (), 2) AS revenue_share_pct
FROM pareto ORDER BY tier_revenue DESC;

-- INSIGHT: If top 20% drive >65% of revenue, the business is healthy but
-- concentrated. Diversification strategies are needed to reduce dependency.


-- ============================================================================
-- QUERY 25: Average Time Between Repeat Orders
-- ============================================================================
-- PROBLEM: Understand natural ordering frequency to time re-engagement nudges.
-- CONCEPTS: LEAD/LAG window function, date arithmetic

WITH order_gaps AS (
    SELECT
        user_id,
        order_date,
        LEAD(order_date) OVER (PARTITION BY user_id ORDER BY order_date)
            AS next_order_date,
        EXTRACT(EPOCH FROM (
            LEAD(order_date) OVER (PARTITION BY user_id ORDER BY order_date)
            - order_date
        )) / 86400.0 AS days_until_next_order
    FROM orders WHERE status = 'Delivered'
)
SELECT
    ROUND(AVG(days_until_next_order), 1) AS avg_gap_days,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY days_until_next_order), 1)
        AS median_gap_days,
    ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY days_until_next_order), 1)
        AS p25_gap_days,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY days_until_next_order), 1)
        AS p75_gap_days
FROM order_gaps
WHERE days_until_next_order IS NOT NULL;

-- INSIGHT: If median gap is 7 days, send push notifications on Day 5-6.
-- Customers who exceed 2x their median gap are at churn risk.


-- ============================================================================
-- QUERY 26: Restaurant Churn Detection
-- ============================================================================
-- PROBLEM: Identify restaurants that were active but stopped receiving orders.
-- CONCEPTS: CTE, date difference, activity classification

WITH restaurant_activity AS (
    SELECT
        r.restaurant_id, r.name, r.city, r.cuisine_type,
        COUNT(o.order_id) AS total_orders,
        MAX(o.order_date)::DATE AS last_order_date,
        ('2025-12-31'::DATE - MAX(o.order_date)::DATE) AS days_since_last_order
    FROM restaurants r
    JOIN orders o ON r.restaurant_id = o.restaurant_id
    WHERE o.status = 'Delivered'
    GROUP BY r.restaurant_id, r.name, r.city, r.cuisine_type
)
SELECT *,
    CASE
        WHEN days_since_last_order <= 30 THEN 'Active'
        WHEN days_since_last_order <= 60 THEN 'At Risk'
        WHEN days_since_last_order <= 90 THEN 'Churning'
        ELSE 'Churned'
    END AS churn_status
FROM restaurant_activity
ORDER BY days_since_last_order DESC;

-- INSIGHT: Losing a top-performing restaurant costs 50-100x what it costs
-- to retain them. "At Risk" restaurants should receive proactive outreach.


-- ============================================================================
-- QUERY 27: Delivery Partner Efficiency Ranking
-- ============================================================================
-- PROBLEM: Rank delivery partners for performance bonuses and identify
--          underperformers for training programs.
-- CONCEPTS: DENSE_RANK, multiple metrics

WITH partner_metrics AS (
    SELECT
        dp.partner_id, dp.partner_name, dp.city, dp.vehicle_type,
        COUNT(d.delivery_id) AS deliveries_completed,
        ROUND(AVG(d.delivery_duration_mins), 1) AS avg_delivery_time,
        ROUND(AVG(d.distance_km), 2) AS avg_distance,
        ROUND(100.0 * SUM(CASE WHEN d.delivery_status = 'On Time' THEN 1 ELSE 0 END)
              / COUNT(d.delivery_id), 2) AS on_time_pct,
        DENSE_RANK() OVER (
            PARTITION BY dp.city
            ORDER BY AVG(d.delivery_duration_mins)
        ) AS speed_rank
    FROM delivery d
    JOIN delivery_partners dp ON d.partner_id = dp.partner_id
    GROUP BY dp.partner_id, dp.partner_name, dp.city, dp.vehicle_type
    HAVING COUNT(d.delivery_id) >= 5
)
SELECT * FROM partner_metrics
ORDER BY city, speed_rank;

-- INSIGHT: Top 10% of delivery partners complete deliveries 40% faster.
-- Studying their route patterns can improve fleet-wide efficiency.


-- ============================================================================
-- QUERY 28: Weekend vs Weekday Revenue with Statistical Summary
-- ============================================================================
-- PROBLEM: Quantify the revenue gap between weekdays and weekends for
--          capacity planning and dynamic pricing decisions.
-- CONCEPTS: CTE, CASE WHEN, statistical aggregation

WITH daily_revenue AS (
    SELECT
        order_date::DATE AS day,
        CASE WHEN EXTRACT(DOW FROM order_date) IN (0, 6) THEN 'Weekend'
             ELSE 'Weekday' END AS day_type,
        COUNT(order_id) AS orders,
        ROUND(SUM(final_amount), 2) AS revenue
    FROM orders WHERE status = 'Delivered'
    GROUP BY order_date::DATE
)
SELECT
    day_type,
    COUNT(*) AS num_days,
    ROUND(AVG(orders), 1) AS avg_daily_orders,
    ROUND(AVG(revenue), 2) AS avg_daily_revenue,
    ROUND(STDDEV(revenue), 2) AS stddev_revenue,
    ROUND(MIN(revenue), 2) AS min_daily_revenue,
    ROUND(MAX(revenue), 2) AS max_daily_revenue
FROM daily_revenue
GROUP BY day_type;

-- INSIGHT: If weekend avg revenue is 25%+ higher than weekday, consider
-- introducing "Weekday Specials" to flatten the demand curve.


-- ============================================================================
-- QUERY 29: Customer Segmentation — Whale / Regular / Dormant
-- ============================================================================
-- PROBLEM: Create actionable segments for targeted marketing campaigns.
-- CONCEPTS: CTE, CASE WHEN, percentile-based segmentation

WITH customer_stats AS (
    SELECT
        u.user_id, u.name, u.city, u.is_premium,
        COUNT(o.order_id) AS order_count,
        ROUND(SUM(o.final_amount), 2) AS total_spent,
        MAX(o.order_date)::DATE AS last_order,
        ('2025-12-31'::DATE - MAX(o.order_date)::DATE) AS recency_days
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    WHERE o.status = 'Delivered'
    GROUP BY u.user_id, u.name, u.city, u.is_premium
)
SELECT
    user_id, name, city, is_premium,
    order_count, total_spent, recency_days,
    CASE
        WHEN total_spent >= (SELECT PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY total_spent) FROM customer_stats)
             AND recency_days <= 30 THEN '🐋 Whale'
        WHEN order_count >= 5 AND recency_days <= 60 THEN '⭐ Regular'
        WHEN recency_days <= 90 THEN '😐 Occasional'
        WHEN recency_days <= 180 THEN '😴 Dormant'
        ELSE '💀 Churned'
    END AS segment
FROM customer_stats
ORDER BY total_spent DESC;

-- INSIGHT: Whales need VIP treatment (dedicated support, early access).
-- Dormant customers need re-activation campaigns within 90 days before
-- they become permanently churned.


-- ============================================================================
-- QUERY 30: Churn Prediction — Customers Likely to Churn Based on Recency
-- ============================================================================
-- PROBLEM: Build an early warning system for customer churn using SQL.
-- CONCEPTS: CTE, window functions, behavioral scoring

WITH customer_behavior AS (
    SELECT
        u.user_id, u.name, u.city,
        COUNT(o.order_id) AS lifetime_orders,
        ROUND(AVG(o.final_amount), 2) AS avg_order_value,
        MAX(o.order_date)::DATE AS last_order_date,
        ('2025-12-31'::DATE - MAX(o.order_date)::DATE) AS days_inactive,
        ROUND(AVG(o.rating), 2) AS avg_rating
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    WHERE o.status = 'Delivered'
    GROUP BY u.user_id, u.name, u.city
    HAVING COUNT(o.order_id) >= 3
),
avg_gap AS (
    SELECT user_id,
        ROUND(AVG(gap_days), 1) AS avg_order_gap_days
    FROM (
        SELECT user_id,
            EXTRACT(EPOCH FROM (
                LEAD(order_date) OVER (PARTITION BY user_id ORDER BY order_date) - order_date
            )) / 86400.0 AS gap_days
        FROM orders WHERE status = 'Delivered'
    ) gaps
    WHERE gap_days IS NOT NULL
    GROUP BY user_id
)
SELECT
    cb.user_id, cb.name, cb.city,
    cb.lifetime_orders, cb.avg_order_value,
    cb.days_inactive, cb.avg_rating,
    ag.avg_order_gap_days,
    CASE
        WHEN cb.days_inactive > COALESCE(ag.avg_order_gap_days * 3, 90) THEN 'High Risk'
        WHEN cb.days_inactive > COALESCE(ag.avg_order_gap_days * 2, 60) THEN 'Medium Risk'
        WHEN cb.days_inactive > COALESCE(ag.avg_order_gap_days * 1.5, 30) THEN 'Low Risk'
        ELSE 'Active'
    END AS churn_risk,
    CASE
        WHEN cb.avg_rating IS NOT NULL AND cb.avg_rating < 3 THEN 'Poor Experience'
        WHEN cb.days_inactive > 90 AND cb.lifetime_orders <= 3 THEN 'Failed Activation'
        WHEN cb.days_inactive > 60 AND cb.lifetime_orders > 10 THEN 'Lapsed Power User'
        ELSE 'Normal'
    END AS churn_reason
FROM customer_behavior cb
LEFT JOIN avg_gap ag ON cb.user_id = ag.user_id
WHERE cb.days_inactive > COALESCE(ag.avg_order_gap_days, 30)
ORDER BY cb.days_inactive DESC;

-- INSIGHT: "Lapsed Power Users" are the highest-value churn targets.
-- A personalized win-back offer (free delivery + 20% off) for this
-- segment typically yields 15-20% reactivation rate with strong ROI.
