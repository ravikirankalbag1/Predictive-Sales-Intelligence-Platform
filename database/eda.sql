-- Finding records of each table
SELECT 'customers' AS table_name, COUNT(*) AS total_records
FROM customers

UNION ALL

SELECT 'products', COUNT(*)
FROM products

UNION ALL

SELECT 'stores', COUNT(*)
FROM stores

UNION ALL

SELECT 'sales_transaction', COUNT(*)
FROM sales_transaction;

-- Total Revenue generated over 5 year
select sum(final_price) as total_revenue from sales_transaction;

-- Unique Customers atleast one purchase
select count(distinct customer_id) from sales_transaction;

-- Final products never been sold
select p.product_name from products p left join sales_transaction s
on p.product_id = s.product_id
where s.transaction_id is null;

-- Stores never made a sale
select s.store_name from stores s left join sales_transaction st
on s.store_id = st.store_id
where st.transaction_id is null;

-- Earliest & Latest Transaction
select min(d.date) as earlier_transaction, max(d.date) as late_transaction 
from sales_transaction st
join dates d
on st.date_id = d.date_id;


-- Average Order across all transactions
select avg(final_price) as Average_Order from sales_transaction;

-- Transaction with Zero Revenue
select * from sales_transaction
where final_price = 0;


-- Find Duplicate Transaction ID
select transaction_id, count(*) 
from sales_transaction
group by transaction_id
having count(*) > 1;

-- Total Quantity sold
select sum(quantity) as total_quantity_sold from sales_transaction;


-- Top 10 customers who generated highest revenue
select c.customer_id, c.customer_name,sum(final_price) as revenue 
from sales_transaction st
join customers c
on c.customer_id = st.customer_id
group by c.customer_id, c.customer_name
order by revenue desc
limit 10;

-- Follow Up 
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(st.transaction_id) AS total_orders
FROM sales_transaction st
JOIN customers c
    ON st.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_orders DESC
LIMIT 1;

-- Average Spend per Customer
select avg(total_spend) as average_customer_spend 
from (select customer_id, sum(final_price) as total_spend from sales_transaction
group by customer_id) t;


-- Customers who placed more than 100 orders
select customer_id, count(customer_id) as total_orders 
from sales_transaction
group by customer_id 
having count(customer_id) > 100;

-- Customers who purchased products from 3 categories
select st.customer_id, count(distinct(p.category)) as category_count
from sales_transaction st
join products p
on p.product_id = st.product_id
group by st.customer_id
having count(distinct(p.category)) > 3;


-- Top 5 products generated highest revenue
select p.product_id, p.product_name, sum(st.final_price) as revenue
from sales_transaction st
join products p
on p.product_id = st.product_id
group by p.product_id, p.product_name
order by revenue desc
limit 5;


-- Product Category that generated highest revenue
select p.category, sum(st.final_price) as revenue
from sales_transaction st
join products p
on st.product_id = p.product_id
group by p.category
order by revenue desc
limit 1;


-- Average revenue generated per store
-- Average Transaction Order Value per store
select s.store_name, avg(st.final_price) as revenue 
from sales_transaction st
join stores s
on s.store_id = st.store_id
group by s.store_name;

-- Average Revenue 
select avg(store_revenue) as average_store_revenue
from (select store_id, sum(final_price) as store_revenue from sales_transaction
group by store_id) t;

-- Maximum products sold at a store
select s.store_name, sum(st.quantity) as store_quantity 
from sales_transaction st
join stores s
on s.store_id = st.store_id
group by s.store_id, s.store_name
order by store_quantity desc
limit 1;


-- Customer who purchased highest total quantity of products
select c.customer_id, c.customer_name, sum(st.quantity) as total_quantity
from sales_transaction st
join customers c
on c.customer_id = st.customer_id
group by c.customer_id, c.customer_name
order by total_quantity desc
limit 1;


-- Customers who never purchased a product
select c.customer_id, c.customer_name
from customers c
left join sales_transaction st
on c.customer_id = st.customer_id
where st.transaction_id is null;




































































































































