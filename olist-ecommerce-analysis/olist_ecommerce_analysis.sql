-- =============================================================
-- PROJECT  : Olist E-Commerce Sales Analysis
-- DATABASE : MySQL 8.0
-- DATASET  : Brazilian E-Commerce (Olist) — Kaggle
-- AUTHOR   : Tharun sajeev
-- =============================================================
-- SKILLS DEMONSTRATED:
--   Joins, Aggregation, Subqueries, CTEs,
--   Window Functions (RANK, DENSE_RANK, ROW_NUMBER, LAG, LEAD),
--   Indexing, Stored Procedures
-- =============================================================

use olist;

-- ------------   SECTION 1: REVENUE ANALYSIS -------------------

-- Q1. Total revenue generated per product category

select
	c.product_category_name,
    sum(o.price) as total_revenue
from order_items o
join products p on o.product_id = p.product_id
join categories c on p.product_category_name = c.product_category_name
group by c.product_category_name
order by total_revenue desc;

-- Q2. Total orders placed per month (grouped by year and month)
select
	extract(month from order_purchase_timestamp) as sales_month,
	extract(year from order_purchase_timestamp) as sales_year,
	count(order_id) as total_items_sold
from Orders
where order_status = 'delivered'
group by sales_month, sales_year
order by sales_year, sales_month asc;
    
-- Q3. Top 10 sellers by total revenue
select 
	seller_id,
    sum(price) as total_revenue
from order_items
group by seller_id
order by total_revenue desc
limit 10;
    
-- Q4. Average order value overall, and broken down by payment type (credit card, boleto, etc.)  
select 
	payment_type,
    avg(payment_value) as avg_order_value,
    count(order_id) as total_transactions
from order_payments
group by payment_type
order by avg_order_value desc;


-- -------- SECTION 2: CUSTOMER & REVIEW ANALYSIS -------------

--  Q5. Average review score per product category (lowest rated at top)
select 
	p.product_category_name,
	round(avg(r.review_score),2) as average_review_score,
	count(r.review_id) as total_reviews
from products p
join order_items o on p.product_id = o.product_id
join order_reviews r on o.order_id = r.order_id
group by p.product_category_name
order by average_review_score asc;

-- Q6. Number of unique customers who placed more than one order (repeat customers) 
select count(*) as total_repeat_customers
from (
		select 
			c.customer_unique_id,
			count(o.order_id) as order_count
		from orders o
		join customers c on o.customer_id = c.customer_id
		group by c.customer_unique_id
		having order_count > 1
) as repeat_customers;

-- ------------ SECTION 3: DELIVERY ANALYSIS ----------------

-- Q7. Orders where actual delivery was later than estimated with late % of total
select 
	order_id, date(order_estimated_delivery_date) as estimated_date,
	date(order_delivered_customer_date) as delivered_date,
	datediff(order_delivered_customer_date,order_estimated_delivery_date) as days_late
from orders
where order_estimated_delivery_date < order_delivered_customer_date
and order_status = 'delivered'
order by days_late desc;

-- Q8. Top 10 most frequently ordered products with category names
select 
	p.product_id,
	p.product_category_name,
	count(o.order_item_id) as products_sold
from products p
join order_items o on p.product_id = o.product_id
group by p.product_category_name,product_id
order by products_sold desc
limit 10; 

show tables;
-- Q9. Customers who spent above the average customer lifetime value
select 
	count(*) as above_avg_spend_customers
	from (
			select 
				c.customer_unique_id,
				sum(op.payment_value) as total_spend
			from customers c 
			join orders o on c.customer_id = o.customer_id
			join order_payments op on o.order_id = op.order_id
            group by c.customer_unique_id
            having total_spend >( 
					select 
						avg(total_spend)
                    from (
					select 
						c1.customer_unique_id,
						sum(op1.payment_value) as total_spend
					from customers c1
					join orders o1 on c1.customer_id = o1.customer_id
					join order_payments op1 on o1.order_id = op1.order_id
					group by c1.customer_unique_id
                    ) as avg_table
				)
			) as above_avg_customers;
       
-- Q10. Top 5 Brazilian states by total revenue

select 
	s.seller_state,
	sum(o.price) as total_revenue
