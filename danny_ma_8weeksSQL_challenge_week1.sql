/* --------------------
   Case Study Questions
   --------------------*/
-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
/* 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
not just sushi - how many points do customer A and B have at the end of January? */

-- -- 1. What is the total amount each customer spent at the restaurant?
SELECT customer_id, SUM(price) AS total_amount
FROM sales S JOIN menu M ON S.product_id = M.product_id 
GROUP BY 1 ;

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, COUNT( DISTINCT order_date )
FROM sales 
GROUP BY 1;

-- 3. What was the first item from the menu purchased by each customer?
WITH cte AS (
SELECT customer_id, order_date , s.product_id, product_name,ROW_NUMBER () OVER ( PARTITION BY customer_id ORDER BY order_date ) AS row_no
FROM sales S JOIN menu M ON S.product_id = M.product_id)
SELECT customer_id, product_name AS first_item_purchased
FROM cte
WHERE row_no = 1
/*At first, I create a new table joining sale and menu tables together.
-- Assigning a numbering to each customer_id orders as a new column using Row_number window functions
-- I made the query result above as CTE and extract each customer_id with their first product ordered(using where row_number = 1 */;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT s.customer_id, m.product_name AS most_purchased_item, count(s.order_date) AS no_of_time_purchased
FROM sales as S
JOIN menu as M
ON S.product_id = M.product_id
GROUP BY 1,2
HAVING product_name = ( WITH product_no_of_purchase_table AS (
SELECT M.product_name, COUNT(product_name) AS total_no_of_purchase
FROM sales S JOIN menu M ON S.product_id = M.product_id
GROUP BY 1)
SELECT product_name 
FROM product_no_of_purchase_table 
WHERE total_no_of_purchase = (SELECT MAX(total_no_of_purchase) FROM product_no_of_purchase_table) );
/* Breaking the question down, I need the most purchased item from the menu, and also how many of it each customer bought. 
 
To check for the most purchased item from the menu, I look into all the product and count number of times they are bought with the query below
**SELECT M.product_name, COUNT(product_name) AS total_no_of_purchase
FROM sales S JOIN menu M ON S.product_id = M.product_id
GROUP BY 1**
To pick out the most purchased items from the result, I created a table with the result from the query above using CTE(product_no_of_purchase_table)
Then,I selected only the product_name with max total no of purchase AS most_purchased_product by filtering with the query below
**SELECT product_name FROM cte WHERE total_no_of_purchase = (SELECT MAX(total_no_of_purchase) FROM cte)**
Finally, I counted number of the most_purchased_item bought by each customer using GROUP BY and filtered by product_name with max_no_of_purchased
from the CTE(product_no_of_purchase_table) results*/ 

-- 5. Which item was the most popular for each customer?  
WITH cte AS (
SELECT DISTINCT customer_id, product_name, COUNT(s.product_id) AS product_count
FROM sales s JOIN menu m ON s.product_id = m.product_id 
GROUP BY 1,2
ORDER BY 1,3 DESC ) 
SELECT *, DENSE_RANK () OVER ( PARTITION BY customer_id ORDER BY product_count DESC ) AS product_rank
FROM cte ;
/* Assuming that Most popular refer to most bought product by each customer. To do this,Joining sale and menu together, I created a table showing the 
customer_id, product_name, and counted each product bought by customer( AS product_count ). I then create a CTE and add a new column to densely
ranked customer product by the number of purchased from higher to lower AS product ranked. */

-- 6. Which item was purchased first by the customer after they became a member?
WITH cte AS (
SELECT s.customer_id, product_name, join_date, order_date,
 ROW_NUMBER () OVER ( PARTITION BY customer_id ORDER BY order_date) AS row_no
FROM sales s JOIN menu m USING ( product_id ) LEFT JOIN members me ON s.customer_id = me.customer_id
WHERE order_date >= join_date ) 
SELECT customer_id, product_name AS first_product
FROM cte 
WHERE row_no = 1 ;
/* At first, I created a table joining the sale, menu and member together, and add a new column( row_no) using window function
to numbering the customer orders by order_date. Then I selected out customer first product by filtering out customer first order.*/

