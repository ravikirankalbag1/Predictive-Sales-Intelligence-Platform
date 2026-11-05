-- customer summary
WITH order_summary AS (
    SELECT
        customer_id,
        order_id,
        SUM(final_price) AS order_total,
		SUM(quantity) AS total_items
    FROM sales_transaction
    GROUP BY customer_id, order_id
),

category_summary AS (
select st.customer_id, p.category, count(p.category) as category_count, 
row_number() over (partition by customer_id order by count(p.category) desc) as category_rank
from sales_transaction st
left join products p
on p.product_id = st.product_id
group by p.category,st.customer_id
),

product_summary AS (
select st.customer_id, p.product_name, count(p.product_name) as product_count, 
row_number() over (partition by customer_id order by count(p.product_name) desc) as product_rank
from sales_transaction st
left join products p
on p.product_id = st.product_id
group by p.product_name,st.customer_id
),

price_band_summary as (
select customer_id,
case 
  when final_price < 500 then 'Low'
  when final_price between 500 and 2000 then 'Medium'
  when final_price between 2000 and 6000 then 'High'
  else 'Premium'
end as price_band, 
count(*) as purchase_count,
row_number() over (partition by customer_id order by count(*) desc) as price_band_rank
from sales_transaction
group by customer_id, price_band
),

customer_order_summary AS (
    SELECT
        customer_id,
        COUNT(order_id) AS total_orders,
        AVG(order_total) AS average_order_value,
		AVG(total_items) AS average_items_per_order
    FROM order_summary
    GROUP BY customer_id
),

category_order_summary AS (
select * from category_summary
where category_rank = 1
),

product_order_summary AS (
select * from product_summary
where product_rank = 1
),

price_order_summary AS (
select * from price_band_summary
where price_band_rank = 1
)

select c.customer_id, c.customer_name, c.age, c.gender, c.membership, c.join_date,
cos.total_orders, sum(st.final_price) as total_revenue,
avg(st.discount) as average_discount_percentage,
sum(quantity) as total_quantity_purchased,
count(distinct st.product_id) as total_distinct_products_bought,
cos.average_order_value, cos.average_items_per_order,
min(d.date) as first_transaction_date,
max(d.date) as last_transaction_date,
count(distinct p.category) as distinct_categories_purchased,
(sum(st.final_price) - sum((p.cost_price*st.quantity))) as total_profits_generated,
'2025-12-31'::date - max(d.date::date) as recency_days,
caos.category as favourite_category,
pos.product_name as most_purchased_product,
ps.price_band as preferred_price_band
from customers c

left join sales_transaction st
on st.customer_id = c.customer_id

left join dates d
on d.date_id = st.date_id

left join products p
on st.product_id = p.product_id

left join customer_order_summary cos
on cos.customer_id = c.customer_id

left join category_order_summary caos
on caos.customer_id = c.customer_id

left join product_order_summary as pos
on pos.customer_id = c.customer_id

left join price_order_summary as ps
on ps.customer_id = c.customer_id

group by c.customer_id, c.customer_name, c.age, c.gender, c.join_date, c.membership, 
cos.total_orders, cos.average_order_value, cos.average_items_per_order, caos.category, pos.product_name, ps.price_band;


--- Product Summary
with discount_summary as (
select product_id, avg(discount) as average_discount 
from sales_transaction
group by product_id
),

profit_summary as (
select st.product_id, 
sum(st.final_price - (p.cost_price*st.quantity)) as total_profit,
avg(st.final_price - (p.cost_price*st.quantity)) as average_profit
from sales_transaction st
left join products p
on p.product_id = st.product_id
group by st.product_id
),

repeat_customer_summary as (
select customer_id, product_id, count(product_id) as purchase_count
from sales_transaction
group by customer_id, product_id
having count(product_id) > 1
),

repeat_summary as (
select product_id, sum(purchase_count - 1) as repeat_purchase
from repeat_customer_summary
group by product_id
),

transaction_summary as (
select product_id, count(distinct order_id) as total_transaction
from sales_transaction
group by product_id
),

product_summary as (
select product_id, sum(final_price) as product_revenue
from sales_transaction
group by product_id
),

total_revenue_summary as (
select sum(final_price) as total_company_revenue
from sales_transaction
)

select st.product_id, p.product_name, sum(st.quantity) as total_units_sold,
avg(final_price) as average_selling_price,
sum(final_price) as total_revenue,
count(distinct st.customer_id) as unique_customers, 
ds.average_discount as average_discount, 
ps.total_profit,
ps.average_profit,
COALESCE(rs.repeat_purchase,0) as repeat_purchase,
ts.total_transaction,
round((prs.product_revenue / trs.total_company_revenue)*100, 2) as market_share
from sales_transaction st

left join products p
on p.product_id = st.product_id

left join discount_summary ds
on ds.product_id = st.product_id

left join profit_summary as ps
on ps.product_id = st.product_id

left join repeat_summary rs
on rs.product_id = st.product_id

left join transaction_summary ts
on ts.product_id = st.product_id

left join product_summary as prs
on prs.product_id = st.product_id

cross join total_revenue_summary as trs

group by 
st.product_id, p.product_name, ds.average_discount,
ps.total_profit, ps.average_profit, rs.repeat_purchase, ts.total_transaction, prs.product_revenue, trs.total_company_revenue;


