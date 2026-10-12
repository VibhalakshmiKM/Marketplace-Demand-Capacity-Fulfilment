create database market;
use market;
SELECT COUNT(*) AS total_rows FROM customers;
SELECT COUNT(*) AS total_rows FROM orders;
SELECT COUNT(*) AS total_rows FROM hub_capacity;
SELECT COUNT(*) AS total_rows FROM delivery_performance;
SELECT COUNT(*) AS total_rows FROM cx_tickets;
SELECT COUNT(*) AS total_rows FROM demand_forecast;
SELECT COUNT(*) AS total_rows FROM products;
SELECT COUNT(*) AS total_rows FROM sellers;
SELECT COUNT(*) AS total_rows FROM riders;
SELECT COUNT(*) AS total_rows FROM inventory;

##Demand Ranking##
#Demand ranking by city
SELECT
    city,
    SUM(quantity) AS total_demand,
    DENSE_RANK() OVER (
        ORDER BY SUM(quantity) DESC
    ) AS demand_rank
FROM orders
WHERE quantity IS NOT NULL
  AND quantity >= 0
GROUP BY city
ORDER BY demand_rank;

#Demand ranking by category
SELECT
    p.category,
    SUM(o.quantity) AS total_demand,
    DENSE_RANK() OVER (
        ORDER BY SUM(o.quantity) DESC
    ) AS demand_rank
FROM orders o
JOIN products p
    ON o.sku_id = p.sku_id
WHERE o.quantity IS NOT NULL
  AND o.quantity >= 0
GROUP BY p.category
ORDER BY demand_rank;

#Top 3 categories
WITH category_demand AS (
    SELECT
        p.category,
        SUM(o.quantity) AS total_demand
    FROM orders o
    JOIN products p
        ON o.sku_id = p.sku_id
    WHERE o.quantity IS NOT NULL
      AND o.quantity >= 0
    GROUP BY p.category
),
ranked_categories AS (
    SELECT
        category,
        total_demand,
        DENSE_RANK() OVER (
            ORDER BY total_demand DESC
        ) AS demand_rank
    FROM category_demand
)
SELECT *
FROM ranked_categories
WHERE demand_rank <= 3
ORDER BY demand_rank;

##City/hub capacity utilization##
SELECT
    hub,
    `month`,
    daily_order_capacity,
    forecast_orders,
    active_riders,
    ROUND(
        forecast_orders /
        (daily_order_capacity * DAY(LAST_DAY(`month`))) * 100,
        2
    ) AS capacity_utilization_pct,
    CASE
        WHEN forecast_orders /
             (daily_order_capacity * DAY(LAST_DAY(`month`))) > 1
            THEN 'Over Capacity'
        WHEN forecast_orders /
             (daily_order_capacity * DAY(LAST_DAY(`month`))) >= 0.8
            THEN 'High Pressure'
        ELSE 'Normal'
    END AS capacity_status
FROM hub_capacity
WHERE forecast_orders IS NOT NULL
  AND daily_order_capacity > 0
ORDER BY capacity_utilization_pct DESC;

##Stockout analysis##
SELECT
    hub,
    SUM(demand_units) AS total_demand,
    SUM(stockout_days) AS total_stockout_days,
    SUM(closing_stock) AS total_closing_stock,
    ROUND(
        SUM(stockout_days) /
        SUM(DAY(LAST_DAY(`month`))) * 100,
        2
    ) AS stockout_exposure_pct
FROM inventory
WHERE stockout_days IS NOT NULL
GROUP BY hub
ORDER BY total_stockout_days DESC;

##Customer-level CX query##
SELECT
    c.customer_id,
    COUNT(*) AS total_tickets,
    COUNT(DISTINCT cx.order_id) AS affected_orders,
    ROUND(AVG(CAST(cx.csat AS DECIMAL(10,2))), 2) AS average_csat,
    ROUND(AVG(cx.resolution_hours), 2) AS avg_resolution_hours
FROM customers c
JOIN cx_tickets cx
    ON c.customer_id = cx.customer_id
GROUP BY c.customer_id
ORDER BY total_tickets DESC;

#Delivery Delay vs CSAT
SELECT
    CASE
        WHEN dp.delay_days > 0 THEN 'Delayed'
        WHEN dp.delay_days <= 0 THEN 'On Time'
        ELSE 'Unknown'
    END AS delivery_status,

    COUNT(DISTINCT cx.ticket_id) AS total_tickets,

    ROUND(
        AVG(
            CASE
                WHEN CAST(cx.csat AS DECIMAL(10,2))
                     BETWEEN 1 AND 5
                THEN CAST(cx.csat AS DECIMAL(10,2))
                ELSE NULL
            END
        ),
        2
    ) AS average_csat

FROM cx_tickets cx
JOIN delivery_performance dp
    ON cx.order_id = dp.order_id

GROUP BY
    CASE
        WHEN dp.delay_days > 0 THEN 'Delayed'
        WHEN dp.delay_days <= 0 THEN 'On Time'
        ELSE 'Unknown'
    END

ORDER BY average_csat;

##Forecast Error Calculations##
SELECT
    `month`,
    city,
    actual_demand,
    forecast_demand,

    forecast_demand - actual_demand AS forecast_error,

    ABS(forecast_demand - actual_demand) AS absolute_error,

    ROUND(
        (1 - ABS(forecast_demand - actual_demand)
        / NULLIF(actual_demand, 0)) * 100,
        2
    ) AS forecast_accuracy_pct

FROM demand_forecast
WHERE quality_flag = 'Valid'
  AND actual_demand IS NOT NULL
  AND actual_demand > 0

ORDER BY absolute_error DESC;

#overall forecast KPIs
SELECT
    COUNT(*) AS valid_forecast_records,

    ROUND(AVG(ABS(forecast_demand - actual_demand)), 2)
        AS average_absolute_error,

    ROUND(AVG(forecast_demand - actual_demand), 2)
        AS average_forecast_bias,

    ROUND(
        1 - SUM(ABS(forecast_demand - actual_demand))
            / NULLIF(SUM(actual_demand), 0),
        4
    ) * 100 AS overall_forecast_accuracy_pct

FROM demand_forecast
WHERE quality_flag = 'Valid'
  AND actual_demand > 0;
  
##Root-cause analysis##
#Demand and Stockout Root-Cause Analysis
SELECT
    p.category,
    i.hub,
    SUM(i.demand_units) AS total_demand,
    SUM(i.stockout_days) AS total_stockout_days,
    SUM(i.closing_stock) AS total_closing_stock,
    ROUND(
        SUM(i.stockout_days) /
        NULLIF(SUM(DAY(LAST_DAY(i.month))), 0) * 100,
        2
    ) AS stockout_exposure_pct
FROM inventory i
JOIN products p
    ON i.sku_id = p.sku_id
WHERE i.stockout_days IS NOT NULL
GROUP BY
    p.category,
    i.hub
ORDER BY
    total_stockout_days DESC;

#Seller Performance
SELECT
    s.seller_id,
    s.seller_type,
    s.seller_tier,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.quantity) AS total_demand,
    ROUND(SUM(o.quantity * p.base_price), 2) AS total_order_value,
    DENSE_RANK() OVER (
        ORDER BY SUM(o.quantity * p.base_price) DESC
    ) AS revenue_rank
FROM orders o
JOIN products p
    ON o.sku_id = p.sku_id
JOIN sellers s
    ON p.seller_id = s.seller_id
WHERE o.quantity IS NOT NULL
  AND o.quantity >= 0
GROUP BY
    s.seller_id,
    s.seller_type,
    s.seller_tier
ORDER BY revenue_rank;