-- 7. Which item was purchased just before the customer became a member?
SELECT S.customer_id, product_name, join_date, order_date 
FROM sales S JOIN menu M USING ( product_id ) LEFT JOIN members me ON s.customer_id = me.customer_id 
WHERE order_date < join_date -- to filter customer order before becoming member 
ORDER BY 1;
/* To show product purchased after customer becoming a member, I joined the 3 tables together and
filter filter customer order before becoming member  using ** WHERE order_date < join_date** */

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id, COUNT(*) AS total_items, SUM(price) AS total_amount
FROM sales s JOIN menu m USING ( product_id ) LEFT JOIN members me ON s.customer_id = me.customer_id 
WHERE order_date < join_date
GROUP BY 1 
ORDER BY 1;
/* Breaking the question, I need to show each customers, their total items, and total amount spent before becoming member.
To this, I joined the 3 tables together then selecting customers, creating their total items and total amount, only
where the customer order before becaming memeber */

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH customers_point AS (
SELECT customer_id, product_name, price, 10*price AS points,
	CASE WHEN product_name = 'sushi' THEN 2*10*price
		 ELSE 10*price 
	END AS new_points
FROM sales JOIN menu USING ( product_id ) )
SELECT customer_id, SUM(new_points) AS total_points
FROM customers_point
GROUP BY 1;
/* At first, I create new table by joining the sale and menu table together. This new table involves
customer_id, product_name, price, and two additional columns. A new column named "points" which is equal
to 10 multiply by price( because $1 equals 10points). Also another column named "new_points" using CASE statement.
This was obtained by multiplying the points by 2 if the product_name is sushi and the points remain the same for others.
To obtained total points for each customers, I used CTE(customers_point) for the table created and SUM the new_points( as total_points),
then grouped it by each customer */

/* 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
not just sushi - how many points do customer A and B have at the end of January? */

WITH cte AS(
SELECT s.customer_id, product_name, join_date, order_date, price,  join_date + INTERVAL 7 DAY AS first_week_after_customer_joins,
	CASE
		WHEN order_date BETWEEN join_date AND join_date + INTERVAL 7 DAY THEN 2*10*price
        ELSE price*10
	END AS customer_point
FROM sales s JOIN menu m USING ( product_id ) JOIN members me ON s.customer_id = me.customer_id)
SELECT customer_id, SUM(customer_point)
FROM cte
WHERE month(order_date) = 1
GROUP BY 1 ;
/* After merging the sale, member and menu tables together, I created a column(first_week_after_customer_joins) by adding
7 days to thr join date column to show date for a week afte customer joined. 
Also to give the 2x point on all items, I created another column using CASE statement. This is by assigning 2*10*price to the
orders made BETWEEN join_date AND the new created "first_week_after_customer_joins" and leaving the price if the condition was not met.
Finally, to answer the question, I created a CTE table including customer_id, product_name,join_date, order_date, price, and the
2 new columns(first_week_after_customer_joins and customer_point), then SUMming the customer_points by customer_id, This was done for
orders only in the month of january (WHERE month(order_date) = 1)  */

-- END OF CHALLENGE ONE Case Study Questions.................... 

    -- Bonus Questions !!! 
    
    -- JOIN ALL THE THINGS
SELECT s.customer_id, order_date, product_name, price, 
	CASE WHEN order_date >= join_date THEN 'Y' ELSE 'N' END AS members
FROM sales s JOIN menu m USING( product_id) LEFT JOIN members mem ON s.customer_id = mem.customer_id ;

/* Danny also requires further information about the ranking of customer products, 
but he purposely does not need the ranking for non-member purchases so he expects null ranking values 
for the records when customers are not yet part of the loyalty program. */
SELECT *,
	CASE WHEN order_date >= join_date THEN 'Y' ELSE 'N' END AS members, 
	RANK() OVER ( PARTITION BY s.customer_id ORDER BY order_date ) AS ranking
FROM sales s JOIN menu m USING( product_id) LEFT JOIN members mem ON s.customer_id = mem.customer_id
WHERE order_date >= join_date ;



