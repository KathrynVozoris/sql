-- COALESCE
/* 1. Our favourite manager wants a detailed long list of products, but is afraid of tables! 
We tell them, no problem! We can produce a list with all of the appropriate details. 

Using the following syntax you create our super cool and not at all needy manager a list:

SELECT 
product_name || ', ' || product_size|| ' (' || product_qty_type || ')'
FROM product

But wait! The product table has some bad data (a few NULL values). 
Find the NULLs and then using COALESCE, replace the NULL with a 
blank for the first problem, and 'unit' for the second problem. 

HINT: keep the syntax the same, but edited the correct components with the string. 
The `||` values concatenate the columns into strings. 
Edit the appropriate columns -- you're making two edits -- and the NULL rows will be fixed. 
All the other rows will remain the same.) */

SELECT 
product_name || ', ' || coalesce(product_size, '')|| ' (' || coalesce(product_qty_type, 'unit') || ')'

FROM product;


--Windowed Functions
/* 1. Write a query that selects from the customer_purchases table and numbers each customer’s  
visits to the farmer’s market (labeling each market date with a different number). 
Each customer’s first visit is labeled 1, second visit is labeled 2, etc. 

You can either display all rows in the customer_purchases table, with the counter changing on
each new market date for each customer, or select only the unique market dates per customer 
(without purchase details) and number those visits. 
HINT: One of these approaches uses ROW_NUMBER() and one uses DENSE_RANK(). */

SELECT *,
row_number() OVER(PARTITION BY customer_id ORDER BY market_date) as [purchase_num_by_customer]
FROM customer_purchases;



/* 2. Reverse the numbering of the query from a part so each customer’s most recent visit is labeled 1, 
then write another query that uses this one as a subquery (or temp table) and filters the results to 
only the customer’s most recent visit. */

SELECT *
FROM
(
SELECT *,
row_number() OVER(PARTITION BY customer_id ORDER BY market_date DESC) as [purchase_num_by_customer]
FROM customer_purchases
)
WHERE [purchase_num_by_customer] = 1;


/* 3. Using a COUNT() window function, include a value along with each row of the 
customer_purchases table that indicates how many different times that customer has purchased that product_id. */

SELECT *, count(product_id)

FROM customer_purchases
GROUP BY customer_id, product_id;



-- String manipulations
/* 1. Some product names in the product table have descriptions like "Jar" or "Organic". 
These are separated from the product name with a hyphen. 
Create a column using SUBSTR (and a couple of other commands) that captures these, but is otherwise NULL. 
Remove any trailing or leading whitespaces. Don't just use a case statement for each product! 

| product_name               | description |
|----------------------------|-------------|
| Habanero Peppers - Organic | Organic     |

Hint: you might need to use INSTR(product_name,'-') to find the hyphens. INSTR will help split the column. */

  --If ' -' appears in the product_name then replace the name with the inital part of the string before ' -' occurs
  --otherwise leave the produt_name as is
SELECT product_id,  
	CASE WHEN instr(product_name, ' -') > 0
		THEN substr(product_name, 0, (instr(product_name, ' -')) ) 
		ELSE product_name
	END AS product_name
	,product_size
	,product_category_id
	,product_qty_type
FROM product;



/* 2. Filter the query to show any product_size value that contain a number with REGEXP. */

SELECT product_id
	,CASE WHEN instr(product_name, ' -') > 0
		THEN substr(product_name, 0, (instr(product_name, ' -')) ) 
		ELSE product_name
		END AS product_name
	,product_size
	,product_category_id
	,product_qty_type
FROM product
  --only show rows where the product_size contains a number
WHERE product_size REGEXP '[0-9]' =1

-- UNION
/* 1. Using a UNION, write a query that displays the market dates with the highest and lowest total sales.

HINT: There are a possibly a few ways to do this query, but if you're struggling, try the following: 
1) Create a CTE/Temp Table to find sales values grouped dates; 
2) Create another CTE/Temp table with a rank windowed function on the previous query to create 
"best day" and "worst day"; 
3) Query the second temp table twice, once for the best day, once for the worst day, 
with a UNION binding them. */


 --Create a temp table called daily_totals that shows the total revenue per day from the customer_purchases table
DROP TABLE IF EXISTS daily_totals;

CREATE TEMP TABLE daily_totals AS
  SELECT market_date,
	SUM(quantity*cost_to_customer_per_qty) as daily_total
		
  FROM customer_purchases
  GROUP BY market_date;

  --Createa a table containing only the row with the lowest daily value from the daily_totals table
SELECT market_date, min(daily_total) as daily_total
FROM daily_totals

UNION

 --Union this with the table containing only the row with the highest daily_total from the daily_totals table
SELECT market_date, max(daily_total)
FROM daily_totals

