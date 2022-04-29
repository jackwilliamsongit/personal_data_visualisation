-- Preview data
SELECT * FROM superstore;

-- Null values removed within table settings

-- Postal data (average standard delivery time by state)
SELECT 
	state,
	ROUND(AVG(delivery_time), 1)
FROM(
	SELECT 
		DISTINCT(order_id),
		STR_TO_DATE(order_date, '%c/%d/%Y') AS order_date,
		STR_TO_DATE(ship_date, '%c/%d/%Y') AS ship_date,
		TIMESTAMPDIFF(DAY, STR_TO_DATE(order_date, '%c/%d/%Y'), STR_TO_DATE(ship_date, '%c/%d/%Y')) AS delivery_time,
		ship_mode,
		state
	FROM superstore
	WHERE ship_mode = 'Standard Class' AND segment = 'Consumer') a
GROUP BY state
ORDER BY state

-- 