from sellers s
join order_items o on s.seller_id = o.seller_id
group by s.seller_state order by total_revenue desc
limit 5;
    
-- Q11. Order cancellation rate per month
select 
	canceled.month_,
	total.total_orders,
	canceled.total_orders_canceled,
	round((canceled.total_orders_canceled/total.total_orders)*100,2) as cancellation_rate_percentage
		from (
				select 
					extract(month from order_purchase_timestamp) as month_,
					count(order_id) as total_orders_canceled
				from orders where order_status = 'canceled'
				group by month_ order by month_ asc
			) as canceled
				join
					(
                    select 
						extract(month from order_purchase_timestamp) as month_,
						count(order_id) as total_orders
					from orders group by month_
                    ) as total
					on canceled.month_ = total.month_
					order by canceled.month_ asc;

-- Q12. Average delivery days per product category 
select 
	p.product_category_name,
	round(avg(datediff(order_delivered_customer_date,order_purchase_timestamp))) as avg_days_to_deliver
from orders o
join order_items oi on o.order_id = oi.order_id
join products p on oi.product_id = p.product_id
where o.order_status = 'delivered' and order_delivered_customer_date is not null
group by p.product_category_name
order by avg_days_to_deliver desc;

-- ---------------SECTION 4: CTE-BASED ANALYSIS --------------------------------

-- Q13. Using a CTE, calculate the 3-month rolling average of monthly revenue. Does revenue grow over time?
select * from order_payments;
select * from orders;

with monthly_revenue as (
	select 
		extract(month from o.order_purchase_timestamp) as month_,
		sum(op.payment_value) as total_revenue
    from order_payments op
	join orders o on op.order_id = o.order_id
	where o.order_purchase_timestamp is not null
	group by month_
	),
		rolling_avg as (
				select 
					month_,
					total_revenue,
					round(avg(total_revenue) over (order by month_ rows between 2 preceding and current row),2) as rolling_avg_revenue
				from monthly_revenue
				)
	select * from rolling_avg
    order by month_;
				
-- Q14. Top product category per state by number of orders 

with top_product_category as (
		select 
			p.product_category_name,
			sum(oi.price) as total_revenue,
			s.seller_state
        from products p
		join order_items oi on p.product_id = oi.product_id
		join sellers s on oi.seller_id = s.seller_id
		group by product_category_name,seller_state
		),
         ranked_categories as ( select seller_state, product_category_name, total_revenue,
         row_number() over (
				partition by seller_state
                order by total_revenue desc) as ranked_product
		from top_product_category
	)
	
	select 
		seller_state,
        product_category_name,
        total_revenue
	from ranked_categories
	where ranked_product = 1
	order by total_revenue desc;
        
with top_product_category as (
		select 
			p.product_category_name,
            count(oi.order_id) as total_orders,
            s.seller_state
        from products p
			join order_items oi on p.product_id = oi.product_id
            join sellers s on oi.seller_id = s.seller_id
            group by p.product_category_name,s.seller_state
		),
         ranked_categories as ( 
			select 
				seller_state,
				product_category_name,
				total_orders,
				row_number() over (partition by seller_state order by total_orders desc) as ranked_product
			from top_product_category
	)
	
	select 
		seller_state,
		product_category_name,
		total_orders
	from ranked_categories
	where ranked_product = 1
	order by total_orders desc;
        
-- Q15. Month-over-month revenue growth percentage
with monthly_revenue as (
	select 
		extract(month from o.order_purchase_timestamp) as month,
		sum(op.payment_value) as month_revenue
    from orders o
    join order_payments op on o.order_id = op.order_id
    group by month
    order by month asc),
    
    month_over_growth as ( 
		select 
			month,
			month_revenue,
			lag(month_revenue) over (order by month) as _last_month_growth
		from monthly_revenue
		)
	
	select 
		month,
		month_revenue,
		coalesce(round(((month_revenue - _last_month_growth) / _last_month_growth * 100),2),0) as month_growth_percet
    from month_over_growth;
    
-- Q16. Customer segmentation into high, mid, low value tiers
        
