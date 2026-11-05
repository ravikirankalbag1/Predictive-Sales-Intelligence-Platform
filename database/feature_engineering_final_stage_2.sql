WITH product_month_calendar AS (
SELECT p.product_id, d.year, d.month, d.month_number
FROM (SELECT DISTINCT product_id FROM sales_transaction) p
CROSS JOIN (SELECT DISTINCT year, month, month_number FROM dates 
WHERE year BETWEEN 2021 AND 2025) d),

monthly_trend_sales AS (
SELECT st.product_id, d.year, d.month, d.month_number,
count(distinct st.customer_id) as unique_customers,
round(sum(st.final_price)/count(distinct st.customer_id),2) as revenue_per_customer,
round(sum(st.quantity)/count(distinct st.customer_id),2) as units_per_customer,
SUM(st.final_price) AS monthly_revenue,
sum(st.final_price - (p.cost_price*st.quantity)) as total_profit,
avg(st.final_price - (p.cost_price*st.quantity)) as average_profit
FROM sales_transaction st
LEFT JOIN dates d ON d.date_id = st.date_id
LEFT JOIN products p ON p.product_id = st.product_id
GROUP BY st.product_id, d.month, d.year, d.month_number),

monthly_trend AS (
SELECT pm.product_id, pm.month, pm.year, pm.month_number,
COALESCE(mcs.monthly_revenue, 0) AS monthly_revenue,
mcs.unique_customers, mcs.units_per_customer, mcs.revenue_per_customer,
mcs.total_profit, mcs.average_profit
FROM product_month_calendar pm
LEFT JOIN monthly_trend_sales mcs
ON pm.product_id = mcs.product_id AND pm.year = mcs.year AND pm.month_number = mcs.month_number
),

monthly_sales_summary as (
SELECT product_id, month, year, month_number, monthly_revenue,
unique_customers, units_per_customer, revenue_per_customer,
total_profit, average_profit,
LEAD(monthly_revenue, 1) OVER (PARTITION BY product_id ORDER BY year, month_number
) AS next_monthly_revenue,
CASE WHEN month_number IN (3, 6, 9, 12) THEN 1 ELSE 0
END AS is_quarter_end,
CASE WHEN month_number = 12 THEN 1 ELSE 0 
END AS is_year_end,
year - MIN(year) OVER () AS trend_year,
SIN(2 * PI() * month_number / 12) AS sin_month,
COS(2 * PI() * month_number / 12) AS cos_month
FROM monthly_trend
ORDER BY product_id, year, month_number
),

monthly_sales AS (
SELECT st.product_id, d.year, d.month, d.month_number, SUM(st.final_price) AS monthly_revenue,
SUM(st.quantity) AS monthly_quantity, COUNT(DISTINCT st.transaction_id) AS monthly_transactions
FROM sales_transaction st
LEFT JOIN dates d
ON d.date_id = st.date_id
GROUP BY st.product_id, d.year, d.month, d.month_number),

complete_monthly AS (
SELECT pm.product_id, pm.year, pm.month, pm.month_number,
COALESCE(ms.monthly_revenue, 0) AS monthly_revenue,
COALESCE(ms.monthly_quantity, 0) AS monthly_quantity,
COALESCE(ms.monthly_transactions, 0) AS monthly_transactions
FROM product_month_calendar pm
LEFT JOIN monthly_sales ms
ON pm.product_id = ms.product_id AND pm.year = ms.year AND pm.month_number = ms.month_number
),

lag_summary as (
SELECT product_id, year, month, month_number, monthly_revenue, monthly_quantity, monthly_transactions,
LAG(monthly_revenue, 1) OVER (PARTITION BY product_id ORDER BY year, month_number) AS lag_1_revenue,
LAG(monthly_revenue, 2) OVER (PARTITION BY product_id ORDER BY year, month_number) AS lag_2_revenue,
LAG(monthly_revenue, 3) OVER (PARTITION BY product_id ORDER BY year, month_number) AS lag_3_revenue,
LAG(monthly_revenue, 12) OVER (PARTITION BY product_id ORDER BY year, month_number) AS lag_12_revenue,
LAG(monthly_quantity, 1) OVER (PARTITION BY product_id ORDER BY year, month_number) AS lag_1_quantity,
LAG(monthly_quantity, 2) OVER (PARTITION BY product_id ORDER BY year, month_number) AS lag_2_quantity,
LAG(monthly_quantity, 3) OVER (PARTITION BY product_id ORDER BY year, month_number) AS lag_3_quantity,
LAG(monthly_quantity, 12) OVER (PARTITION BY product_id ORDER BY year, month_number) AS lag_12_quantity,
LAG(monthly_transactions, 1) OVER (PARTITION BY product_id ORDER BY year, month_number) AS lag_1_transactions,
LAG(monthly_transactions, 2) OVER (PARTITION BY product_id ORDER BY year, month_number) AS lag_2_transactions,
LAG(monthly_transactions, 3) OVER (PARTITION BY product_id ORDER BY year, month_number) AS lag_3_transactions,
LAG(monthly_transactions, 12) OVER (PARTITION BY product_id ORDER BY year, month_number) AS lag_12_transactions,
LEAD(monthly_revenue, 1) OVER (PARTITION BY product_id ORDER BY year, month_number) AS next_monthly_revenue
FROM complete_monthly
ORDER BY product_id, year, month_number
),

