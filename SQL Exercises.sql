USE sql_store;

SELECT first_name, last_name, points, (points + 10) * 0.01 AS 'discount factor'
FROM customers;

SELECT state FROM customers;

UPDATE `sql_store`.`customers` SET `state` = 'VA' WHERE (`customer_id` = '1');

SELECT DISTINCE state FROM customers;

-- return all the products
-- 	name
-- 	unit price
-- 	new price
SELECT name, unit_price, unit_price*1.1 AS 'new price' FROM products;

-- get orders place in 2019 onwards
SELECT * FROM orders WHERE order_date >= '2019-01-01';

-- from the order_items table, get the items
-- 	order #6
--  where the total price is greater than 30
SELECT * FROM order_items WHERE order_id = 6 AND unit_price * quantity > 30;

-- return products with quantity in stock equal to 49, 38, 72
SELECT * FROM products WHERE quantity_in_stock IN (49, 38, 72);

-- return customers born between 1/1/1990 and 1/1/2000
SELECT * FROM customers WHERE birth_date BETWEEN '1990-01-01' AND '2000-01-01';

-- get customers whose
--  addresses contain TRAIL or AVENUE
--  phone numbers end with 9
--  phone numbers start with 3
SELECT * FROM customers WHERE address LIKE '%TRAIL%' OR address LIKE '%AVENUE%';
SELECT * FROM customers WHERE phone LIKE '%9';
SELECT * FROM customers WHERE address REGEXP 'trail|avenue';
SELECT * FROM customers where phone REGEXP '9$|^3';

-- ^ beginning
-- $ end
-- | logical or
-- [] match any single characters listed inside the brackets
-- [a-h] match single characters from a range

-- get the customers whose
--  first names are ELKA or AMBUR
--  last names end with EY or ON
--  last names start with MY or contains SE
--  last names contain B followed by R or U
SELECT * FROM customers WHERE first_name REGEXP 'ELKA|AMBUR';
SELECT * FROM customers WHERE last_name REGEXP 'EY$|ON$';
SELECT * FROM customers WHERE last_name REGEXP '^MY|SE';
SELECT * FROM customers WHERE last_name REGEXP 'B[RU]';

-- get the orders that are not shipped
SELECT * FROM orders WHERE shipped_date IS NULL;

-- get the top three loyal customers
SELECT * FROM customers ORDER BY points DESC LIMIT 3;

-- INNER JOIN
SELECT order_id, o.customer_id, first_name, last_name FROM orders o JOIN customers c ON o.customer_id = c.customer_id;
-- join order_items table with products table
SELECT order_id, o.product_id, quantity, o.unit_price FROM order_items o JOIN products p ON o.product_id = p.product_id;

-- JOINING ACROSS DATABASE
SELECT * FROM order_items o JOIN sql_inventory.products p ON o.product_id = p.product_id;

-- SELF JOINS
USE sql_hr;
SELECT e.employee_id, e.first_name, m.first_name AS 'manager' FROM employees e JOIN employees m ON e.reports_to = m.employee_id;

-- JOIN Multiple Tables
USE sql_store;

SELECT o.order_id, o.order_date, c.first_name, c.last_name, os.name AS 'status' FROM orders o 
JOIN customers c ON o.customer_id = c.customer_id 
JOIN order_statuses os ON o.status = os.order_status_id;

-- join payments table with payment_methods table and the clients table
USE sql_invoicing;

SELECT p.date, p.invoice_id, p.amount, c.name AS'client name', pm.name AS 'payment method' FROM payments p
JOIN payment_methods pm ON p.payment_method = pm.payment_method_id
JOIN clients c ON p.client_id = c.client_id;

-- COMPOUND JOINS CONDITION
USE sql_store;

SELECT * FROM order_items oi
JOIN order_item_notes oin on oi.order_id = oin.order_id AND oi.product_id = oin.product_id;

-- IMPLICIT JOIN SYNTAX
SELECT * FROM orders o, customers c
WHERE o.customer_id = c.customer_id;

-- OUTER JOIN
SELECT c.customer_id, c.first_name, o.order_id FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id;

-- outer join products table with the order_items table so we can see how many times each produts are ordered
SELECT p.product_id, p.name, o.quantity FROM products p
LEFT JOIN order_items o ON p.product_id = o.product_id;

-- OUTER JOINS BETWEEN MULTIPLE TABLES
SELECT c.customer_id, c.first_name,  o.order_id, s.name AS 'shipper' FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN shippers s ON o.shipper_id = s.shipper_id
ORDER BY c.customer_id;

-- order_date, order_id, first_name of customer, shipper name, shipping status
SELECT o.order_date, o.order_id, c.first_name, s.name AS 'shipper', os.name as 'status' FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN shippers s ON o.shipper_id = s.shipper_id
JOIN order_statuses os ON o.status = os.order_status_id
ORDER BY os.name;

-- SELF OUTER JOINS
USE sql_hr;

SELECT e.employee_id, e.first_name, m.first_name AS 'manager' FROM employees e
LEFT JOIN employees m ON e.reports_to = m.employee_id;

-- USING CLAUSE
USE sql_store;
SELECT o.order_id, c.first_name, s.name as 'shipper' FROM orders o
JOIN customers c USING (customer_id)
LEFT JOIN shippers s USING (shipper_id);

SELECT * FROM order_items oi
JOIN order_item_notes oin USING (order_id, product_id);

-- select payments table and show date, client, amount, payment method
USE sql_invoicing;

SELECT p.date, c.name, p.amount, pm.name AS 'payment method' FROM payments p
JOIN clients c USING (client_id)
JOIN payment_methods pm ON p.payment_method = pm.payment_method_id;

-- NATURAL JOINS
USE sql_store;

SELECT o.order_id, c.first_name FROM orders o 
NATURAL JOIN customers c;

-- CROSS JOIN
SELECT c.first_name, p.name FROM customers c 
CROSS JOIN products p
ORDER BY c.first_name;

SELECT c.first_name, p.name FROM customers c, products p
ORDER BY c.first_name;

-- do a cross join between shippers and products using the implicit syntax and then using the explicit syntax
SELECT * FROM shippers s
CROSS JOIN products p
ORDER BY s.name;

SELECT * FROM shippers s , products p ORDER BY s.name;

-- UNIONS
SELECT order_id, order_date, 'Active' as 'status' FROM orders 
WHERE order_date >= '2019-01-01'
UNION
SELECT order_id, order_date, 'Archive' as 'status' FROM orders 
WHERE order_date < '2019-01-01';

SELECT first_name FROM customers
UNION
SELECT name FROM shippers;

-- customer_id, first_name, points, type (<2000 = bronze, 2000-3000 = silver, >3000 gold) order by first_name
SELECT customer_id, first_name, points,'Bronze' AS 'type' FROM customers
WHERE points<2000
UNION
SELECT customer_id, first_name, points, 'Silver' AS 'type' FROM customers
WHERE points>2000 AND points<3000 
UNION
SELECT customer_id, first_name, points, 'Gold' AS 'type' FROM customers 
WHERE points>3000
ORDER BY type;