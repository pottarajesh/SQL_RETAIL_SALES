# SQL Retail sales Project
create database sql_project_p1 ;
use sql_project_p1 ;

# create Table
Create Table Retail_sales (
transactions_id	int primary key,
sale_date	date,
sale_time	time,
customer_id	int,
gender	varchar(10),
age	int,
category	varchar(15),
quantiy	int,
price_per_unit float,	
cogs	float,
total_sale float
);

select *
 from Retail_sales;

#Null values finding - Data Cleaning

select * from retail_sales
where 
transactions_id IS NULL
or sale_date IS NULL
or sale_time IS NULL
or Customer_id IS NULL
or gender IS NULL
or category IS NULL
or quantiy IS NULL
or price_per_unit IS NULL
or cogs IS NULL
or total_sale IS NULL;

# Delete Null values

delete from retail_sales
where 
transactions_id IS NULL
or sale_date IS NULL
or sale_time IS NULL
or Customer_id IS NULL
or gender IS NULL
or category IS NULL
or quantiy IS NULL
or price_per_unit IS NULL
or cogs IS NULL
or total_sale IS NULL;

# Data Exploration 
# How many sales we have
select count(*) as total_sale from retail_sales;

# How many unique customers we have
select count(distinct customer_id) from retail_sales;

# How many unique category we have
select distinct category from retail_sales;

# Data analysis and business key problems & answers
#1. write sql query to retrieve all columns for sales made on '2022-11-05'
select *
from retail_sales
where sale_date = '2022-11-05';

#2. write sql query to retrieve all transactions where the category is ' clothing' and the quantity --
#	sold is more than 4 in the month of Nov-2022
select * from retail_sales
where
	category = 'Clothing'
    and
	quantiy > '2'
    and
    sale_date like '2022-11%' ;# we also use TO_CHAR function to convert the date, but MYSQL not supporting
    
-- 3. write sql query to calculate the total sales for each category
select Category,sum(total_sale) as total_sales,
count(*) as total_orders
from retail_sales
group by category
order by category desc;

-- 4. write a sql query to find the average age of customers who purchased items from the 'beauty' category
select round(avg(age),2) from retail_sales
where
 category = 'Beauty';
 
 -- 5. write a sql query to find all transactions where the total_sale is > 1000
 select total_sale,category from retail_sales
 where total_sale > '1000';
 
 -- 6. write a sql query to find the total no of transactions made by each gender in each category
 select count(transactions_id),gender,category
 from retail_sales
 group by gender,category
 order by 1;
 
 -- 7. write a sql query to calculate the average sale for each month. find out best selling month in each year
 -- Best selling month in each year
 WITH monthly_sales AS (
    SELECT
        YEAR(sale_date) AS year,
        MONTH(sale_date) AS month,
        MONTHNAME(sale_date) AS month_name,
        SUM(total_sale) AS total_sales
    FROM retail_sales
    GROUP BY YEAR(sale_date), MONTH(sale_date), MONTHNAME(sale_date)
),
ranked_sales AS (
    SELECT *,
           RANK() OVER (
               PARTITION BY year
               ORDER BY total_sales DESC
           ) AS sales_rank
    FROM monthly_sales
)
SELECT
    year,
    month,
    month_name,
    total_sales
FROM ranked_sales
WHERE sales_rank = 1;

-- 8. Average sale for each month

SELECT
    YEAR(sale_date) AS year,
    MONTH(sale_date) AS month,
    MONTHNAME(sale_date) AS month_name,
    ROUND(AVG(total_sale), 2) AS avg_sale,
    ROUND(SUM(total_sale), 2) AS total_sales,
    COUNT(transactions_id) AS total_orders
FROM retail_sales
GROUP BY YEAR(sale_date), MONTH(sale_date), MONTHNAME(sale_date)
ORDER BY year, month;

-- 9 Find the top-selling category in each year based on total revenue.
with category_sales as (
SELECT
    YEAR(sale_date) as year,
    category,
    SUM(total_sale) as total_sales
from retail_sales
group by category, year
),
	ranked_sales as (
		select *, RANK() OVER(partition by year 
						order by total_sales desc
				) as rank_no
		from category_sales
	)
    select year,category,total_sales
    from ranked_sales
    where rank_no = 1;
    
-- Find the top 2 customers in each year based on total purchases.
 with customer_sales as (
	select
		year(sale_date) as year,
        customer_id,
        sum(total_sale) as total_purchase
	from retail_sales
    group by year(sale_date),customer_id
),
	ranked_sales as (
    select *, rank() over(partition by year order by total_purchase desc
    ) as rank_no
    from customer_sales
)
select year,customer_id,total_purchase
 from ranked_sales
 where rank_no <= 5;
 
 -- write sql query to find the top 5  customers based on the highest total sale
 select 
	customer_id,
    sum(total_sale) as total_sales
    from retail_sales
    group by 1
    order by 2 desc
    limit 5 ;
    
-- write sql query to find the no of unique customer who purchased items from each category
select 
		category,
		count(distinct customer_id) as count_cust
from retail_sales
group by category;

-- write sql query to create each shift and number orders (example:morning <=12, afternoon  between 12 & 17, evening > 17)

with hourly_sale 
as (
select * ,
	case
		when hour(sale_time) < 12 then 'morning'
        when hour(sale_time) between 12 and 17 then 'afternoon'
        else 'evening'
        end as shift
from retail_sales
)
select 
shift,
count(*) as total_orders
from hourly_sale
group by shift 