moving_averages AS (
SELECT pm.product_id, pm.year, pm.month, pm.month_number, COALESCE(ms.monthly_revenue, 0) AS monthly_revenue
FROM product_month_calendar pm
LEFT JOIN monthly_sales ms
ON pm.product_id = ms.product_id AND pm.year = ms.year AND pm.month_number = ms.month_number
),

moving_average_summary as (
SELECT product_id, year, month, month_number,
CASE WHEN COUNT(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) = 3
THEN AVG(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
END AS moving_avg_3_month,
CASE WHEN COUNT(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) = 6
THEN AVG(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 5 PRECEDING AND CURRENT ROW)
END AS moving_avg_6_month,
CASE WHEN COUNT(monthly_revenue) OVER ( PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) = 12
THEN AVG(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 11 PRECEDING AND CURRENT ROW)
END AS moving_avg_12_month,
(monthly_revenue - LAG(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number)) / NULLIF(LAG(monthly_revenue) OVER (
PARTITION BY product_id ORDER BY year, month_number), 0
) AS month_over_month,
(monthly_revenue - LAG(monthly_revenue, 12) OVER (PARTITION BY product_id ORDER BY year, month_number)) / NULLIF( LAG(monthly_revenue, 12) OVER (
PARTITION BY product_id ORDER BY year, month_number), 0) AS year_on_year,
CASE WHEN COUNT(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) = 3
THEN STDDEV(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
END AS moving_stdev_3_month,
CASE WHEN COUNT(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) = 6
THEN STDDEV(monthly_revenue) OVER (PARTITION BY product_id
ORDER BY year, month_number ROWS BETWEEN 5 PRECEDING AND CURRENT ROW)
END AS moving_stdev_6_month,
(AVG(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
 - AVG(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 5 PRECEDING AND 3 PRECEDING))
/ NULLIF(AVG(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 5 PRECEDING AND 3 PRECEDING), 0
) AS momentum
FROM moving_averages
ORDER BY product_id, year, month_number
),

category_revenue_summary AS (
SELECT st.product_id, p.category, d.year, d.month, d.month_number,
ROUND(SUM(st.final_price) * 100.0 / NULLIF(SUM(st.final_price), 0),2) AS category_revenue_share,
ROUND(SUM(st.quantity) * 100.0 / NULLIF(SUM(st.final_price), 0),2) AS category_unit_share
FROM sales_transaction st
LEFT JOIN products p
ON p.product_id = st.product_id
left join dates d
on d.date_id = st.date_id
GROUP BY st.product_id, p.category, d.year, d.month, d.month_number
),

price_promotion AS (
SELECT st.product_id, d.year, d.month, d.month_number,
ROUND(AVG(st.discount), 2) AS average_discount_pct,
MAX(st.discount) AS maximum_discount,
ROUND(SUM((st.unit_price * st.quantity) - st.final_price), 2) AS total_discount_amount,
ROUND(COUNT(CASE WHEN st.discount > 10 THEN 1 END)* 100.0 / COUNT(*),2) AS pct_transactions_discount_gt_10,
ROUND(COUNT(CASE WHEN st.discount > 15 THEN 1 END)* 100.0 / COUNT(*),2) AS pct_transactions_discount_gt_15,
COUNT(*) AS total_transactions,
ROUND(AVG(st.final_price), 2) AS average_selling_price,
ROUND(MIN(st.final_price), 2) AS minimum_selling_price,
ROUND(MAX(st.final_price), 2) AS maximum_selling_price,
ROUND(MAX(st.final_price) - MIN(st.final_price),2) AS price_range,
SUM(CASE WHEN st.discount = 0 THEN st.unit_price * st.quantity ELSE 0
END) AS non_discounted_revenue,
SUM(CASE WHEN st.discount > 0 THEN st.final_price ELSE 0 
END) AS discounted_revenue,
SUM(CASE WHEN st.discount > 0 THEN st.quantity ELSE 0 END) AS discounted_quantity_sold,
COUNT(DISTINCT CASE WHEN st.discount > 0 THEN st.order_id END) AS discounted_orders
FROM sales_transaction st
LEFT JOIN dates d 
ON d.date_id = st.date_id
GROUP BY st.product_id, d.year, d.month, d.month_number
),

price_and_promotion_summary as (
SELECT pm.product_id, p.product_name, pm.year, pm.month, pm.month_number,
COALESCE(pp.average_discount_pct, 0) AS average_discount_pct,
COALESCE(pp.maximum_discount, 0) AS maximum_discount,
COALESCE(pp.total_discount_amount, 0) AS total_discount_amount, 
COALESCE(pp.pct_transactions_discount_gt_10, 0) AS pct_transactions_discount_gt_10,
COALESCE(pp.pct_transactions_discount_gt_15, 0) AS pct_transactions_discount_gt_15,
COALESCE(pp.total_transactions, 0) AS total_transactions,
COALESCE(pp.average_selling_price, 0) AS average_selling_price,
COALESCE(pp.minimum_selling_price, 0) AS minimum_selling_price, 
COALESCE(pp.maximum_selling_price, 0) AS maximum_selling_price, 
COALESCE(pp.price_range, 0) AS price_range, 
COALESCE(pp.non_discounted_revenue, 0) AS non_discounted_revenue, 
COALESCE(pp.discounted_revenue, 0) AS discounted_revenue, 
COALESCE(pp.discounted_quantity_sold, 0) AS discounted_quantity_sold,
COALESCE(pp.discounted_orders, 0) AS discounted_orders

FROM product_month_calendar pm
LEFT JOIN price_promotion pp 
ON pm.product_id = pp.product_id AND pm.year = pp.year AND pm.month_number = pp.month_number
LEFT JOIN products p 
ON pm.product_id = p.product_id

ORDER BY pm.product_id, pm.year, pm.month_number
)

SELECT mss.product_id, pps.product_name, mss.year, mss.month, mss.month_number, mss.monthly_revenue,
mss.unique_customers, mss.units_per_customer, mss.revenue_per_customer, mss.next_monthly_revenue, 
mss.is_quarter_end, mss.is_year_end, mss.trend_year, mss.sin_month, mss.cos_month,
ls.monthly_quantity, ls.monthly_transactions, ls.lag_1_revenue, ls.lag_2_revenue, ls.lag_3_revenue, ls.lag_12_revenue, 
ls.lag_1_quantity, ls.lag_2_quantity, ls.lag_3_quantity, ls.lag_12_quantity, 
ls.lag_1_transactions, ls.lag_2_transactions, ls.lag_3_transactions, ls.lag_12_transactions,mas.moving_avg_3_month,mas.moving_avg_6_month,mas.moving_avg_12_month,
mas.month_over_month,mas.year_on_year, mas.moving_stdev_3_month,mas.moving_stdev_6_month,mas.momentum,
crs.category_revenue_share, crs.category_unit_share,
mss.total_profit, mss.average_profit, pps.average_discount_pct, pps.maximum_discount, pps.total_discount_amount, 
pps.pct_transactions_discount_gt_10, pps.pct_transactions_discount_gt_15, 
pps.average_selling_price, pps.minimum_selling_price, pps.maximum_selling_price, pps.price_range, pps.non_discounted_revenue, pps.discounted_revenue,
pps.discounted_quantity_sold, pps.discounted_orders
FROM monthly_sales_summary mss

LEFT JOIN lag_summary ls
ON mss.product_id = ls.product_id AND mss.year = ls.year AND mss.month_number = ls.month_number

LEFT JOIN moving_average_summary mas  
ON mss.product_id = mas.product_id AND mss.year = mas.year AND mss.month_number = mas.month_number

LEFT JOIN price_and_promotion_summary pps 
ON mss.product_id = pps.product_id AND mss.year = pps.year AND mss.month_number = pps.month_number

LEFT JOIN category_revenue_summary crs
ON mss.product_id = crs.product_id AND mss.year = crs.year AND mss.month_number = crs.month_number

ORDER BY mss.product_id, mss.year, mss.month_number;
