-- Preview superstore data
SELECT * FROM superstore;


-- Preview state info data
SELECT * FROM state_info


-- Null values removed within table settings


-- 1) Postal data (average standard delivery time by state)
SELECT 
	a.state,
	a.po_per_100000,
	ROUND(AVG(delivery_time), 1) AS average_delivery
FROM(
	SELECT 
		DISTINCT(order_id),
		STR_TO_DATE(order_date, '%c/%d/%Y') AS order_date,
		STR_TO_DATE(ship_date, '%c/%d/%Y') AS ship_date,
		TIMESTAMPDIFF(DAY, STR_TO_DATE(order_date, '%c/%d/%Y'), STR_TO_DATE(ship_date, '%c/%d/%Y')) AS delivery_time,
		ship_mode,
		superstore.state,
		po_per_100000
	FROM superstore
	LEFT JOIN state_info ON superstore.state = state_info.State 
	WHERE ship_mode = 'Standard Class' AND segment = 'Consumer') a
GROUP BY 1,2
ORDER BY a.state;


-- 2a) Find the top 10 sub-categories for average time between purchases for repeat purchasers. 
SELECT
	b.sub_category,
	ROUND(AVG(b.difference),0)
FROM(
	SELECT 
		a.customer_id,
		sub_category,
		TIMESTAMPDIFF(DAY, LAG(date,1) OVER (PARTITION BY customer_id, sub_category ORDER BY customer_id, sub_category, date), date) AS difference
	FROM (
		SELECT
			customer_id,
			STR_TO_DATE(order_date, '%m/%d/%Y') AS date,
			sub_category
		FROM superstore
		WHERE segment = 'Consumer'
		ORDER BY customer_id, STR_TO_DATE(order_date, '%m/%d/%Y') ASC) a) b
WHERE b.difference > 0
GROUP BY 1
ORDER BY 2 DESC


-- 2b) Proportion of discounted orders above 50% that belong to each sub-category

-- **Discount was read in as an integer and rounded to 0 for each case so discount data was lost.
-- Thus, output is different to pandas
-- To calculate with discount filter: WHERE discount >= 0.5**

SELECT
	sub_category,
	COUNT(DISTINCT(order_id))
FROM superstore
WHERE segment = 'Consumer'
GROUP BY 1;


-- 2c) Most popular item colours

-- ** CASE WHEN would ideally be used to simplify and shorten query, but since the product description can contain
-- more than one colour, using case when would only count the first colour that appears in the query and would lead to a 
-- bias depending on the order the colours are checked. This is avoided using UNIONS as every colour that appears in the 
-- product name is counted. It is however much more long winded, thus only 4 colours have been checked, to demonstrate.
-- output. A collumn was deleted from the data when formatting to import, hence the black collumn having one less than
-- when using Python.**

SELECT 
	colour,
	COUNT(colour)
FROM(
	SELECT 
		DISTINCT(order_id),
		segment,
		product_name,
		"Black" AS colour
	FROM superstore
	WHERE LOWER(product_name) LIKE '%black%' AND segment = 'Consumer'-- In postgreSQL would use ILIKE
	UNION 
	SELECT 
		DISTINCT(order_id),
		segment,
		product_name,
		"Blue"
	FROM superstore
	WHERE LOWER(product_name) LIKE '%blue%'AND segment = 'Consumer'
	UNION 
	SELECT 
		DISTINCT(order_id),
		product_name,
		segment,
		"Red"
	FROM superstore
	WHERE LOWER(product_name) LIKE '%red%'AND segment = 'Consumer'
	UNION
	SELECT 
		DISTINCT(order_id),
		segment,
		product_name,
		"yellow"
	FROM superstore
	WHERE LOWER(product_name) LIKE '%yellow%' AND segment = 'Consumer') col
GROUP BY colour