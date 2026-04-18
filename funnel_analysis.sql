-- ============================================================
-- Funnel Analysis Queries
-- Database: PostgreSQL
-- Table:    user_events (user_id, event_type, event_date,
--                        traffic_source, amount)
-- ============================================================


-- ------------------------------------------------------------
-- 1. Sales Funnel Stages
--    Counts distinct users at each stage of the purchase funnel
-- ------------------------------------------------------------

WITH funnel_stages AS (
    SELECT
        COUNT(DISTINCT CASE WHEN event_type = 'page_view'      THEN user_id END) AS stage_1_views,
        COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart'    THEN user_id END) AS stage_2_cart,
        COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS stage_3_checkout,
        COUNT(DISTINCT CASE WHEN event_type = 'payment_info'   THEN user_id END) AS stage_4_payment,
        COUNT(DISTINCT CASE WHEN event_type = 'purchase'       THEN user_id END) AS stage_5_purchase
    FROM user_events
)
SELECT
    stage_1_views,
    stage_2_cart,
    ROUND(stage_2_cart     * 100.0 / stage_1_views,    2) AS view_to_cart_rate,

    stage_3_checkout,
    ROUND(stage_3_checkout * 100.0 / stage_2_cart,     2) AS cart_to_checkout_rate,

    stage_4_payment,
    ROUND(stage_4_payment  * 100.0 / stage_3_checkout, 2) AS checkout_to_payment_rate,

    stage_5_purchase,
    ROUND(stage_5_purchase * 100.0 / stage_4_payment,  2) AS payment_to_purchase_rate,

    ROUND(stage_5_purchase * 100.0 / stage_1_views,    2) AS overall_conversion_rate
FROM funnel_stages;


-- ------------------------------------------------------------
-- 2. Funnel by Traffic Source
--    Breaks down conversion rates by acquisition channel
-- ------------------------------------------------------------

WITH source_funnel AS (
    SELECT
        traffic_source,
        COUNT(DISTINCT CASE WHEN event_type = 'page_view'   THEN user_id END) AS views,
        COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS carts,
        COUNT(DISTINCT CASE WHEN event_type = 'purchase'    THEN user_id END) AS purchases
    FROM user_events
    GROUP BY traffic_source
)
SELECT
    traffic_source,
    views,
    carts,
    purchases,
    ROUND(carts     * 100.0 / views, 2) AS cart_conversion_rate,
    ROUND(purchases * 100.0 / views, 2) AS purchase_conversion_rate,
    ROUND(purchases * 100.0 / carts, 2) AS cart_to_purchase_conversion_rate
FROM source_funnel
ORDER BY purchases DESC;


-- ------------------------------------------------------------
-- 3. Time to Conversion Analysis
--    Average minutes between funnel stages for converted users
-- ------------------------------------------------------------

WITH user_journey AS (
    SELECT
        user_id,
        MIN(CASE WHEN event_type = 'page_view'   THEN event_date END) AS view_time,
        MIN(CASE WHEN event_type = 'add_to_cart' THEN event_date END) AS cart_time,
        MIN(CASE WHEN event_type = 'purchase'    THEN event_date END) AS purchase_time
    FROM user_events
    GROUP BY user_id
    HAVING MIN(CASE WHEN event_type = 'purchase' THEN event_date END) IS NOT NULL
)
SELECT
    COUNT(*) AS converted_users,
    ROUND(AVG(EXTRACT(EPOCH FROM (cart_time     - view_time))  / 60), 2) AS avg_view_to_cart_minutes,
    ROUND(AVG(EXTRACT(EPOCH FROM (purchase_time - cart_time))  / 60), 2) AS avg_cart_to_purchase_minutes,
    ROUND(AVG(EXTRACT(EPOCH FROM (purchase_time - view_time))  / 60), 2) AS avg_total_journey_minutes
FROM user_journey;


-- ------------------------------------------------------------
-- 4. Revenue Funnel Analysis
--    Key revenue metrics across the visitor-to-buyer funnel
-- ------------------------------------------------------------

WITH funnel_revenue AS (
    SELECT
        COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS total_visitors,
        COUNT(DISTINCT CASE WHEN event_type = 'purchase'  THEN user_id END) AS total_buyers,
        SUM(CASE WHEN event_type = 'purchase' THEN amount END)              AS total_revenue,
        COUNT(CASE WHEN event_type = 'purchase' THEN 1 END)                 AS total_orders
    FROM user_events
)
SELECT
    total_visitors,
    total_buyers,
    total_orders,
    total_revenue,
    ROUND(total_revenue / total_orders::numeric,   2) AS avg_order_value,
    ROUND(total_revenue / total_buyers::numeric,   2) AS revenue_per_buyer,
    ROUND(total_revenue / total_visitors::numeric, 2) AS revenue_per_visitor
FROM funnel_revenue;
