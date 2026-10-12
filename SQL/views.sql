use market;

##Reusable operations KPI dataset##
CREATE OR REPLACE VIEW vw_demand_kpis AS
SELECT
    `month`,
    city,
    actual_demand,

    CASE
        WHEN quality_flag = 'Missing Forecast' THEN NULL
        ELSE forecast_demand
    END AS forecast_demand,

    CASE
        WHEN quality_flag = 'Missing Forecast' THEN NULL
        ELSE forecast_demand - actual_demand
    END AS forecast_error,

    growth_rate,
    quality_flag
FROM demand_forecast;

SELECT
    COUNT(*) AS total_records,
    SUM(actual_demand) AS total_actual_demand,
    SUM(forecast_demand) AS valid_forecast_demand,
    SUM(forecast_demand IS NULL) AS missing_forecasts
FROM vw_demand_kpis;

SELECT
    quality_flag,
    COUNT(*) AS total_records,
    SUM(forecast_demand) AS forecast_total
FROM demand_forecast
GROUP BY quality_flag;

SELECT
    quality_flag,
    COUNT(*) AS total_records,
    SUM(forecast_demand) AS forecast_total
FROM vw_demand_kpis
GROUP BY quality_flag;

SELECT
    COUNT(*) AS total_records,
    SUM(actual_demand) AS total_actual_demand,
    SUM(forecast_demand) AS valid_forecast_demand,
    SUM(quality_flag = 'Missing Forecast') AS missing_forecasts
FROM vw_demand_kpis;

SELECT *
FROM vw_demand_kpis
LIMIT 20;

SELECT
    COUNT(*) AS total_records,
    SUM(actual_demand) AS total_actual_demand,
    SUM(forecast_demand) AS total_forecast_demand,
    SUM(forecast_demand IS NULL) AS missing_forecasts
FROM demand_forecast;

SELECT
    SUM(actual_demand) AS total_actual_demand,
    SUM(forecast_demand) AS total_forecast_demand
FROM vw_demand_kpis;

SELECT
    COUNT(*) AS total_records,
    SUM(forecast_demand IS NULL) AS null_forecasts,
    SUM(forecast_demand = 0) AS zero_forecasts,
    SUM(quality_flag = 'Missing Forecast') AS flagged_missing
FROM demand_forecast;

#reusable inventory KPI view
CREATE OR REPLACE VIEW vw_inventory_kpis AS
SELECT
    hub,
    SUM(demand_units) AS total_demand,
    SUM(stockout_days) AS total_stockout_days,
    SUM(closing_stock) AS total_closing_stock,
    ROUND(
        SUM(stockout_days) /
        NULLIF(SUM(DAY(LAST_DAY(`month`))), 0) * 100,
        2
    ) AS stockout_exposure_pct
FROM inventory
WHERE stockout_days IS NOT NULL
GROUP BY hub;

SELECT *
FROM vw_inventory_kpis
ORDER BY total_stockout_days DESC;

#reusable capacity KPI view
CREATE OR REPLACE VIEW vw_capacity_kpis AS
SELECT
    hub,
    `month`,
    daily_order_capacity,
    forecast_orders,
    active_riders,

    daily_order_capacity * DAY(LAST_DAY(`month`))
        AS monthly_capacity,

    ROUND(
        forecast_orders /
        NULLIF(
            daily_order_capacity * DAY(LAST_DAY(`month`)),
            0
        ) * 100,
        2
    ) AS capacity_utilization_pct,

    CASE
        WHEN forecast_orders IS NULL
            THEN 'Missing Forecast'
        WHEN forecast_orders /
             NULLIF(
                 daily_order_capacity * DAY(LAST_DAY(`month`)),
                 0
             ) > 1
            THEN 'Over Capacity'
        WHEN forecast_orders /
             NULLIF(
                 daily_order_capacity * DAY(LAST_DAY(`month`)),
                 0
             ) >= 0.8
            THEN 'High Pressure'
        ELSE 'Normal'
    END AS capacity_status

FROM hub_capacity;

SELECT *
FROM vw_capacity_kpis
ORDER BY capacity_utilization_pct DESC;

#delivery KPI view

CREATE OR REPLACE VIEW vw_delivery_kpis AS
SELECT
    hub,
    COUNT(DISTINCT delivery_id) AS total_deliveries,

    ROUND(AVG(actual_days), 2) AS avg_actual_days,

    ROUND(AVG(delay_days), 2) AS avg_delay_days,

    SUM(
        CASE
            WHEN delay_days <= 0 THEN 1
            ELSE 0
        END
    ) AS on_time_deliveries,

    SUM(
        CASE
            WHEN delay_days > 0 THEN 1
            ELSE 0
        END
    ) AS delayed_deliveries

FROM delivery_performance
WHERE delay_days IS NOT NULL
GROUP BY hub;

SELECT *
FROM vw_delivery_kpis
ORDER BY delayed_deliveries DESC;

#
CREATE OR REPLACE VIEW vw_customer_cx_kpis AS
SELECT
    cx.customer_id,
    c.city,
    c.segment AS customer_segment,
    COUNT(cx.ticket_id) AS total_tickets,
    COUNT(DISTINCT cx.order_id) AS affected_orders,

    ROUND(
        AVG(
            CASE
                WHEN CAST(cx.csat AS DECIMAL(10,2))
                     BETWEEN 1 AND 5
                THEN CAST(cx.csat AS DECIMAL(10,2))
                ELSE NULL
            END
        ), 2
    ) AS average_csat,

    ROUND(AVG(cx.resolution_hours), 2)
        AS avg_resolution_hours

FROM cx_tickets cx
JOIN customers c
    ON cx.customer_id = c.customer_id

GROUP BY
    cx.customer_id,
    c.city,
    c.segment;
    
SELECT *
FROM vw_customer_cx_kpis
ORDER BY total_tickets DESC;

##riders api
CREATE OR REPLACE VIEW vw_rider_kpis AS
SELECT
    hub,
    COUNT(DISTINCT rider_id) AS total_riders,
    ROUND(AVG(shift_hours), 2) AS avg_shift_hours,
    ROUND(AVG(utilization), 2) AS avg_rider_utilization,
    ROUND(MIN(utilization), 2) AS min_rider_utilization,
    ROUND(MAX(utilization), 2) AS max_rider_utilization
FROM riders
GROUP BY hub;

SELECT *
FROM vw_rider_kpis
ORDER BY avg_rider_utilization DESC;
