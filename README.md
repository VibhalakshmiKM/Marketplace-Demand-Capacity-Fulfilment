Marketplace Demand, Capacity & Fulfilment Analytics
Project Overview
This project analyzes an e-commerce marketplace's demand, inventory availability, hub capacity, delivery operations, and customer experience to support peak-season planning. The goal is to help business teams make evidence-based operational decisions while managing forecast uncertainty and capacity costs.
Business Objectives
- Identify demand patterns by city, product category, customer segment, channel, and time period.
- Evaluate forecast accuracy, forecast error, and forecast bias.
- Analyze inventory availability and stockout exposure.
- Compare forecast demand with available hub capacity.
- Examine rider utilization, delivery delays, and on-time performance.
- Analyze support tickets, customer satisfaction (CSAT), and resolution time.
- Support a phased, evidence-based peak-season investment recommendation for the ₹25 crore budget.
Tools & Technologies
- Excel: Data-quality audit, data cleaning, analytical model, and operational analysis.
- MySQL: Data joins, aggregations, CTEs, window functions, forecast calculations, and reusable KPI views.
- Power BI: Interactive dashboards, KPI cards, charts, matrix, donut chart, and slicers.
Project Workflow
1. Data Quality & Preparation: Audited source datasets and documented cleaning decisions for missing, duplicate, invalid, and inconsistent values.
2. Excel Analysis: Prepared an analytical model and analyzed demand, forecasts, inventory, capacity, delivery performance, and customer support.
3. SQL Analysis: Created analytical queries and reusable views to summarize demand, inventory, capacity, delivery, and customer-experience metrics.
4. Power BI Reporting: Connected the analytical data to Power BI and built five dashboard pages.
5. Business Recommendation: Used the analysis to frame peak-season investment priorities, operational risks, and weekly monitoring metrics.
SQL Analysis
The SQL work includes:
- Demand ranking by city and product category.
- Forecast error, absolute error, forecast accuracy, and forecast bias.
- Inventory and stockout analysis by hub and category.
- Capacity utilization by hub and month.
- Delivery delay and on-time delivery metrics.
- Customer-level ticket volume, CSAT, and resolution-time analysis.
- Reusable KPI views:
  - vw_demand_kpis
  - vw_inventory_kpis
  - vw_capacity_kpis
  - vw_delivery_kpis
  - vw_customer_cx_kpis
  - vw_rider_kpis (if included in the final SQL scripts)
Power BI Dashboards
1. COO Peak-Season Scorecard — Executive view of demand, stockouts, forecast demand, and delivery performance.
2. Demand & Forecasting — Actual versus forecast demand, forecast accuracy, forecast error/bias, and demand trends.
3. Inventory & Availability — Demand units, stockout days, closing stock, and inventory risk by hub.
4. Hub, Rider & Delivery Operations — Capacity utilization, rider utilization, delayed deliveries, and on-time delivery performance.
5. Customer Experience & Operational Risk — Support tickets, customer satisfaction, resolution time, matrix analysis, and ticket share by segment.
Key Business Considerations
- Forecast uncertainty should not automatically lead to permanent capacity expansion.
- Distinguish demand shortage, inventory shortage, and capacity shortage before recommending an intervention.
- Estimated demand exposure is not the same as confirmed lost sales unless lost orders are directly observed.
- Correlation between delays and customer satisfaction does not by itself prove causation.
- Validate metric definitions, data quality, aggregation, and assumptions before using KPIs for investment decisions.
Peak-Season Recommendation Framework
Use a phased approach to the ₹25 crore planning scenario:
- Scale: Replenishment for high-demand products and hubs with verified stockout exposure.
- Reduce: Avoidable stockouts, excess inventory in low-demand locations, and unnecessary permanent-capacity spending.
- Rebalance: Inventory, rider shifts, and operational resources toward locations with demonstrated pressure.
- Test: Temporary hub capacity, flexible staffing, and forecasting improvements in selected locations before scaling.
- Monitor weekly: Weighted forecast accuracy and bias, stockout exposure, hub capacity utilization, on-time delivery rate, and CSAT or support resolution time.
Final budget allocations and expected savings should be based on validated scenario assumptions and documented calculations; they are not stated here because no verified allocation amounts or realized savings have been provided.
Repository Structure
marketplace-demand-capacity-analytics/
├── README.md
├── excel/                # Excel audit and analytical workbooks
├── sql/                  # SQL analysis scripts and KPI views
├── powerbi/              # Power BI .pbix file

How to Explore the Project
1. Review the Excel workbook to understand data-quality decisions and analytical preparation.
2. Run the SQL scripts against a compatible MySQL database after checking table and column names.
3. Open the Power BI .pbix file to explore the five dashboard pages. Refreshing may require access to the source database and updating connection settings.
