create database if not exists Walmart;
select Time,(case 
				when Time between "00:00:00" and "11:59:00" then "Morning"
				when Time between "12:00:00" and "16:00:00" then "Afternoon"
				else "Evening"
			end ) as time_of_day from walmartsalesdata;
-- -------------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------
-- ----------------------------time_of_day------------------------------------

alter table walmartsalesdata add column time_of_day varchar(10);
select * from walmartsalesdata;

update walmartsalesdata 
set time_of_day = (case 
				when Time between "00:00:00" and "11:59:00" then "Morning"
				when Time between "12:00:00" and "16:00:00" then "Afternoon"
				else "Evening"
			end
);

-- -------------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------
-- ----------------------------day_name------------------------------------

alter table walmartsalesdata add column day_name varchar(10);
select Date,dayname(Date) from walmartsalesdata;

update walmartsalesdata 
set day_name = dayname(Date);

-- -------------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------
-- ----------------------------month_name------------------------------------

alter table walmartsalesdata add column month_name varchar(10);
select Date,monthname(Date) from walmartsalesdata;
update walmartsalesdata
set month_name = monthname(Date);

-- -------------------------------------------------------------------------------------------
-- -------------------------Product-----------------------------------------------------------


-- How many unique cities does the data have? -----------------------------------------------------
select distinct(City) from walmartsalesdata;

-- In which city is each branch? -----------------------------------------------------
select City,Branch from walmartsalesdata
group by City,Branch;

-- How many unique product lines does the data have? -----------------------------------
SELECT COUNT(DISTINCT `Product line`) FROM walmartsalesdata;

-- What is the most common payment method? ---------------------------------------------
select Payment,count(Payment) from walmartsalesdata
group by Payment
limit 1;

-- What is the most selling product line? ----------------------------------------------
select `Product line`,count(`Product line`) from walmartsalesdata
group by `Product line`
limit 1;

-- What is the total revenue by month?--------------------------------------------------
select month_name,round(sum(Total)) from walmartsalesdata
group by month_name;

-- What month had the largest COGS? ----------------------------------------------------
SELECT month_name as Month,sum(cogs) as total_cogs
FROM walmartsalesdata
group by month_name
order by sum(cogs) desc
limit 1;

-- What product line had the largest revenue?-------------------------------------------
SELECT `Product line`
FROM walmartsalesdata
GROUP BY `Product line`
ORDER BY SUM(`Unit price` * Quantity) DESC
LIMIT 1;

-- What product line had the largest VAT? -------------------------------------------
select  `Product line` from walmartsalesdata
group by `Product line` 
order by  sum(`Tax 5%`) desc
limit 1;

-- Which branch sold more products than average product sold? -------------------------------------------
select Branch,sum(Quantity) as Qty from walmartsalesdata
group by Branch
Having sum(Quantity) > (select avg(Quantity) from walmartsalesdata)
limit 1;

select * from walmartsalesdata;

-- What is the most common product line by gender? -------------------------------------------
select `Product line`,count(`Product line`) as Users,Gender from walmartsalesdata
group by `Product line`,Gender 
order by count(`Product line`) desc
limit 1;

-- What is the average rating of each product line? ------------------------------------------
select `Product line`,round(avg(Rating),2) as Average_rating from walmartsalesdata
group by `Product line`
order by Average_rating desc;


-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
WITH avg_sales AS (
    SELECT AVG(Total) AS avg_total_sales
    FROM walmartsalesdata
)
SELECT `Product line`,
    (CASE 
        WHEN Total > (SELECT avg_total_sales FROM avg_sales) THEN 'Good' 
        ELSE 'Bad' 
    END) AS line_quality
FROM walmartsalesdata;

-- -------------------------------------------------------------------------------------------
-- -------------------------Sales-----------------------------------------------------------


-- Number of sales made in each time of the day per weekday. ---------------------------------

select time_of_day,count(*) as Total_sales from walmartsalesdata
where day_name not in ("Saturday", "Sunday")
group by time_of_day
order by Total_sales
;

--  Which of the customer types brings the most revenue? ----------------------------
select `Customer type`,sum(Total) as Total_revenue from walmartsalesdata
group by `Customer type`
order by Total_revenue desc
limit 1;

-- Which city has the largest tax percent/ VAT (Value Added Tax)? ----------------------------
select City,round(sum(`tax 5%`),2) as VAT from walmartsalesdata
group by City
order by VAT desc
limit 1;

-- Which customer type pays the most in VAT? --------------------------------------------------------
select `Customer type`,round(sum(`tax 5%`),2) as VAT from walmartsalesdata
group by `Customer type`
order by VAT desc
limit 1;

-- -------------------------------------------------------------------------------------------
-- -------------------------Customer-----------------------------------------------------------

-- How many unique customer types does the data have? -----------------------------------------
select count(distinct(`Customer type`)) from walmartsalesdata ;

-- How many unique payment methods does the data have? -----------------------------------------
select count(distinct(Payment)) as "Payment method" from walmartsalesdata;

-- What is the most common customer type?-------------------------------
select `Customer type`,count(`Customer type`) as Total_members from walmartsalesdata
group by `Customer type`
limit 1;

-- Which customer type buys the most? -------------------------------
select `Customer type`,count(*) as "total buys" from walmartsalesdata
group by `Customer type`
order by "total buys";

-- What is the gender of most of the customers? --------------------------------
select Gender,count(Gender) from walmartsalesdata
group by Gender
limit 1;

-- What is the gender distribution per branch? --------------------------------
SELECT Branch,
       Gender,
       COUNT(*) AS count
FROM walmartsalesdata
GROUP BY Branch, Gender
ORDER BY Branch, Gender;

-- Which time of the day do customers give most ratings?------------------------
select time_of_day, count(Rating) as R from walmartsalesdata 
group by time_of_day
order by R desc
limit 1;

--  Which time of the day do customers give most ratings per branch?---------------------------
select Branch,time_of_day,Total_rating from(
select Branch,time_of_day, avg(Rating) as Total_rating, 
row_number() over(partition by Branch order by  avg(Rating) DESC) AS rn
FROM walmartsalesdata
    GROUP BY Branch, time_of_day
) AS ranked
WHERE rn = 1
ORDER BY Branch;

-- Which day of the week has the best avg ratings?-------------------------------
select day_name,avg(Rating) as avg_rating from walmartsalesdata
group by day_name
order by avg_rating desc
limit 1;

-- Which day of the week has the best average ratings per branch? -----------------
SELECT Branch, day_name, round(avg_rating,2)
FROM (
    SELECT Branch, day_name, AVG(Rating) AS avg_rating,
           ROW_NUMBER() OVER (PARTITION BY Branch ORDER BY AVG(Rating) DESC) AS rn
    FROM walmartsalesdata
    GROUP BY Branch, day_name
) AS ranked
WHERE rn = 1
ORDER BY Branch;