with customer_spendings as (
	select 
		o.customer_id, sum(op.payment_value) as total_spend
    from order_payments op
    join orders o on op.order_id = o.order_id
    group by o.customer_id
    ),
    
    customer_rank as (
		select 
			customer_id,
            total_spend,
			case
				when total_spend > 1000 then 'high'
				when total_spend between 200 and 1000 then 'mid'
                else 'low'
			end as customer_tier
		from customer_spendings)
        
	select 
		customer_tier,
        count(customer_id) from customer_rank
    group by customer_tier;
       
 -- -------------- SECTION 5: WINDOW FUNCTION ANALYSIS --------------------      
 -- Q17. Top seller per product category by revenue using RANK()
with revenue_from_sellers as (
	select 
		oi.seller_id,
        p.product_category_name,
        sum(oi.price) as total_revenue
	from order_items oi
    join products p 
    on oi.product_id = p.product_id
    group by oi.seller_id, p.product_category_name),
    
    seller_revenue_category as ( 
		select 
			seller_id,
			product_category_name,
            total_revenue,
			rank () over ( partition by product_category_name order by total_revenue desc ) as seller_rank
		from revenue_from_sellers)
		
	select
		seller_id,
        product_category_name,
        total_revenue
	from seller_revenue_category
	where seller_rank = 1 and product_category_name is not null
	order by total_revenue desc;
        
-- Q18. Month with the biggest revenue drop using LAG()
with month_revenue as ( 
	select 
		extract( month from o.order_purchase_timestamp) as month_,
		sum(op.payment_value) as total_month_revenue
	from orders o
	join order_payments op on o.order_id = op.order_id
	group by month_
	order by month_ asc),
        
        month_over_revenue as (
			select 
				month_,
                total_month_revenue,
				lag(total_month_revenue) over (order by month_) as last_month_revenue
            from month_revenue )
        
select 
	month_,
    total_month_revenue as month_revenue,last_month_revenue,
	round((((total_month_revenue - last_month_revenue) / last_month_revenue) * 100),2) as mom_growth_pct
from month_over_revenue
where last_month_revenue is not null
order by mom_growth_pct asc
limit 1;
        
-- Q19. Months with declining order volume using LEAD()
select 
	month,
    total_orders,
    total_orders - next_month_orders as decline_amount
	from ( 
		select
			month,
            total_orders,
			lead(total_orders) over (order by month) as next_month_orders
		from (
			select 
				extract(month from order_purchase_timestamp) as month,
                count(order_id) as total_orders
			from orders 
            group by month) as order_per_month
        ) as next_monthly_data
	where next_month_orders < total_orders
	order by decline_amount desc;
        
-- Q20. Running total of revenue at what month did cumulative revenue cross 10 million.
select 
	month,
    cumulative_revenue
	from (
		select
			month,
            total_revenue,
			sum(total_revenue) over (order by month asc) as cumulative_revenue
		from (
			select 
				extract(month from o.order_purchase_timestamp) as month,
				sum(op.payment_value) as total_revenue
			from order_payments op 
			join orders o on op.order_id = o.order_id
			group by month
        ) as monthly_revenue
	) as cumu_revn
where cumulative_revenue >= 10000000
order by month asc
limit 1;
        
-- Q21. Top 20 customers by total spend using DENSE_RANK()
with total_spendings as (
	select 
		o.customer_id,
        sum(op.payment_value) as total_spend
	from orders o
	join order_payments op
	on o.order_id = op.order_id
	group by customer_id
	),
     ranking_customer as (   
		select
			customer_id,
            total_spend,
			dense_rank() over (order by total_spend desc ) as customer_rank
		from total_spendings
	)
    
select * from ranking_customer
where customer_rank <= 20
order by customer_rank asc;

-- Q22. Best selling month per seller using ROW_NUMBER()
select 
	seller_id,
    month,
    total_revenue
from (
	select
		seller_id,
		month,
        total_revenue,
		row_number() over (partition by seller_id order by total_revenue desc) as best_selling_month
	from (
	select
		oi.seller_id,
        extract(month from o.order_purchase_timestamp) as month,
		sum(oi.price) as total_revenue
	from order_items oi
	join orders o on oi.order_id = o.order_id
	group by oi.seller_id, month
	order by month asc
	) as revenue_from_seller
) as final_ranking
where best_selling_month = 1;

-- -------------- SECTION 6: PERFORMANCE OPTIMIZATION -------------------

-- Q23. Index creation on foreign key columns for query optimization
	-- Run 'explain' on Q12 before and after to observe performance difference
