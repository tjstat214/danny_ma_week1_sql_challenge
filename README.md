# danny_ma_week1_sql_challenge
![Case study 1](Danny_MA_SQL_challenge_1.png)

To practice my SQL skill, I took Danny MA 8 weeks SQL challenge, case study number 1.
This project gives me the ability to apply my SQL knowlege to provide answers to business questions provided,
and also derived insight that can help make a better data driven decision.

## Introduction
Danny wants to use data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

Danny has provided a sample of his overall customer data due to privacy issues - but he hopes that these examples are enough to write fully functioning SQL queries to help him answer his questions!

Danny has shared with you 3 key datasets for this case study:
![members]()
![menu]()
![sales]()


### Below is the ERD that shows the relationship between the tables
![ERD](https://github.com/tjstat214/danny_ma_week1_sql_challenge/blob/main/ERD_1_for_danny_ma_SQLchallenge.png)

#### I will be using SQL queries to provide answers to danny questions.
## Question 1: What is the total amount each customer spent at the restaurant?
<pre>SELECT customer_id, SUM(price) AS total_amount
FROM sales S 
JOIN menu M
ON S.product_id = M.product_id 
GROUP BY 1;</pre>
I joined the menu and sales tables to get customer_id and price, then summed the prices as total_amount and grouped the results by each customer_id.

![answer1](results_folder/result1.png)

Customers A, B, and C spent $76, $74, and $36 respectively

## Question 2: How many days has each customer visited the restaurant?
<pre> 
SELECT customer_id, COUNT( DISTINCT order_date ) AS days_count
FROM sales 
GROUP BY 1;</pre>
I selected customer_id and counted distinct order_date to capture visits by day (ignoring visit times), then grouped the visit count by each customer_id
![answer2](results_folder/result2.png)

Customer A, B, and C visited the restaurant in 4,6, and 2 days respectively

## Question 3:







