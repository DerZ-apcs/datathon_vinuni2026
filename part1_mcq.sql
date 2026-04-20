-- ANSWER:
-- 1C
-- 2D
-- 3B
-- 4C
-- 5C
-- 6A
-- 7C
-- 8A
-- 9A
-- 10C

-- SQL Code
-- 1C
-- chỉ tính những đơn delivered
WITH ValidOrders AS (
    SELECT customer_id, order_date
    FROM orders
    WHERE order_status IN ('delivered')
),
PreviousOrders AS (
    SELECT 
        customer_id,
        order_date,
        LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_date
    FROM ValidOrders 
),
OrderGaps AS (
    SELECT 
		DATEDIFF(order_date, prev_date) AS days_between,
		ROW_NUMBER() OVER (ORDER BY DATEDIFF(order_date, prev_date)) AS row_num,
		COUNT(*) OVER () AS total_count
    FROM PreviousOrders
    WHERE prev_date IS NOT NULL
)
SELECT 
    AVG(days_between) AS median_gap
FROM OrderGaps
WHERE row_num IN (FLOOR((total_count + 1) / 2), CEIL((total_count + 1) / 2));

-- 2D
SELECT 
	segment,
	avg((price - cogs)/price) as gross_margin
FROM products
GROUP BY segment
ORDER BY gross_margin DESC
LIMIT 1;

-- 3B
SELECT 
	r.return_reason, 
    COUNT(*) AS total_returns
FROM returns r
INNER JOIN products p ON r.product_id = p.product_id
WHERE p.category = 'Streetwear'
GROUP BY r.return_reason
ORDER BY total_returns DESC;

-- 4C
SELECT 
	traffic_source,
    AVG(bounce_rate)
FROM web_traffic
GROUP BY traffic_source
ORDER BY AVG(bounce_rate) ASC
LIMIT 1;

-- 5C
SELECT 
	COUNT(CASE WHEN promo_id IS NOT NULL THEN order_id END) AS no_promo_count,
    COUNT(order_id) AS total_count,
    COUNT(CASE WHEN promo_id IS NOT NULL THEN order_id END) /COUNT(order_id)*100 AS no_promo_rate
FROM order_items;

-- 6A
WITH OrdersPerCustomer AS (
	SELECT 
		c.customer_id, 
        c.age_group, 
        COUNT(o.order_id) AS ord_per_cus
	FROM customers c
	INNER JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.age_group
)
SELECT 
	age_group,
	avg(ord_per_cus)
FROM OrdersPerCustomer
WHERE age_group IS NOT NULL
GROUP BY age_group
ORDER BY avg(ord_per_cus) DESC
LIMIT 1;

-- 7C
-- doanh thu (revenue) = price * unit - discount?
-- có cần ràng buộc bởi ord_status? 
-- geography (zip) -> orders (date/ zip/order_id) -> order_items (order_id, quantity*unit_price-discount_amount) ->
SELECT * FROM sales;
SELECT * FROM order_items;
WITH RevenuePerOrder AS (
	SELECT 
		orders.zip,
        order_items.order_id,
        SUM((order_items.quantity * order_items.unit_price - order_items.discount_amount)) AS rev_per_ord
	FROM orders 
    INNER JOIN order_items ON order_items.order_id = orders.order_id
    WHERE orders.order_status IN ('delivered')
    GROUP BY orders.order_id, orders.zip
)
SELECT 
	SUM(RevenuePerOrder.rev_per_ord) AS total_revenue,
    geography.region
FROM RevenuePerOrder
JOIN geography ON geography.zip = RevenuePerOrder.zip
GROUP BY region
ORDER BY total_revenue DESC
LIMIT 1;

-- 8A
SELECT 
	payment_method,
    COUNT(order_id) AS total
FROM orders
WHERE order_status = 'cancelled'
GROUP BY payment_method
ORDER BY total DESC
LIMIT 1;

-- 9A
-- rate = returns/total

WITH ReturnedSize AS(
	SELECT 
		products.size,
		COUNT(*) AS total
	FROM returns
	JOIN products ON products.product_id = returns.product_id
	GROUP BY products.size
),
OrderedSize AS(
	SELECT 
		products.size,
		COUNT(*) AS total
	FROM order_items
	JOIN products ON products.product_id = order_items.product_id
	GROUP BY products.size
)
SELECT 
	OrderedSize.size,
	ReturnedSize.total/OrderedSize.total AS return_rate
    
FROM ReturnedSize
RIGHT JOIN OrderedSize ON ReturnedSize.size = OrderedSize.size
ORDER BY return_rate DESC
LIMIT 1;

-- 10C
-- giá trị thanh toán = price*unit - discount?
WITH PaymentPerOrder AS(
	SELECT 
		order_id,
		SUM(quantity*unit_price-discount_amount) as payment_amount
	FROM order_items
	GROUP BY order_id
)
SELECT
	payments.installments,
    AVG(PaymentPerOrder.payment_amount) AS avg_payment
FROM PaymentPerOrder
JOIN payments ON PaymentPerOrder.order_id = payments.order_id
GROUP BY payments.installments
ORDER BY avg_payment DESC
LIMIT 1;


