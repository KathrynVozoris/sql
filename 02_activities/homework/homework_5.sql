-- Cross Join
/*1. Suppose every vendor in the `vendor_inventory` table had 5 of each of their products to sell to **every** 
customer on record. How much money would each vendor make per product? 
Show this by vendor_name and product name, rather than using the IDs.

HINT: Be sure you select only relevant columns and rows. 
Remember, CROSS JOIN will explode your table rows, so CROSS JOIN should likely be a subquery. 
Think a bit about the row counts: how many distinct vendors, product names are there (x)?
How many customers are there (y). 
Before your final group by you should have the product of those two queries (x*y).  */

--Add the [product_name] from the 'product' table 
SELECT 	z.vendor_name
		,product.product_name
		,z.cost_5_per_customer
FROM
(
  --Add the [vendor_name] column from the 'vendor' table 
  --Calculate cost of 5x each product for all customers
  SELECT 	y.vendor_id
			,vendor.vendor_name
			,y.product_id
			,SUM(y.original_price*5) AS cost_5_per_customer
  FROM
  
  (	--Add the columns [vendor_id] and [orginal_price] from 'vendor_inventory' table
	 SELECT vi.vendor_id, x.product_id, vi.original_price, x.customer_id
	 FROM
	(
		---Add list of customer_id's to the list of products in 'vendor_inventory' table
		
		SELECT product_id, customer.customer_id
		FROM 
		(SELECT DISTINCT product_id
			FROM vendor_inventory) AS w
		CROSS JOIN
		customer
	) AS x
	LEFT JOIN vendor_inventory as vi
	ON x.product_id = vi.product_id
	GROUP BY x.product_id, customer_id
		
  ) AS y
  
  INNER JOIN vendor
  ON y.vendor_id = vendor.vendor_id
  GROUP BY product_id
  
  ) AS Z
 
INNER JOIN product
ON z.product_id = product.product_id
GROUP BY z.product_id
 

-- INSERT
/*1.  Create a new table "product_units". 
This table will contain only products where the `product_qty_type = 'unit'`. 
It should use all of the columns from the product table, as well as a new column for the `CURRENT_TIMESTAMP`.  
Name the timestamp column `snapshot_timestamp`. */

CREATE TABLE product_units AS
SELECT *
,CURRENT_TIMESTAMP as snapshot_timestamp
FROM product
WHERE product_qty_type = 'unit'

/*2. Using `INSERT`, add a new row to the product_units table (with an updated timestamp). 
This can be any product you desire (e.g. add another record for Apple Pie). */

INSERT INTO product_units
	VALUES(40, 'Peach pie', '12"', 2, 'unit', CURRENT_TIMESTAMP)

-- DELETE
/* 1. Delete the older record for the whatever product you added. 

HINT: If you don't specify a WHERE clause, you are going to have a bad time.*/

DELETE FROM product_units
WHERE product_name like 'Cherry pie%' AND snapshot_timestamp = '2024-09-21 17:37:20';

-- UPDATE
/* 1.We want to add the current_quantity to the product_units table. 
First, add a new column, current_quantity to the table using the following syntax.

ALTER TABLE product_units
ADD current_quantity INT;

Then, using UPDATE, change the current_quantity equal to the last quantity value from the vendor_inventory details.

HINT: This one is pretty hard. 
First, determine how to get the "last" quantity per product. 
Second, coalesce null values to 0 (if you don't have null values, figure out how to rearrange your query so you do.) 
Third, SET current_quantity = (...your select statement...), remembering that WHERE can only accommodate one column. 
Finally, make sure you have a WHERE statement to update the right row, 
	you'll need to use product_units.product_id to refer to the correct row within the product_units table. 
When you have all of these components, you can run the update statement. */

--Add the column current_quantity to the table product_units
ALTER TABLE product_units
ADD current_quantity INT;


--Create a temp table called 'recent' with only the most recent purchase of each product
--Include the columns [product_id], [quantity] and [market date]
DROP TABLE IF EXISTS recent;

CREATE TEMP TABLE recent AS

SELECT *
FROM
(
	SELECT product_id, quantity, market_date
			,dense_rank() OVER(PARTITION BY product_id ORDER BY market_date DESC) as [ranking]
	FROM vendor_inventory
)x
WHERE x.[ranking]= 1;


--Using LEFT JOIN add the [quantity] column from the 'recent' table to the 'product_units' table
-- Update [current_quantity] to be the same value as [quantity] in the 'products_units' table
UPDATE product_units
SET current_quantity = x.quantity
FROM
(
SELECT 	product_units.product_id
		,product_name
		,product_size
		,product_category_id 
		,product_qty_type
		,snapshot_timestamp
		,CASE 
			WHEN recent.quantity IS NULL
			THEN 0
			ELSE recent.quantity
		END AS quantity
FROM
product_units
LEFT JOIN recent
ON product_units.product_id = recent.product_id
) x
WHERE current_quantity is NULL AND product_units.product_id = x.product_id





