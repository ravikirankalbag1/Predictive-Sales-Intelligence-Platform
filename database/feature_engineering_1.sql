-- Sprint 1 & Sprint 4
-- Monthly Sales Trend, is_quarter_end, is_year_end, trend_year, sin & cos month
WITH product_month_calendar AS (
SELECT p.product_id, d.year, d.month, d.month_number
FROM (SELECT DISTINCT product_id FROM sales_transaction) p
CROSS JOIN (SELECT DISTINCT year, month, month_number FROM dates WHERE year BETWEEN 2021 AND 2025) d),
monthly_sales AS (
SELECT st.product_id, d.year, d.month, d.month_number, SUM(st.final_price) AS monthly_revenue
FROM sales_transaction st
LEFT JOIN dates d ON d.date_id = st.date_id
GROUP BY st.product_id, d.month, d.year, d.month_number),

monthly_trend AS (
SELECT pm.product_id, pm.month, pm.year, pm.month_number,
COALESCE(ms.monthly_revenue, 0) AS monthly_revenue
FROM product_month_calendar pm
LEFT JOIN monthly_sales ms
ON pm.product_id = ms.product_id AND pm.year = ms.year AND pm.month_number = ms.month_number
)

SELECT product_id, month, year, month_number, monthly_revenue,
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
ORDER BY product_id, year, month_number;


-- Sprint 2
-- Calculate 3M, 6M, 12M revenue, quantity & transactions
-- Lag Features: 1M, 2M, 3M, 12M
-- Target: Next Month Revenue
-- Complete Product × Month Calendar

WITH product_month_calendar AS (
SELECT p.product_id, d.year, d.month, d.month_number
FROM (SELECT DISTINCT product_id FROM sales_transaction) p
CROSS JOIN (SELECT DISTINCT year, month, month_number FROM dates
WHERE year BETWEEN 2021 AND 2025) d),

monthly_sales AS (
SELECT st.product_id, d.year, d.month, d.month_number, SUM(st.final_price) AS monthly_revenue,
SUM(st.quantity) AS monthly_quantity, COUNT(DISTINCT st.transaction_id) AS monthly_transactions
FROM sales_transaction st
LEFT JOIN dates d
ON d.date_id = st.date_id
GROUP BY st.product_id, d.year, d.month, d.month_number),

complete_monthly_summary AS (
SELECT pm.product_id, pm.year, pm.month, pm.month_number,
COALESCE(ms.monthly_revenue, 0) AS monthly_revenue,
COALESCE(ms.monthly_quantity, 0) AS monthly_quantity,
COALESCE(ms.monthly_transactions, 0) AS monthly_transactions
FROM product_month_calendar pm
LEFT JOIN monthly_sales ms
ON pm.product_id = ms.product_id AND pm.year = ms.year AND pm.month_number = ms.month_number
)

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
FROM complete_monthly_summary
ORDER BY product_id, year, month_number;


-- Sprint 3
-- Calculate MA (3M, 6M, 12M revenue), Growth (MoM & YoY), Momentum, 3M stdev, 6M stdev
-- Complete Product × Month calendar
WITH product_month_calendar AS (
SELECT p.product_id, d.year, d.month, d.month_number
FROM (SELECT DISTINCT product_id FROM sales_transaction) p
CROSS JOIN (SELECT DISTINCT year, month, month_number FROM dates WHERE year BETWEEN 2021 AND 2025) d
),

monthly_sales AS (
SELECT st.product_id, d.year, d.month, d.month_number, SUM(st.final_price) AS monthly_revenue
FROM sales_transaction st
LEFT JOIN dates d
ON d.date_id = st.date_id
GROUP BY st.product_id, d.year, d.month, d.month_number
),

moving_average_summary AS (
SELECT pm.product_id, pm.year, pm.month, pm.month_number, COALESCE(ms.monthly_revenue, 0) AS monthly_revenue
FROM product_month_calendar pm
LEFT JOIN monthly_sales ms
ON pm.product_id = ms.product_id AND pm.year = ms.year AND pm.month_number = ms.month_number
)

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
FROM moving_average_summary
ORDER BY product_id, year, month_number;

-- Sprint 5
-- Product Performance & Consistency
WITH category_revenue AS (
SELECT p.category, SUM(st.final_price) AS category_revenue, SUM(st.quantity) AS category_quantity
FROM sales_transaction st
LEFT JOIN products p
ON p.product_id = st.product_id
GROUP BY p.category
),

monthly_units AS (
SELECT st.product_id, d.year, d.month, d.month_number, SUM(st.quantity) AS monthly_units
FROM sales_transaction st
LEFT JOIN dates d
ON d.date_id = st.date_id
GROUP BY st.product_id, d.year, d.month, d.month_number
),

monthly_units_summary AS (
SELECT product_id, ROUND(STDDEV(monthly_units) * 100 / NULLIF(AVG(monthly_units), 0),2) AS sales_consistency_cv
FROM monthly_units
GROUP BY product_id
)

SELECT p.product_id, p.product_name, ROUND(SUM(st.final_price) * 100.0 / NULLIF(cr.category_revenue, 0),2) AS category_revenue_share,
ROUND(SUM(st.quantity) * 100.0 / NULLIF(cr.category_quantity, 0),2) AS category_unit_share,
MIN(d.date) AS first_sale, MAX(d.date) AS last_sale, mus.sales_consistency_cv
FROM sales_transaction st

LEFT JOIN products p
ON p.product_id = st.product_id

LEFT JOIN category_revenue cr
ON cr.category = p.category

LEFT JOIN dates d
ON d.date_id = st.date_id

LEFT JOIN monthly_units_summary mus
ON mus.product_id = p.product_id