create index idx_orders_customer on orders(customer_id); 
create index idx_orderitems_order on order_items(order_id);
create index idx_ordersitems_products on order_items(product_id);
create index idx_orderitems_seller on order_items(seller_id);
create index idx_payments_order on order_payments(order_id);
create index idx_review_order on order_reviews(order_id);

-- After: run 'explain' again — type changes to 'ref', key shows index name, rows drop significantly
explain 
	select 
		c.product_category_name,
		round(avg(datediff(o.order_delivered_customer_date,o.order_purchase_timestamp)),1) as avg_days_to_deliver
	from orders o
    join order_items oi on o.order_id = oi.order_id
    join products p on oi.product_id = p.product_id
    join categories c on p.product_category_name = c.product_category_name
    where o.order_status = 'delivered'
    group by c.product_category_name;
    
-- ------------ SECTION 7: CAPSTONE — MONTHLY BUSINESS REPORT ----------------

-- Q24 Complete monthly business report using CTEs and window functions.
with monthly_business_report as ( 
	select 
		extract(month from o.order_purchase_timestamp) as month,
		count(distinct o.order_id) as total_orders, 
		sum(op.payment_value) / count(distinct o.order_id) as avg_order_value,
		sum(op.payment_value) as total_revenue,
		p.product_category_name
		from orders o 
		join order_payments op on o.order_id = op.order_id
		join order_items oi on o.order_id = oi.order_id
		join products p on oi.product_id = p.product_id
		where o.order_purchase_timestamp is not null and o.order_status = 'delivered'
		group by month, product_category_name
		order by month asc),
        
		MoM_growth as (
			select 
				month,
                total_orders,
                avg_order_value,
                total_revenue,
                product_category_name,
				lag(total_revenue) over (order by month ) as last_month
			from monthly_business_report),
            
			final_report as (
				select
					month,
                    total_orders,
                    avg_order_value,
                    total_revenue,
                    last_month,
                    product_category_name,
					rank() over ( partition by month order by total_revenue desc) as category_rank
				from MoM_growth)
        
	select
         month,
         total_orders,
         round(avg_order_value,2) as avg_order_value,
         total_revenue,
         round((((total_revenue - last_month)/last_month)* 100),2) as MoM_rate,
         product_category_name as top_category
    from final_report
    where category_rank = 1
    order by month asc;
    
-- Q25 Stored procedure: monthly_report(input_year, input_month)
	-- Returns full business summary for a given year and month
	-- Usage: CALL monthly_report(2018, 1);

delimiter $$

create procedure monthly_report(in input_year int, in input_month int)
begin
	
    with monthly_business_report as ( 
		select
			extract(month from o.order_purchase_timestamp) as month_,
			extract(year from o.order_purchase_timestamp) as year_,
			count(distinct o.order_id) as total_orders, 
            sum(op.payment_value) / count(distinct o.order_id) as avg_order_value,
            sum(op.payment_value) as total_revenue,
            p.product_category_name
		from orders o 
		join order_payments op on o.order_id = op.order_id
		join order_items oi on o.order_id = oi.order_id
		join products p on oi.product_id = p.product_id
		where o.order_purchase_timestamp is not null and o.order_status = 'delivered'
		group by month_,year_, p.product_category_name
	),
        
	MoM_growth as (
			select 
				month_,
                year_,
                total_orders,
				avg_order_value,
				total_revenue,
                product_category_name,
				lag(total_revenue) over (partition by product_category_name order by year_,month_ ) as last_month
			from monthly_business_report
		),
        
		final_report as (
				select 
					month_,
                    year_,
                    total_orders,
                    avg_order_value,
					total_revenue,
                    last_month,
                    product_category_name,
				rank() over ( partition by year_, month_ order by total_revenue desc) as category_rank
				from MoM_growth)
        
	select
         month_,
         year_,
         total_orders,
         round(avg_order_value,2) as avg_order_value,
         total_revenue,
         round((((total_revenue - last_month)/last_month)* 100),2) as MoM_rate,
         product_category_name as top_category
    from final_report
    where category_rank = 1
		and year_ = input_year
        and month_= input_month
    order by month_ asc;
end$$
delimiter ;

call monthly_report(2018,1);