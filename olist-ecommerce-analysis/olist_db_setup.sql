create database olist;
use olist;

show variables like 'secure_file_priv';
Describe orders;

-- 1. CUSTOMERS
create table customers (
    customer_id varchar(50),
    customer_unique_id varchar(50),
    customer_zip_code_prefix int,
    customer_city varchar(100),
    customer_state varchar(10)
);

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_customers_dataset.csv'
into table customers
fields terminated by ',' enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

select * from customers;

-- 2. ORDER ITEMS
create table order_items (
    order_id varchar(50),
    order_item_id int,
    product_id varchar(50),
    seller_id varchar(50),
    shipping_limit_date datetime,
    price decimal(10,2),
    freight_value decimal(10,2)
);

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_items_dataset.csv'
into table order_items
fields terminated by ',' enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

select * from order_items;

-- 3. PRODUCTS
drop table if exists products;
create table products (
    product_id varchar(50),
    product_category_name varchar(100),
    product_name_length int,
    product_description_length int,
    product_photos_qty int,
    product_weight_g int,
    product_length_cm int,
    product_height_cm int,
    product_width_cm int
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_products_clean.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@product_id, @product_category_name, @product_name_length, @product_description_length, @product_photos_qty, @product_weight_g, @product_length_cm, @product_height_cm, @product_width_cm)
SET
    product_id = NULLIF(@product_id, ''),
    product_category_name = NULLIF(@product_category_name, ''),
    product_name_length = NULLIF(@product_name_length, ''),
    product_description_length = NULLIF(@product_description_length, ''),
    product_photos_qty = NULLIF(@product_photos_qty, ''),
    product_weight_g = NULLIF(@product_weight_g, ''),
    product_length_cm = NULLIF(@product_length_cm, ''),
    product_height_cm = NULLIF(@product_height_cm, ''),
    product_width_cm = NULLIF(@product_width_cm, '');

select * from products;

-- 4. CATEGORIES
create table categories (
    product_category_name varchar(100),
    product_category_name_english varchar(100)
);
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/product_category_name_translation.csv'
into table categories
fields terminated by ',' enclosed by ""
lines terminated by '\n'
ignore 1 rows;

select * from categories;

-- 5. ORDER PAYMENTS
create table order_payments (
    order_id varchar(50),
    payment_sequential int,
    payment_type varchar(50),
    payment_installments int,
    payment_value decimal(10,2)
);

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_payments_dataset.csv'
into table order_payments
fields terminated by',' enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

select * from order_payments;

-- 6. ORDER REVIEWS
drop table if exists order_reviews;
create table order_reviews (
    review_id varchar(50),
    order_id varchar(50),
    review_score int,
    review_comment_title varchar(100),
    review_comment_message text,
    review_creation_date text,
    review_answer_timestamp text
);

-- 7. ORDER_REVIEWS TABLE
drop table if exists order_reviews;

create table order_reviews (
    review_id varchar(50),
    order_id varchar(50),
    review_score int,
    review_comment_title varchar(100),
    review_comment_message text,
    review_creation_date text,
    review_answer_timestamp text
);

ALTER TABLE order_reviews
    MODIFY review_score INT NULL,
    MODIFY review_comment_title VARCHAR(100) NULL,
    MODIFY review_comment_message TEXT NULL;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_reviews_clean.csv'
INTO TABLE order_reviews
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@review_id, @order_id, @review_score, @review_comment_title, @review_comment_message, @review_creation_date, @review_answer_timestamp)
SET
    review_id = NULLIF(@review_id, ''),
    order_id = NULLIF(@order_id, ''),
    review_score = NULLIF(@review_score, ''),
    review_comment_title = NULLIF(@review_comment_title, ''),
    review_comment_message = NULLIF(@review_comment_message, ''),
    review_creation_date = NULLIF(@review_creation_date, ''),
    review_answer_timestamp = NULLIF(@review_answer_timestamp, '');
    
select * from order_reviews;

-- 8. SELLERS
create table sellers (
    seller_id varchar(50),
    seller_zip_code_prefix int,
    seller_city varchar(100),
    seller_state varchar(10)
);

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_sellers_dataset.csv'
into table sellers
fields terminated by ',' enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

select * from sellers;

-- 9. ORDERS TABLE
drop table if exists orders;

create table orders (
    order_id varchar(50),
    customer_id varchar(50),
    order_status varchar(50),
    order_purchase_timestamp datetime,
    order_approved_at datetime,
    order_delivered_carrier_date datetime,
    order_delivered_customer_date datetime,
    order_estimated_delivery_date datetime
);

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_orders_dataset.csv'
into table orders
fields terminated by ',' enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(@order_id, @customer_id, @order_status, @order_purchase_timestamp, @order_approved_at, @order_delivered_carrier_date, @order_delivered_customer_date, @order_estimated_delivery_date)
SET
    order_id = NULLIF(@order_id, ''),
    customer_id = NULLIF(@customer_id, ''),
    order_status = NULLIF(@order_status, ''),
    order_purchase_timestamp = NULLIF(@order_purchase_timestamp, ''),
    order_approved_at = NULLIF(@order_approved_at, ''),
    order_delivered_carrier_date = NULLIF(@order_delivered_carrier_date, ''),
    order_delivered_customer_date = NULLIF(@order_delivered_customer_date, ''),
    order_estimated_delivery_date = NULLIF(@order_estimated_delivery_date, '');


select 'orders' as table_name, count(*) as `rows` from orders union all
select 'customers', count(*) from customers union all
select 'order_items', count(*) from order_items union all
select 'products', count(*) from products union all
select 'categories', count(*) from categories union all
select 'order_payments', count(*) from order_payments union all
select 'order_reviews', count(*) from order_reviews union all
select 'sellers', count(*) from sellers;