--- Store Summary
with store_category as (
select st.store_id, p.category, count(p.category),
row_number() over (partition by store_id order by count(p.category) desc) as store_rank
from products p
left join sales_transaction st
on st.product_id = p.product_id
group by st.store_id, p.category
),

store_category_summary as (
select store_id, category from store_category
where store_rank = 1
),

peak_month_summary as (
select st.store_id, s.store_name, d.year, d.month, sum(st.final_price) as revenue,
row_number() over (partition by st.store_id order by sum(st.final_price) desc) as row_num
from sales_transaction st
left join stores s
on s.store_id = st.store_id
left join dates d
on d.date_id = st.date_id
group by st.store_id, s.store_name, d.year, d.month
),

store_peak_month as (
select store_id, store_name, year, month, revenue 
from peak_month_summary
where row_num = 1
)

select s.store_id, s.store_name, scs.category as best_selling_category,
spm.year as peak_year, spm.month as peak_month, spm.revenue as peak_revenue
from stores s

left join store_category_summary scs
on scs.store_id = s.store_id

left join store_peak_month as spm
on spm.store_id = s.store_id
order by s.store_id;


-- Store Monthly Summary
with order_summary as (
select st.store_id, d.year, d.month, order_id, sum(final_price) as order_total
from sales_transaction st
left join dates d
on d.date_id = st.date_id
group by st.store_id, d.year, d.month, order_id
),

store_aov_summary as (
select store_id, year, month,
avg(order_total) as avg_order_total
from order_summary
group by store_id, year, month 
)

select st.store_id, d.year, d.month,
aos.avg_order_total as average_order_value,
count(distinct order_id) as total_transactions, 
count(distinct customer_id) as total_customers,
sum(final_price) as revenue,
sum(quantity) as total_units_sold
from sales_transaction st

left join dates d
on st.date_id = d.date_id

left join store_aov_summary aos
on aos.store_id = st.store_id
and aos.year = d.year
and aos.month = d.month

group by st.store_id, d.year, d.month, aos.avg_order_total;

-- Store Yearly Summary
with order_yearly_summary as (
select st.store_id, st.order_id, st.customer_id, d.year, sum(st.final_price) as order_value
from sales_transaction st
left join stores s
on s.store_id = st.store_id
left join dates d
on d.date_id = st.date_id
group by st.store_id, st.order_id, st.customer_id, d.year
order by d.year asc
),

store_yearly_summary as (
select store_id, year, avg(order_value) as average_order_value,
count(distinct order_id) as total_transactions,
count(distinct customer_id) as total_customers
from order_yearly_summary
group by store_id, year
order by store_id, year
)

select s.store_id, s.store_name, sys.year, 
sys.average_order_value as yearly_average_order_value,
sys.total_transactions as total_transactions,
sys.total_customers as total_customers
from stores s
left join store_yearly_summary sys
on sys.store_id = s.store_id
order by s.store_id, sys.year;


-- Sales Transaction Summary

with order_values as (
select order_id, sum(final_price) as order_value
from sales_transaction
group by order_id
),

percentiles as (
select 
percentile_cont(0.25) within group (order by order_value) as P25,
percentile_cont(0.50) within group (order by order_value) as P50,
percentile_cont(0.75) within group (order by order_value) as P75
from order_values
),

dates_summary as (
select date_id, month,
case 
	when month IN ('February', 'March', 'April', 'May') then 'Summer'
	when month IN ('June', 'July', 'August', 'September') then 'Monsoon'
	else 'Winter'
end as Season
from dates
),

festive_summary as (
select date_id,
case
	when month IN ('October', 'November', 'August') then 'Festive Season'
	else 'Non-Festive Season'
end as Festival
from dates
)

select st.order_id, sum(st.final_price - (p.cost_price * st.quantity)) as profit,
round(sum(st.unit_price * st.quantity * st.discount / 100)/ sum(st.unit_price * st.quantity) * 100, 2) as discount_pct,
case when d.is_weekend = TRUE then 'Weekend Sale' else 'Not Weekend Sale' End as weekend_sale,
case 
	when ov.order_value <= pct.P25 then 'Low Value'
    when ov.order_value <= pct.P50 then 'Medium Value'
	when ov.order_value <= pct.P75 then 'High Value'
	else 'Very High Value'
end as order_bucket,
ds.Season,
case
	when ov.order_value <= pct.P75 then 'Not High Value Order'
	else 'High Value Order'
end as High_Value_Order,
round(sum(st.final_price - (p.cost_price*st.quantity))/nullif(sum(st.final_price),0)*100,2) as profit_margin,
fs.festival
from sales_transaction st

left join products p
on p.product_id = st.product_id

left join dates d
on d.date_id = st.date_id

left join order_values ov
on ov.order_id = st.order_id

cross join percentiles pct

left join dates_summary ds
on ds.date_id = st.date_id

left join festive_summary fs
on fs.date_id = st.date_id

group by st.order_id, d.is_weekend, ov.order_value, pct.P25, pct.P50, pct.P75, ds.Season, fs.festival;

select st.product_id, d.month, d.year,
sum(st.final_price) as monthly_revenue
from sales_transaction st
left join dates d
on d.date_id = st.date_id
group by st.product_id, d.month, d.year, d.month_number
order by st.product_id, d.year, d.month_number;

