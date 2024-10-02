-- Create database
CREATE DATABASE IF NOT EXISTS walmartSales;

-- use the database
USE walmartSales;


-- Create table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------FEATURE ENGINEERING-------------------------------------------------------------------------------

-- Adding time_of_day to show in which part of the day the sale took place
ALTER TABLE sales 
ADD COLUMN time_of_day VARCHAR(100) NOT NULL;

UPDATE sales 
SET time_of_day = (
			CASE 
				WHEN 'time' BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
				WHEN 'time' BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
				ELSE 'Evening'
			END		
);


-- ---------------------
-- day column
ALTER TABLE sales ADD COLUMN day VARCHAR(10) NOT NULL;

UPDATE sales 
SET day = (DAYNAME(date));

-- ---------------------
-- Month column
ALTER TABLE sales ADD COLUMN month VARCHAR(10) NOT NULL;

UPDATE sales 
SET month = (MONTHNAME(date));


-- ---------------------------------------- Explory Data Analysis ----------------------------------------------------------------


-- How many unique cities does the data have?
SELECT count(DISTINCT city) as unique_cities_number
FROM sales;

-- In which city is each branch?
SELECT DISTINCT branch,city
FROM sales;

-- unique product lines does the data have?
SELECT DISTINCT product_line 
FROM sales;



-- What is the most common payment method?
SELECT payment,COUNT(payment) as operation_done
FROM sales 
GROUP BY payment
ORDER BY operation_done DESC;



-- What is the most selling product line?
SELECT product_line, SUM(quantity) AS quantity_sold
FROM sales 
GROUP BY product_line
ORDER BY quantity_sold DESC;  



-- What is the total revenue by month?
SELECT month,SUM(quantity * unit_price) total_revenue_bymonth 
FROM sales 
GROUP BY month
ORDER BY total_revenue_bymonth DESC;


-- What month had the largest COGS?
SELECT month, SUM(COGS) AS COGS_permonth
FROM sales 
GROUP BY month
ORDER BY COGS_permonth DESC
LIMIT 1;


-- What product line had the largest revenue?
SELECT product_line, SUM(COGS) as total_COGS
FROM sales
GROUP BY product_line
ORDER BY total_COGS DESC
LIMIT 1;


-- What is the city with the largest revenue?
SELECT city, SUM(COGS) as total_COGS
FROM sales
GROUP BY city
ORDER BY total_COGS DESC
LIMIT 1;


-- What product line had the largest VAT?
SELECT product_line
FROM sales
GROUP BY product_line
ORDER BY SUM(COGS * 0.05) DESC
LIMIT 1;


-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

-- Which branch sold more products in average than average product sold?
SELECT  branch, AVG(quantity) as total_quantity
FROM sales 
GROUP BY branch
HAVING total_quantity > (SELECT AVG(quantity) FROM sales);



-- What is the most common product line by gender?
SELECT gender , product_line , COUNT(product_line) AS count
FROM sales
GROUP BY gender, product_line
HAVING gender = 'male'  -- 'female' for other gender
ORDER BY count DESC
LIMIT 1;

-- What is the average rating of each product line? 
SELECT  product_line , AVG(rating) AS avg_rating
FROM sales
GROUP BY product_line;

-- ----------------------- SALES-------------
-- Number of sales made in each time of the day per weekday
SELECT time_of_day, COUNT(time_of_day)  AS sales_nbr
FROM sales 
GROUP BY time_of_day;


-- Which of the customer types brings the most revenue?
SELECT customer_type, SUM(COGS) as revenue
FROM sales 
GROUP BY customer_type
ORDER BY revenue DESC
LIMIT 1;
-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT city, (0.05 * COGS) as VAT 
FROM sales
WHERE (0.05 * COGS)  = (
						SELECT max(0.05 * COGS) 
						FROM sales
                        );


-- ------------------ CUSTOMER -----------------------------
-- How many unique customer types does the data have?
SELECT DISTINCT customer_type     -- or SELECT COUNT(DISTINCT customer_type) to get the nbr of unique types
FROM sales;  


-- How many unique payment methods does the data have?
SELECT COUNT(DISTINCT payment)
FROM sales;


-- What is the most common customer type?
SELECT customer_type, COUNT(customer_type) AS appearance
FROM sales 
GROUP BY customer_type
HAVING COUNT(customer_type) = (
								SELECT COUNT(customer_type) AS appearance
								FROM sales 
								GROUP BY customer_type
                                ORDER BY appearance
                                LIMIT 1);
                                

-- Which customer type buys the most?
SELECT customer_type
FROM (
		SELECT customer_type, SUM(quantity) AS quantity_per_type
        FROM sales 
        GROUP BY customer_type
        ORDER BY quantity_per_type
        LIMIT 1
) AS subquery;


-- What is the gender of most of the customers?
SELECT gender 
FROM (
		SELECT gender, COUNT(gender) AS individuals
        FROM sales 
        GROUP BY gender
        ORDER BY individuals
        LIMIT 1
) AS subquery;


-- What is the gender distribution per branch?
SELECT branch , gender, COUNT(gender) AS individuals
FROM sales
GROUP BY branch, gender
ORDER BY branch, individuals;


-- Which day fo the week has the best avg ratings?
SELECT day 
FROM (
		SELECT day, AVG(rating) AS avg_rating
		FROM sales 
		GROUP BY day 
		ORDER BY avg_rating
		LIMIT 1
) AS subquery; 


-- Which day of the week has the best average ratings per branch?
SELECT branch, day 
FROM (
		SELECT day, branch, AVG(rating) AS avg_rating
		FROM sales 
		GROUP BY day, branch
        HAVING branch= 'A'
        ORDER BY avg_rating DESC
		LIMIT 1
) AS subquery1

UNION 

SELECT branch, day 
FROM (
		SELECT day, branch, AVG(rating) AS avg_rating
		FROM sales 
		GROUP BY day, branch
        HAVING branch= 'B'
        ORDER BY avg_rating DESC
		LIMIT 1
) AS subquery2

UNION 

SELECT branch,day 
FROM (
		SELECT day, branch, AVG(rating) AS avg_rating
		FROM sales 
		GROUP BY day, branch
        HAVING branch= 'C'
        ORDER BY avg_rating DESC
		LIMIT 1
) AS subquery3;
 


