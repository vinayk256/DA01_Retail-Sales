/*--1. Database Setup
--Create Table
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,	
    sale_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
);

--ERROR: invalid input syntax for type integer: "﻿transactions_id" --becasue while importing HEADER option was disabled
copy public.retail_sales (transactions_id, sale_date, sale_time, customer_id, gender, age, category, quantity, price_per_unit, cogs, total_sale)
FROM 'F:/Vinaykc/SQL/Retail Sales/Retail-Sales-Analysis-SQL-Project--P1-main/SQL - Retail Sales Analysis_utf .csv'
WITH (FORMAT csv, DELIMITER ',', QUOTE '"', HEADER true);
*/

/*--2. Data Exploration & Cleaning
SELECT COUNT(*)
FROM retail_sales

SELECT *
FROM retail_sales
WHERE transactions_id IS NULL
	OR sale_date IS NULL
	OR sale_time IS NULL
	OR customer_id IS NULL
	OR gender IS NULL
	OR age IS NULL
	OR category IS NULL
	OR quantity IS NULL
	OR price_per_unit IS NULL
	OR cogs IS NULL
	OR total_sale IS NULL

DELETE
FROM retail_sales
WHERE transactions_id IS NULL
	OR sale_date IS NULL
	OR sale_time IS NULL
	OR customer_id IS NULL
	OR gender IS NULL
	OR age IS NULL
	OR category IS NULL
	OR quantity IS NULL
	OR price_per_unit IS NULL
	OR cogs IS NULL
	OR total_sale IS NULL
*/

--1. retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022:
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
	AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
	AND quantity >= 4

--2. calculate the total sales (total_sale) for each category
SELECT category, SUM(total_sale) AS total_sale
FROM retail_sales
GROUP BY category

--3. find the average age of customers who purchased items from the 'Beauty' category
SELECT ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty'

--4. all transactions where the total_sale is greater than 1000
SELECT *
FROM retail_sales
WHERE total_sale > 1000

--5. find the total number of transactions (transaction_id) made by each gender in each category
SELECT gender, category, COUNT(transactions_id)
FROM retail_sales
GROUP BY gender, category

--6. calculate the average sale for each month. Find out best selling month in each year
WITH best_selling_month AS (
	SELECT EXTRACT (MONTH FROM sale_date) AS month, EXTRACT (YEAR FROM sale_date) AS year, AVG(total_sale) AS avg_sale,
	ROW_NUMBER() OVER(PARTITION BY EXTRACT (YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS row_num
	FROM retail_sales
	GROUP BY month, year
)
SELECT *
FROM best_selling_month
WHERE row_num = 1

--7. find the top 5 customers based on the highest total sales
SELECT customer_id, SUM(total_sale) AS total_sale
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sale DESC
LIMIT 5

--8. find the number of unique customers who purchased items from each category
SELECT COUNT(DISTINCT(customer_id)) AS cnt_unique_cs
FROM retail_sales
GROUP BY category

--9. create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)
WITH shifts AS (
	SELECT *,
		CASE
			WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
			WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
			ELSE 'Evening'
		END AS shift_time
	FROM retail_sales
)
SELECT shift_time, COUNT(transactions_id) AS count_tr
FROM shifts
GROUP BY shift_time