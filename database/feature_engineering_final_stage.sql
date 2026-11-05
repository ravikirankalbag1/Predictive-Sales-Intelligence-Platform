-- Final Query (ML DataSet)
with moving_average_summary as (
select st.product_id, d.year, d.month, d.month_number,
sum(final_price) as monthly_revenue
from sales_transaction st
left join dates d
on d.date_id = st.date_id
group by st.product_id, d.year, d.month, d.month_number
),

moving_averages as (
select product_id, year, month, month_number,
CASE WHEN COUNT(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) = 3
	THEN AVG(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
END AS moving_avg_3_month,
CASE WHEN COUNT(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) = 6
	THEN AVG(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 5 PRECEDING AND CURRENT ROW)
END AS moving_avg_6_month,
CASE WHEN COUNT(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) = 12
	THEN AVG(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 11 PRECEDING AND CURRENT ROW)
END AS moving_avg_12_month,
(monthly_revenue - LAG(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number)) / NULLIF(LAG(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number), 0) as month_over_month,
(monthly_revenue - LAG(monthly_revenue, 12) OVER (PARTITION BY product_id ORDER BY year, month_number)) / NULLIF(LAG(monthly_revenue, 12) OVER (PARTITION BY product_id ORDER BY year, month_number), 0) as year_on_year,
CASE WHEN COUNT(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) = 3
	THEN STDDEV(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
END AS moving_stdev_3_month,
CASE WHEN COUNT(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) = 6
	THEN STDDEV(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 5 PRECEDING AND CURRENT ROW)
END AS moving_stdev_6_month,
(AVG(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) - AVG(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 5 PRECEDING AND 3 PRECEDING))/ NULLIF(AVG(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 5 PRECEDING AND 3 PRECEDING),0) AS momentum
from moving_average_summary
),
	
category_revenue AS (
SELECT p.category, d.year, d.month, d.month_number,
SUM(st.final_price) AS category_revenue, SUM(st.quantity) AS category_quantity
FROM sales_transaction st
LEFT JOIN products p
ON p.product_id = st.product_id
left join dates d
on d.date_id = st.date_id
GROUP BY p.category, d.year, d.month, d.month_number
),

product_summary as (
select st.product_id, d.year, d.month, d.month_number, sum(st.final_price) as product_revenue
from sales_transaction st
left join dates d
on d.date_id = st.date_id
group by st.product_id, d.year, d.month, d.month_number
order by st.product_id, d.year, d.month_number
),

total_revenue_summary as (
select d.year, d.month, d.month_number, sum(st.final_price) as total_company_revenue
from sales_transaction st
left join dates d
on d.date_id = st.date_id
group by d.year, d.month, d.month_number
),

profit_summary as (
select st.product_id, d.year, d.month, d.month_number,
sum(st.final_price - (p.cost_price*st.quantity)) as total_profit,
avg(st.final_price - (p.cost_price*st.quantity)) as average_profit
from sales_transaction st
left join products p
on p.product_id = st.product_id
left join dates d
on d.date_id = st.date_id
group by st.product_id, d.year, d.month, d.month_number
)

select st.product_id, p.product_name, d.year, d.month, d.month_number,
sum(st.final_price) as monthly_revenue, sum(st.quantity) as monthly_quantity,
count(distinct st.transaction_id) as monthly_transactions,
round(avg(st.discount),2) as average_discount_pct,
max(st.discount) as maximum_discount,
round(sum((st.unit_price * st.quantity) - st.final_price),2) as total_discount_amount,
round(count(case when st.discount > 10 then 1 end)*100/count(*),2) as pct_transactions_discount_gt_10,
round(count(case when st.discount > 15 then 1 end)*100/count(*),2) as pct_transactions_discount_gt_15,
count(*) as total_transactions,
round(avg(st.final_price),2) as average_selling_price,
round(min(st.final_price),2) as minimum_selling_price,
round(max(st.final_price),2) as maximum_selling_price,
(max(st.final_price) - min(st.final_price)) as price_range,
sum(case when st.discount=0 then st.unit_price * st.quantity else 0 end) as non_discounted_revenue,
sum(case when st.discount>0 then st.final_price else 0 end) as discounted_revenue,
sum(case when st.discount > 0 then st.quantity else 0 end) as discounted_quantity_sold,
count(distinct case when st.discount > 0 then st.order_id end) as discounted_orders,
count(distinct st.customer_id) as unique_customers,
round(sum(st.final_price)/count(distinct st.customer_id),2) as revenue_per_customer,
round(sum(st.quantity)/count(distinct st.customer_id),2) as units_per_customer,
ROUND(SUM(st.final_price) * 100.0 / NULLIF(cr.category_revenue, 0),2) AS category_revenue_share,
ROUND(SUM(st.quantity) * 100.0 / NULLIF(cr.category_quantity, 0),2) AS category_unit_share,
pts.total_profit, pts.average_profit, round((ps.product_revenue / trs.total_company_revenue)*100, 2) as market_share,
lag(sum(st.final_price), 1) over (partition by st.product_id order by d.year, d.month_number) as lag_1_revenue,
lag(sum(st.final_price), 2) over (partition by st.product_id order by d.year, d.month_number) as lag_2_revenue,
lag(sum(st.final_price), 3) over (partition by st.product_id order by d.year, d.month_number) as lag_3_revenue,
lag(sum(st.final_price), 12) over (partition by st.product_id order by d.year, d.month_number) as lag_12_revenue,
lag(sum(st.quantity), 1) over (partition by st.product_id order by d.year, d.month_number) as lag_1_quantity,
lag(sum(st.quantity), 2) over (partition by st.product_id order by d.year, d.month_number) as lag_2_quantity,
lag(sum(st.quantity), 3) over (partition by st.product_id order by d.year, d.month_number) as lag_3_quantity,
lag(sum(st.quantity), 12) over (partition by st.product_id order by d.year, d.month_number) as lag_12_quantity,
lag(count(distinct st.transaction_id), 1) over (partition by st.product_id order by d.year, d.month_number) as lag_1_transactions,
lag(count(distinct st.transaction_id), 2) over (partition by st.product_id order by d.year, d.month_number) as lag_2_transactions,
lag(count(distinct st.transaction_id), 3) over (partition by st.product_id order by d.year, d.month_number) as lag_3_transactions,
lag(count(distinct st.transaction_id), 12) over (partition by st.product_id order by d.year, d.month_number) as lag_12_transactions,
ma.moving_avg_3_month, ma.moving_avg_6_month, ma.moving_avg_12_month, ma.moving_stdev_3_month, ma.moving_stdev_6_month, ma.momentum,
ma.month_over_month, ma.year_on_year,
CASE WHEN d.month_number IN (3,6,9,12) THEN 1 ELSE 0 END AS is_quarter_end,
CASE WHEN d.month_number IN (12) THEN 1 ELSE 0 END AS is_year_end,
d.year - MIN(d.year) OVER () as trend_year,
SIN(2 * PI() * d.month_number / 12) AS sin_month,
COS(2 * PI() * d.month_number / 12) AS cos_month,
lead(sum(final_price),1) over (partition by st.product_id order by d.year, d.month_number) as next_monthly_revenue
from sales_transaction st

left join products p
on p.product_id = st.product_id

left join dates d
on d.date_id = st.date_id

left join moving_averages ma
on ma.product_id = st.product_id and ma.year = d.year and ma.month_number = d.month_number

LEFT JOIN category_revenue cr
ON cr.category = p.category AND cr.year = d.year AND cr.month_number = d.month_number

left join product_summary ps
on ps.product_id = st.product_id and ps.year = d.year and ps.month_number = d.month_number

left join total_revenue_summary as trs
ON d.year = trs.year AND d.month_number = trs.month_number

left join profit_summary pts
ON pts.product_id = st.product_id AND pts.year = d.year AND pts.month_number = d.month_number

group by st.product_id, p.product_name, d.year, d.month, d.month_number, ma.moving_avg_3_month, ma.moving_avg_6_month, ma.moving_avg_12_month, ma.moving_stdev_3_month, ma.moving_stdev_6_month, ma.momentum,
ma.month_over_month, ma.year_on_year, cr.category_revenue, cr.category_quantity, 
ps.product_revenue, pts.total_profit, pts.average_profit, trs.total_company_revenue
order by d.year, d.month_number asc;


-- Sprint 7 (Price & Promotion)
select st.product_id, d.year, d.month,
round(avg(st.discount),2) as average_discount_pct,
max(st.discount) as maximum_discount,
round(sum((st.unit_price * st.quantity) - st.final_price),2) as total_discount_amount,
round(count(case when st.discount > 10 then 1 end)*100/count(*),2) as pct_transactions_discount_gt_10,
round(count(case when st.discount > 15 then 1 end)*100/count(*),2) as pct_transactions_discount_gt_15,
count(*) as total_transactions,
round(avg(st.final_price),2) as average_selling_price,
round(min(st.final_price),2) as minimum_selling_price,
round(max(st.final_price),2) as maximum_selling_price,
(max(st.final_price) - min(st.final_price)) as price_range,
sum(case when st.discount=0 then st.unit_price * st.quantity else 0 end) as non_discounted_revenue,
sum(case when st.discount>0 then st.final_price else 0 end) as discounted_revenue,
sum(case when st.discount > 0 then st.quantity else 0 end) as discounted_quantity_sold,
count(distinct case when st.discount > 0 then st.order_id end) as discounted_orders
from sales_transaction st
left join dates d
on d.date_id = st.date_id
left join products p
on p.product_id = st.product_id
group by st.product_id, p.product_name, d.year, d.month
order by st.product_id, p.product_name, d.year;


-- Sprint 3
-- Calculate MA (3M, 6M, 12M revenue), Growth (MoM & YoY), Momentum (Recent Avg vs Previous Avg), 3M stdev, 6M stdev
-- 9 Features here excluding product_id, year, month, month_number & target variable next_month_revenue this will be common
with moving_average_summary as (
select st.product_id, d.year, d.month, d.month_number,
sum(final_price) as monthly_revenue
from sales_transaction st
left join dates d
on d.date_id = st.date_id
group by st.product_id, d.year, d.month, d.month_number
)

select product_id, year, month, month_number,
CASE WHEN COUNT(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) = 3
	THEN AVG(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
END AS moving_avg_3_month,
CASE WHEN COUNT(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) = 6
	THEN AVG(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 5 PRECEDING AND CURRENT ROW)
END AS moving_avg_6_month,
CASE WHEN COUNT(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) = 12
	THEN AVG(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 11 PRECEDING AND CURRENT ROW)
END AS moving_avg_12_month,
(monthly_revenue - LAG(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number)) / NULLIF(LAG(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number), 0) as month_over_month,
(monthly_revenue - LAG(monthly_revenue, 12) OVER (PARTITION BY product_id ORDER BY year, month_number)) / NULLIF(LAG(monthly_revenue, 12) OVER (PARTITION BY product_id ORDER BY year, month_number), 0) as year_on_year,
CASE WHEN COUNT(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) = 3
	THEN STDDEV(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
END AS moving_stdev_3_month,
CASE WHEN COUNT(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) = 6
	THEN STDDEV(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 5 PRECEDING AND CURRENT ROW)
END AS moving_stdev_6_month,
(AVG(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) - AVG(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 5 PRECEDING AND 3 PRECEDING))/ NULLIF(AVG(monthly_revenue) OVER (PARTITION BY product_id ORDER BY year, month_number ROWS BETWEEN 5 PRECEDING AND 3 PRECEDING),0) AS momentum
from moving_average_summary
order by product_id, year, month_number;






--- Product Summary (Product + Year + month Grain)
with product_summary as (
select st.product_id, d.year, d.month, d.month_number, sum(st.final_price) as product_revenue
from sales_transaction st
left join dates d
on d.date_id = st.date_id
group by st.product_id, d.year, d.month, d.month_number
order by st.product_id, d.year, d.month_number
),

total_revenue_summary as (
select d.year, d.month, d.month_number, sum(st.final_price) as total_company_revenue
from sales_transaction st
left join dates d
on d.date_id = st.date_id
group by d.year, d.month, d.month_number
),

profit_summary as (
select st.product_id, d.year, d.month, d.month_number,
sum(st.final_price - (p.cost_price*st.quantity)) as total_profit,
avg(st.final_price - (p.cost_price*st.quantity)) as average_profit
from sales_transaction st
left join products p
on p.product_id = st.product_id
left join dates d
on d.date_id = st.date_id
group by st.product_id, d.year, d.month, d.month_number
)

select ps.product_id, p.product_name, ps.year, ps.month, ps.month_number,
pts.total_profit,
pts.average_profit,
round((ps.product_revenue / trs.total_company_revenue)*100, 2) as market_share
from product_summary ps

left join products p
on p.product_id = ps.product_id

left join total_revenue_summary as trs
ON ps.year = trs.year
AND ps.month = trs.month
AND ps.month_number = trs.month_number

left join profit_summary pts
ON pts.product_id = ps.product_id
AND pts.year = ps.year
AND pts.month = ps.month
AND pts.month_number = ps.month_number

group by ps.product_id, p.product_name, ps.year, ps.month, ps.month_number, ps.product_revenue, trs.total_company_revenue,
pts.total_profit, pts.average_profit
order by ps.product_id, p.product_name, ps.year, ps.month_number;















