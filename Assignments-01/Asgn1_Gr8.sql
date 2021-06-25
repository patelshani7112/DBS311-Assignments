-- DBS311NBB - Assignment 1
-- Group 8  
-- Members: Eakampreet Singh (100828201)
--          Shani Patel (152243192)
--          Vishwa Inder Singh (129377206)
--          Yash Padsala (150450195)
------------------------------------------
-- Question 1
SELECT employee_id "Emp#", (first_name || ' ' || last_name) "Full Name", 
        job_title "Job", to_char(hire_date, 'fmDdspTH "of" Month"," YYYY') "Start Date" 
FROM employees 
WHERE to_char(hire_date, 'mm') NOT IN ('09', '10', '11') 
    AND job_title LIKE 'A%' 
    AND Length(job_title) <= 20 
ORDER BY hire_date DESC;

-- Question 2
SELECT (last_name ||', '|| first_name) "Emp Name", 
        TO_CHAR(SUM(unit_price * quantity),'$999,999,999.99') "Total Sale" 
FROM orders o JOIN order_items oi USING(order_id) 
              JOIN employees e ON o.salesman_id = e.employee_id 
GROUP BY salesman_id,
         last_name,
         first_name
HAVING substr(first_name,length(first_name), 1) != 'y'
ORDER BY 2 DESC;

-- Question 3
SELECT (e.last_name || ', ' || e.first_name) "Emp Name",
       to_char(SUM(oi.quantity * oi.unit_price), '$99,999,999.99') "Total Sale"
FROM employees e RIGHT JOIN orders o
    ON e.employee_id = o.salesman_id
       RIGHT JOIN order_items oi
            ON o.order_id = oi.order_id
WHERE SUBSTR(lower(e.first_name),-1,1) <> '%y'
    OR o.salesman_id is null
HAVING SUM(oi.quantity*oi.unit_price) > 4000000
GROUP BY e.last_name, e.first_name
ORDER BY 2 DESC;

--QUESTION 4 
SELECT c.customer_id "CustId", c.name "Name", NVL(o.TotalOrderCust, 0) "Total Orders"
FROM customers c FULL OUTER JOIN (SELECT customer_id, COUNT(*) AS TotalOrderCust
                                  FROM orders
                                  GROUP BY customer_id)o 
                                  ON c.customer_id = o.customer_id
WHERE NVL(o.TotalOrderCust, 0) < 2 AND
((substr(name,1,1) = 'B' AND INSTR(substr(name,2,30), 'l') > 0) 
OR    (substr(name,1,1) = 'L' AND INSTR(substr(name,2,30), 'b') > 0))
AND (INSTR(Name, 'Bank of New York Mellon')) = 0
ORDER BY 3, 2;

-- Question 5
SELECT customer_id "Cust#", NAME "Customer Name", order_id "Order#", order_date "Order Date",
        SUM(quantity) "Total#",To_CHAR(SUM(unit_price * quantity), 'fm$9,999,999.00') "Total Amount", last_name "LName"
FROM customers c INNER JOIN orders USING (customer_id)
                 INNER JOIN order_items USING (order_id)
                 INNER JOIN contacts USING (customer_id)       
WHERE substr(phone, 4, 3) = '319'
AND last_name NOT IN ('Norris')
GROUP BY customer_id, name, order_id, order_date, last_name
HAVING SUM(unit_price * quantity) < 800000
ORDER BY SUM(unit_price * quantity) desc;

-- Question 6
SELECT warehouse_id "Wrhs#", 
       warehouse_name "Warehouse Name", 
       category_id "Category#", 
       category_name "Category Name", 
       TO_CHAR(MIN(list_price), 'fm$9,999,999.00') "Lowest Price"
FROM warehouses w INNER JOIN inventories USING (warehouse_id) 
                  INNER JOIN products USING (product_id)
                  INNER JOIN product_categories USING (category_id)
                  INNER JOIN locations USING (location_id)
                  INNER JOIN countries USING (country_id)
WHERE country_name LIKE 'C%'
GROUP BY warehouse_id, warehouse_name, category_id, category_name
HAVING MIN(list_price) < 50.00 OR MIN(list_price) > 200
ORDER BY 1, 3;

-- Question 7
SELECT product_id "ProdId",
       category_id "Category#",
       product_name "Product Name",
       list_price "Lprice"
FROM products
WHERE product_id IN (SELECT product_id
                     FROM order_items
                     WHERE order_id IN (SELECT order_id
                                        FROM orders
                                        WHERE salesman_id IN (SELECT employee_id
                                                              FROM employees
                                                              WHERE UPPER(last_name) LIKE 'E%' OR
                                                                 UPPER(last_name) LIKE 'F%')))
AND category_id = (SELECT category_id
                   FROM product_categories
                   WHERE UPPER(category_name) LIKE 'VIDEO%')
ORDER BY 1 ASC;

-- Question 8
SELECT product_id "ProdId",
       product_name "Product Name",
       list_price "Lprice"
FROM products
WHERE product_id IN (SELECT product_id
                     FROM order_items
                     WHERE order_id IN (SELECT order_id
                                        FROM orders
                                        WHERE salesman_id IN (SELECT employee_id
                                                              FROM employees
                                                              WHERE SUBSTR(UPPER(last_name), 1, 1) IN ('E', 'F')
                                                                AND SUBSTR(TO_CHAR(hire_date), 4,3) = 'DEC')))
                                                                    
AND category_id = (SELECT category_id
                   FROM product_categories
                   WHERE UPPER(category_name) LIKE 'VIDEO%')
ORDER BY 1 ASC;

-- Question 9
SELECT product_id "Product ID",
       product_name "Product Name",
       TO_CHAR(list_price, 'fm$9,999,999.00') "List Price"
FROM products INNER JOIN inventories USING (product_id)
WHERE list_price < ANY (SELECT MIN(standard_cost)
                        FROM warehouses INNER JOIN locations USING (location_id)
                                        INNER JOIN countries USING (country_id)
                                        INNER JOIN regions USING (region_id)
                                        INNER JOIN inventories USING (warehouse_id)
                                        INNER JOIN products USING (product_id)
                        WHERE UPPER(region_name) IN ('EUROPE', 'ASIA')
                        GROUP BY warehouse_id)
AND quantity > ANY (SELECT MAX(quantity)
                    FROM inventories
                    GROUP BY warehouse_id)
ORDER BY list_price DESC;     
