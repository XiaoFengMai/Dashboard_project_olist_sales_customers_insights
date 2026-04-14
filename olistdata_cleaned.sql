-- this query is creating a dataset that answers: for all delivered orders, show order details, customer location, product category, and total payment per item
-- this query is at the item level, NOT order level meaning one order with 3 items will appear 3 times becaues payment_value is per item


-- the SELECT retreives a specified value from a table, combines raw order info (order_id, timestamp, customer_id), a calculated field (price + freight), and joined data (product category, customer state)
SELECT
	o.order_id,				-- o is short for the orders table so o.order_id = orders.order_id; getting order_id from the orders table
	o.customer_id,				-- retrieves the customer_id from the order table, tells who placed what order
	o.order_purchase_timestamp,		-- retrieves the date and time the order was placed from the orders table, useful for time analysis, building dashboards for 
	oi.price + oi.freight_value AS payment_value,		-- oi short for ordered_items table so the price (product cost) and freight value (shipping cost) from ordered_items table are added and named payment_value
	p.product_category_name,		-- p is the alias; retrieve the product category name (electronics, furniture), one order witih multiple categories are separated into multiple rows
	c.customer_state			-- c is the alias; the state where the customer lives, useful or geoegraphic analysis, regional sales breakdowns

FROM orders o		-- tells SQL the main table is orders, "o" is the alias
JOIN order_items oi 	ON o.order_id = oi.order_id			-- joins the orders table with order_items table and adds a new product_id column to the order table for where order_id matches from both tables. creates a one-to-many relationship where one order has multiple items
JOIN products p			ON oi.product_id = p.product_id			-- joins order_items table with products tables and adds a new category column to the order table for where product_id matches from both tables. to add category details 
JOIN customers c		ON o_customer_id = c.customer_id			-- joins orders table with customers table and adds a new state column for where customer_id matches in both tables
WHERE o.order_status = 'delivered';			-- filters the data to only include orders were successfully delivered


-- the joins are essentialling attaching extra columns from another table where the IDs match

