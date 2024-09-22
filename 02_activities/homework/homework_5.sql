-- Cross Join
/*1. Suppose every vendor in the `vendor_inventory` table had 5 of each of their products to sell to **every** 
customer on record. How much money would each vendor make per product? 
Show this by vendor_name and product name, rather than using the IDs.

HINT: Be sure you select only relevant columns and rows. 
Remember, CROSS JOIN will explode your table rows, so CROSS JOIN should likely be a subquery. 
Think a bit about the row counts: how many distinct vendors, product names are there (x)?
How many customers are there (y). 
Before your final group by you should have the product of those two queries (x*y).  */

--Create a temp table that shows the number of customers
DROP TABLE IF EXISTS num_customers;

CREATE TEMP TABLE num_customers AS

SELECT count(customer_id) AS number_of_customers
FROM customer;

--Create a table which includes vendor_id, product_id
-- and calculates the cost of (5 *original_price)*(number of customers) for each product

DROP TABLE IF EXISTS cost_of_five;

CREATE TEMP TABLE cost_of_five AS

SELECT vendor_id, product_id, (price_times_5*number_of_customers) AS [cost_5_per_customer]
FROM
(
	SELECT vendor_id, product_id, (original_price*5) AS [price_times_5], [number_of_customers]
	FROM vendor_inventory
	JOIN num_customers
	GROUP BY  product_id 
);

--Create a temp table that add the vendor names to the previous temp table

DROP TABLE IF EXISTS add_vendor_name;
CREATE TEMP TABLE add_vendor_name AS

SELECT vendor.vendor_name, 
	cost_of_five.product_id, 
	cost_of_five.cost_5_per_customer
FROM cost_of_five

LEFT JOIN vendor

ON cost_of_five.vendor_id = vendor.vendor_id
ORDER BY cost_of_five.vendor_id;

--Add product names to the previous temp table

SELECT vendor_name, product_name, cost_5_per_customer
FROM product
INNER JOIN
add_vendor_name
ON product.product_id = add_vendor_name.product_id;


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

---Note this code has some errors in running which I will fix
--Create TEMP table with only the most recent purchase of each product
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

SELECT product_units.product_id, product_name, product_size, product_qty_type, snapshot_timestamp, current_quantity, recent.quantity,
CASE WHEN product_units.quntity = NULL
	THEN  0
END;
FROM
product_units

LEFT JOIN recent
ON product_units.product_id = recent.product_id



UPDATE product_units
SET
  product_units.current_quantity = recent.quantity
FROM
  recent
WHERE recent.quantity != 0;


