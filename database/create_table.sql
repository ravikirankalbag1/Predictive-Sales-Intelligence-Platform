drop table if exists sales_transaction;
drop table if exists products;
drop table if exists customers;
drop table if exists stores;
drop table if exists dates;

-- Customers
create table customers(
customer_id VARCHAR(6) PRIMARY KEY,
customer_name VARCHAR(255),
age INT,
gender VARCHAR(20),
city VARCHAR(100),
phone VARCHAR(20),
membership VARCHAR(255) not null,
join_date DATE
);

-- Products
create table products(
product_id VARCHAR(5) PRIMARY KEY,
product_name VARCHAR(255),
category VARCHAR(20) NOT NULL,
unit_price DECIMAL(10,2) NOT NULL,
cost_price DECIMAL(10,2) NOT NULL
);


-- Stores
create table stores(
store_id VARCHAR(3) PRIMARY KEY,
store_name varchar(255),
city varchar(100),
state varchar(100),
country varchar(100),
store_type varchar(100)
);


-- Sales Transaction
create table sales_transaction(
transaction_id VARCHAR(11) PRIMARY KEY,
order_id VARCHAR(11),
date_id VARCHAR(9),
quantity INT CHECK(quantity > 0),
unit_price DECIMAL(10,2) NOT NULL,
discount DECIMAL(5,2),
payment_mode varchar(255) CHECK(payment_mode IN ('UPI','Cash','Credit Card','Debit Card')),
final_price DECIMAL(12,2),
customer_id VARCHAR(6),
store_id VARCHAR(3),
product_id VARCHAR(5),
FOREIGN KEY(customer_id) REFERENCES customers(customer_id),
FOREIGN KEY(store_id) REFERENCES stores(store_id),
FOREIGN KEY(product_id) REFERENCES products(product_id)
);


CREATE TABLE dates (
    date_id VARCHAR(9) PRIMARY KEY,
    date DATE NOT NULL,
    year INT NOT NULL,
    month VARCHAR(20) NOT NULL,
    month_number INT NOT NULL,
    quarter VARCHAR(2) NOT NULL,
    week_number INT NOT NULL,
    day VARCHAR(15) NOT NULL,
    day_number INT NOT NULL,
    is_weekend BOOLEAN NOT NULL
);