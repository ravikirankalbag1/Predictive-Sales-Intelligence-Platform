-- Product-Customer Behaviour (Product + Year + Month Level)
WITH product_month AS (
SELECT p.product_id, d.year, d.month, d.month_number
FROM products p
CROSS JOIN (SELECT DISTINCT year, month, month_number
FROM dates
WHERE year BETWEEN 2021 AND 2025) d
),

product_customer AS (
SELECT st.product_id, d.year, d.month, d.month_number, st.customer_id, 
COUNT(DISTINCT st.order_id) AS orders, SUM(st.quantity) AS units, SUM(st.final_price) AS revenue
FROM sales_transaction st
LEFT JOIN dates d
ON d.date_id = st.date_id
GROUP BY st.product_id, d.year, d.month, d.month_number, st.customer_id),

repeat_summary AS ( 
SELECT st.product_id, st.customer_id, MIN(d.date) AS first_sale
FROM sales_transaction st
LEFT JOIN dates d
ON d.date_id = st.date_id
GROUP BY st.product_id, st.customer_id),

customer_summary AS (
SELECT pc.product_id, pc.year, pc.month, pc.month_number,
COUNT(DISTINCT pc.customer_id) AS unique_customers,
COUNT(CASE WHEN rs.first_sale < make_date( pc.year::int, pc.month_number::int, 1)
THEN pc.customer_id END
) AS repeat_customers, SUM(pc.orders) AS total_orders, SUM(pc.units) AS total_units, SUM(pc.revenue) AS total_revenue
FROM product_customer pc
LEFT JOIN repeat_summary rs
ON rs.product_id = pc.product_id
AND rs.customer_id = pc.customer_id 
GROUP BY pc.product_id, pc.year, pc.month, pc.month_number
)

SELECT pm.product_id,pm.year,pm.month,pm.month_number,
COALESCE(cs.unique_customers, 0) AS unique_customers,
COALESCE(cs.repeat_customers, 0) AS repeat_customers, 
CASE WHEN COALESCE(cs.unique_customers, 0) = 0 THEN 0 ELSE ROUND(
(cs.repeat_customers::numeric/ cs.unique_customers) * 100,2)
END AS repeat_customer_rate,
COALESCE(cs.total_orders, 0) AS total_orders,
COALESCE(cs.total_units, 0) AS total_units,
COALESCE(cs.total_revenue, 0) AS total_revenue,
CASE WHEN COALESCE(cs.unique_customers, 0) = 0 THEN 0
ELSE ROUND(cs.total_revenue / cs.unique_customers,2)
END AS revenue_per_customer,
CASE WHEN COALESCE(cs.unique_customers, 0) = 0 
THEN 0 ELSE ROUND(cs.total_units::numeric / cs.unique_customers,2)END AS units_per_customer
FROM product_month pm
LEFT JOIN customer_summary cs
ON cs.product_id = pm.product_id
AND cs.year = pm.year AND cs.month = pm.month AND cs.month_number = pm.month_number

ORDER BY pm.product_id, pm.year, pm.month_number;


-- Product Summary (Product + Year + Month Grain)
WITH product_month_grid AS (
SELECT p.product_id, p.product_name, d.year, d.month, d.month_number
FROM products p
CROSS JOIN (SELECT DISTINCT year, month, month_number
FROM dates WHERE year BETWEEN 2021 AND 2025) d),

product_summary AS (
SELECT st.product_id, d.year, d.month, d.month_number, SUM(st.final_price) AS product_revenue
FROM sales_transaction st
LEFT JOIN dates d
ON d.date_id = st.date_id
GROUP BY st.product_id, d.year, d.month, d.month_number),

total_revenue_summary AS (SELECT d.year,d.month,d.month_number,SUM(st.final_price) AS total_company_revenue
FROM sales_transaction st
LEFT JOIN dates d
ON d.date_id = st.date_id
GROUP BY d.year, d.month, d.month_number),

profit_summary AS (SELECT st.product_id, d.year, d.month, d.month_number, 
SUM( st.final_price - (p.cost_price * st.quantity)) AS total_profit, AVG( st.final_price - (p.cost_price * st.quantity) ) AS average_profit
FROM sales_transaction st
LEFT JOIN products p
ON p.product_id = st.product_id
LEFT JOIN dates d
ON d.date_id = st.date_id
GROUP BY st.product_id, d.year, d.month, d.month_number)

SELECT pmg.product_id, pmg.product_name, pmg.year, pmg.month,pmg.month_number,
COALESCE(ps.product_revenue, 0) AS product_revenue,
COALESCE(pts.total_profit, 0) AS total_profit,
COALESCE(pts.average_profit, 0) AS average_profit,
COALESCE(ROUND((COALESCE(ps.product_revenue, 0)/ NULLIF(trs.total_company_revenue, 0)) * 100),0) AS market_share

FROM product_month_grid pmg

LEFT JOIN product_summary ps
ON ps.product_id = pmg.product_id
AND ps.year = pmg.year AND ps.month = pmg.month AND ps.month_number = pmg.month_number

LEFT JOIN total_revenue_summary trs
ON trs.year = pmg.year AND trs.month = pmg.month AND trs.month_number = pmg.month_number

LEFT JOIN profit_summary pts
ON pts.product_id = pmg.product_id AND pts.year = pmg.year AND pts.month = pmg.month AND pts.month_number = pmg.month_number

ORDER BY pmg.product_id, pmg.year, pmg.month_number;










