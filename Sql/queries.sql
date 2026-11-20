
SELECT 
    'Total Products' AS metric, COUNT(*) AS count_value FROM dim_products
UNION ALL
SELECT 
    'Total Customers', COUNT(*) FROM dim_customers
UNION ALL
SELECT 
    'Total Returns Recorded', COUNT(*) FROM fact_returns
UNION ALL
SELECT 
    'Total Multi-Year Sales Transactions', COUNT(*) FROM fact_sales;


SELECT 
    c.category_name,
    sub.subcategory_name,
    COUNT(s.order_number) AS total_orders,
    SUM(s.order_quantity) AS total_units_sold,
    ROUND(SUM(s.order_quantity * p.product_price), 2) AS total_revenue,
    ROUND(SUM(s.order_quantity * p.product_cost), 2) AS total_cost,
    ROUND(SUM(s.order_quantity * (p.product_price - p.product_cost)), 2) AS total_profit,
    ROUND(
        (SUM(s.order_quantity * (p.product_price - p.product_cost)) / 
         SUM(s.order_quantity * p.product_price)) * 100, 
        2
    ) AS profit_margin_pct
FROM fact_sales s
JOIN dim_products p 
    ON s.product_key = p.product_key
JOIN dim_product_subcategories sub 
    ON p.product_subcategory_key = sub.subcategory_key
JOIN dim_product_categories c 
    ON sub.category_key = c.category_key
GROUP BY 
    c.category_name, 
    sub.subcategory_name
ORDER BY 
    total_revenue DESC;


WITH sales_summary AS (
    SELECT 
        p.product_subcategory_key,
        SUM(s.order_quantity) AS total_units_sold,
        ROUND(SUM(s.order_quantity * p.product_price), 2) AS total_revenue,
        ROUND(SUM(s.order_quantity * (p.product_price - p.product_cost)), 2) AS total_profit
    FROM fact_sales s
    JOIN dim_products p 
        ON s.product_key = p.product_key
    GROUP BY p.product_subcategory_key
),
returns_summary AS (
    SELECT 
        p.product_subcategory_key,
        SUM(r.return_quantity) AS total_units_returned
    FROM fact_returns r
    JOIN dim_products p 
        ON r.product_key = p.product_key
    GROUP BY p.product_subcategory_key
)
SELECT 
    c.category_name,
    sub.subcategory_name,
    s.total_revenue,
    s.total_units_sold,
    COALESCE(r.total_units_returned, 0) AS total_units_returned,
    ROUND(
        (COALESCE(r.total_units_returned, 0)::NUMERIC / s.total_units_sold) * 100, 
        2
    ) AS return_rate_pct,
    ROUND((s.total_profit / s.total_revenue) * 100, 2) AS profit_margin_pct
FROM sales_summary s
LEFT JOIN returns_summary r 
    ON s.product_subcategory_key = r.product_subcategory_key
JOIN dim_product_subcategories sub 
    ON s.product_subcategory_key = sub.subcategory_key
JOIN dim_product_categories c 
    ON sub.category_key = c.category_key
ORDER BY return_rate_pct DESC;


WITH product_performance AS (
    SELECT 
        p.product_key,
        p.product_name,
        sub.subcategory_name,
        c.category_name,
        p.product_cost,
        p.product_price,
        SUM(s.order_quantity) AS units_sold,
        ROUND(SUM(s.order_quantity * p.product_price), 2) AS total_revenue,
        ROUND(SUM(s.order_quantity * (p.product_price - p.product_cost)), 2) AS total_profit,
        ROUND(
            (SUM(s.order_quantity * (p.product_price - p.product_cost)) / 
             SUM(s.order_quantity * p.product_price)) * 100, 
            2
        ) AS profit_margin_pct
    FROM fact_sales s
    JOIN dim_products p 
        ON s.product_key = p.product_key
    JOIN dim_product_subcategories sub 
        ON p.product_subcategory_key = sub.subcategory_key
    JOIN dim_product_categories c 
        ON sub.category_key = c.category_key
    GROUP BY 
        p.product_key, 
        p.product_name, 
        sub.subcategory_name, 
        c.category_name,
        p.product_cost,
        p.product_price
),
ranked_products AS (
    SELECT 
        *,
        DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
        CASE 
            WHEN total_revenue >= 500000 AND profit_margin_pct < 40.0 
                THEN 'Profit Trap (High Revenue, Low Margin)'
            WHEN total_revenue >= 500000 AND profit_margin_pct >= 40.0 
                THEN 'Star Performer (High Revenue, High Margin)'
            WHEN total_revenue < 500000 AND profit_margin_pct >= 55.0 
                THEN 'Cash Cow (Low Volume, High Margin)'
            ELSE 'Standard Performer'
        END AS performance_segment
    FROM product_performance
)
SELECT 
    revenue_rank,
    product_name,
    subcategory_name,
    units_sold,
    total_revenue,
    total_profit,
    profit_margin_pct,
    performance_segment
FROM ranked_products
WHERE performance_segment = 'Profit Trap (High Revenue, Low Margin)'
ORDER BY total_revenue DESC;