GROUP BY p.product_id, p.product_name, cr.category_revenue, cr.category_quantity, mus.sales_consistency_cv
ORDER BY p.product_id;

-- Product-Customer Behaviour
with product_customer as (
select st.product_id, st.customer_id, count(distinct order_id) as orders,
sum(st.quantity) as units, sum(st.final_price) as revenue
from sales_transaction st
group by st.product_id, st.customer_id
)
select product_id, count(distinct customer_id) as unique_customers,
count(CASE WHEN orders > 1 THEN 1 END) as repeat_customers,
round((count(CASE WHEN orders > 1 THEN 1 END)::numeric / NULLIF(count(distinct customer_id), 0)) * 100, 2) as repeat_customer_rate,
sum(orders) as total_orders,
sum(units) as total_units,
sum(revenue) as total_revenue,
round(sum(revenue)/count(distinct customer_id),2) as revenue_per_customer,
round(sum(units)/count(distinct customer_id),2) as units_per_customer
from product_customer
group by product_id;


-- Sprint 6
-- Store Side
with store_order as (
select s.store_id, s.store_name, st.order_id, sum(st.final_price) as order_revenue, sum(st.quantity) as order_units
from stores s left join sales_transaction st
on st.store_id = s.store_id
group by s.store_id, s.store_name, st.order_id
),

store_order_summary as (
select store_id, avg(order_revenue) as average_order_value,
avg(order_units) as average_items_per_order
from store_order
group by store_id
),

store_category as (
select st.store_id, p.category,
sum(st.final_price) as category_revenue,
count(distinct st.order_id) as category_orders,
count(distinct st.customer_id) as category_customers
from sales_transaction st
left join products p
on p.product_id = st.product_id
group by st.store_id, p.category
),

share_calculations as (
select store_id, category,
round(category_revenue*100 / nullif(sum(category_revenue) over (partition by store_id), 0),2) as revenue_share,
round(category_orders*100 / nullif(sum(category_orders) over (partition by store_id), 0),2) as order_share,
round(category_customers*100 / nullif(sum(category_customers) over (partition by store_id), 0),2) as customer_share
from store_category
),

selling_category as (
select store_id, category, revenue_share + order_share + customer_share as composite_share,
row_number() over (partition by store_id order by (revenue_share + order_share + customer_share) desc) as share_rank
from share_calculations
),

best_selling_category as (
select * from selling_category where share_rank = 1
),

peak_month_summary as (
select s.store_id, d.month, d.month_number, sum(st.final_price) as revenue,
row_number() over (partition by s.store_id order by sum(final_price) desc) as peak_rank
from stores s
left join sales_transaction st
on st.store_id = s.store_id
left join dates d
on d.date_id = st.date_id
group by s.store_id, d.month, d.month_number
),

peak_summary as (
select * from peak_month_summary
where peak_rank = 1
)

select s.store_id, s.store_name, 
sum(final_price) as total_revenue, 
count(distinct st.transaction_id) as total_transactions,
sum(st.quantity) as total_units_sold,
count(distinct st.customer_id) as unique_customers,
round(sos.average_order_value,2) as average_order_value, 
round(sos.average_items_per_order,2) as average_items_per_order,
bsc.category as best_selling_category,
ps.month as peak_month
from stores s
left join sales_transaction st
on s.store_id = st.store_id
left join store_order_summary sos
on sos.store_id = s.store_id
left join best_selling_category bsc
on bsc.store_id = s.store_id
left join peak_summary ps
on ps.store_id = s.store_id
group by s.store_id, s.store_name, sos.average_order_value, sos.average_items_per_order, bsc.category, ps.month;

-- Customer Side
with purchase_orders as (
select st.customer_id, count(distinct st.order_id) as total_orders,
GREATEST(FLOOR((MAX(d.date) - MIN(d.date)) / 30.4375), 1) as active_months
from sales_transaction st
left join dates d
on d.date_id = st.date_id
group by customer_id
),
monthly_orders as (
select st.customer_id, d.year, d.month, d.month_number, count(distinct order_id) as monthly_orders
from sales_transaction st
left join dates d
on d.date_id = st.date_id
group by customer_id, d.year, d.month, d.month_number
order by st.customer_id, d.year, d.month_number
)
select  c.customer_id, round(po.total_orders / po.active_months, 2) as purchase_frequency,
round(stddev(mo.monthly_orders)/ avg(mo.monthly_orders),2) as purchase_consistency,
ROUND((po.total_orders - 1) * 100.0 / NULLIF(po.total_orders, 0),2) AS repeat_purchase_rate,
round(avg(st.discount),2) as average_discount_received,
round(avg(st.final_price),2) as average_price_paid
from customers c
left join sales_transaction st
on c.customer_id = st.customer_id
left join purchase_orders po
on po.customer_id = c.customer_id
left join monthly_orders mo
on mo.customer_id = c.customer_id
group by c.customer_id, po.total_orders, po.active_months;


-- Sprint 7 (Price & Promotion)
WITH product_month_calendar AS (
SELECT p.product_id, d.year, d.month, d.month_number
FROM (SELECT DISTINCT product_id FROM sales_transaction) p
CROSS JOIN (SELECT DISTINCT year, month, month_number FROM dates WHERE year BETWEEN 2021 AND 2025) d
),

price_promotion_summary AS (
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
GROUP BY st.product_id, d.year, d.month, d.month_number)

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
LEFT JOIN price_promotion_summary pp 
ON pm.product_id = pp.product_id AND pm.year = pp.year AND pm.month_number = pp.month_number

LEFT JOIN products p 
ON pm.product_id = p.product_id

ORDER BY pm.product_id, pm.year, pm.month_number;


-- Sprint 8
