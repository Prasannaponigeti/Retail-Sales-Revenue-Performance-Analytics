CREATE DATABASE coffee_shop_sales;

USE coffee_shop_sales;
SELECT DATABASE();
CREATE TABLE coffee_sales (
    transaction_id INT,
    transaction_date DATE,
    transaction_time TIME,
    store_id INT,
    store_location VARCHAR(100),
    product_id INT,
    transaction_qty INT,
    unit_price DECIMAL(10,2),
    product_category VARCHAR(100),
    product_type VARCHAR(150),
    product_detail VARCHAR(200),
    Size VARCHAR(50),
    Total_bill DECIMAL(10,2),
    `Month Name` VARCHAR(20),
    `Day Name` VARCHAR(20),
    Hour INT,
    `Day of Week` INT,
    Month INT
);

SELECT COUNT(*) AS row_count
FROM coffee_sales;

SELECT *
FROM coffee_sales
LIMIT 5;

-- What is the overall performance of the coffee shop in terms of transactions, items sold, total revenue, and average order value?
SELECT
    COUNT(*) AS total_transactions,
    SUM(transaction_qty) AS total_items_sold,
    ROUND(SUM(Total_bill), 2) AS total_revenue,
    ROUND(
        SUM(Total_bill) / COUNT(DISTINCT transaction_id),
        2
    ) AS average_order_value
FROM coffee_sales;

-- Which store locations generate the most revenue, and how many transactions and items does each store handle?
SELECT
    store_location,
    COUNT(DISTINCT transaction_id) AS total_transactions,
    SUM(transaction_qty) AS total_items_sold,
    ROUND(SUM(Total_bill), 2) AS total_revenue,
    ROUND(
        SUM(Total_bill) / COUNT(DISTINCT transaction_id),
        2
    ) AS average_order_value
FROM coffee_sales
GROUP BY store_location
ORDER BY total_revenue DESC;

-- What percentage of the company's total revenue comes from each store?
SELECT
    store_location,
    ROUND(SUM(Total_bill), 2) AS store_revenue,
    ROUND(
        SUM(Total_bill) * 100.0 /
        SUM(SUM(Total_bill)) OVER (),
        2
    ) AS revenue_contribution_pct
FROM coffee_sales
GROUP BY store_location
ORDER BY revenue_contribution_pct DESC;

-- How does the coffee shop's revenue change from month to month?
SELECT
    YEAR(transaction_date) AS sales_year,
    MONTH(transaction_date) AS sales_month,
    DATE_FORMAT(transaction_date, '%M') AS month_name,
    ROUND(SUM(Total_bill), 2) AS monthly_revenue,
    COUNT(DISTINCT transaction_id) AS total_transactions
FROM coffee_sales
GROUP BY
    YEAR(transaction_date),
    MONTH(transaction_date),
    DATE_FORMAT(transaction_date, '%M')
ORDER BY
    sales_year,
    sales_month;
    
 -- Which hours of the day generate the highest sales revenue and transaction volume?
 SELECT
    Hour AS sales_hour,
    ROUND(SUM(Total_bill), 2) AS hourly_revenue,
    COUNT(DISTINCT transaction_id) AS total_transactions,
    SUM(transaction_qty) AS total_items_sold
FROM coffee_sales
GROUP BY Hour
ORDER BY hourly_revenue DESC;

-- Which days of the week generate the highest revenue and transaction volume?
SELECT
    `Day Name` AS day_name,
    ROUND(SUM(Total_bill), 2) AS total_revenue,
    COUNT(DISTINCT transaction_id) AS total_transactions,
    SUM(transaction_qty) AS total_items_sold
FROM coffee_sales
GROUP BY `Day Name`
ORDER BY total_revenue DESC;

-- Which product categories generate the most revenue, and how do their transaction volumes compare?
SELECT
    product_category,
    ROUND(SUM(Total_bill), 2) AS total_revenue,
    COUNT(DISTINCT transaction_id) AS total_transactions,
    SUM(transaction_qty) AS total_items_sold
FROM coffee_sales
GROUP BY product_category
ORDER BY total_revenue DESC;

-- Which individual products are generating the highest revenue, and how many units of each product were sold?
SELECT
    product_type,
    ROUND(SUM(Total_bill), 2) AS total_revenue,
    SUM(transaction_qty) AS total_items_sold,
    COUNT(DISTINCT transaction_id) AS total_transactions
FROM coffee_sales
GROUP BY product_type
ORDER BY total_revenue DESC
LIMIT 10;

-- How does sales performance vary across different product sizes?
SELECT
    Size AS product_size,
    ROUND(SUM(Total_bill), 2) AS total_revenue,
    SUM(transaction_qty) AS total_items_sold,
    COUNT(DISTINCT transaction_id) AS total_transactions,
    ROUND(
        SUM(Total_bill) / COUNT(DISTINCT transaction_id),
        2
    ) AS average_order_value
FROM coffee_sales
GROUP BY Size
ORDER BY total_revenue DESC;

-- How does each product category perform across the three store locations?
SELECT
    store_location,
    product_category,
    ROUND(SUM(Total_bill), 2) AS total_revenue,
    SUM(transaction_qty) AS total_items_sold,
    COUNT(DISTINCT transaction_id) AS total_transactions
FROM coffee_sales
GROUP BY
    store_location,
    product_category
ORDER BY
    store_location,
    total_revenue DESC;
    
-- How does monthly revenue change compared with the previous month?
WITH monthly_sales AS (
    SELECT
        YEAR(transaction_date) AS sales_year,
        MONTH(transaction_date) AS sales_month,
        DATE_FORMAT(transaction_date, '%M') AS month_name,
        SUM(Total_bill) AS monthly_revenue
    FROM coffee_sales
    GROUP BY
        YEAR(transaction_date),
        MONTH(transaction_date),
        DATE_FORMAT(transaction_date, '%M')
)

SELECT
    sales_year,
    sales_month,
    month_name,
    ROUND(monthly_revenue, 2) AS monthly_revenue,
    ROUND(
        LAG(monthly_revenue) OVER (
            ORDER BY sales_year, sales_month
        ),
        2
    ) AS previous_month_revenue,
    ROUND(
        (
            monthly_revenue -
            LAG(monthly_revenue) OVER (
                ORDER BY sales_year, sales_month
            )
        )
        * 100.0
        / LAG(monthly_revenue) OVER (
            ORDER BY sales_year, sales_month
        ),
        2
    ) AS mom_growth_pct
FROM monthly_sales
ORDER BY sales_year, sales_month;

-- Which products perform strongly across different store locations, and are there products whose revenue is concentrated in a particular store?
SELECT
    product_type,
    store_location,
    ROUND(SUM(Total_bill), 2) AS total_revenue,
    SUM(transaction_qty) AS total_items_sold,
    COUNT(DISTINCT transaction_id) AS total_transactions
FROM coffee_sales
GROUP BY
    product_type,
    store_location
ORDER BY
    product_type,
    total_revenue DESC;
    
-- What percentage of total revenue is generated by each product, and how concentrated is the business around its top products?
SELECT
    product_type,
    ROUND(SUM(Total_bill), 2) AS product_revenue,
    ROUND(
        SUM(Total_bill) * 100.0 /
        SUM(SUM(Total_bill)) OVER (),
        2
    ) AS revenue_contribution_pct,
    SUM(transaction_qty) AS total_items_sold
FROM coffee_sales
GROUP BY product_type
ORDER BY product_revenue DESC;

-- Which product category generated the highest revenue?
SELECT
    product_category,
    SUM(Total_bill) AS revenue
FROM coffee_sales
GROUP BY product_category
ORDER BY revenue DESC;

-- Which day of the week has the highest number of transactions?
SELECT
    `Day Name`,
    COUNT(DISTINCT transaction_id) AS total_transactions
FROM coffee_sales
GROUP BY `Day Name`
ORDER BY total_transactions DESC;

-- Which day of the week generates the highest revenue?
SELECT
    `Day Name`,
    ROUND(SUM(Total_bill), 2) AS total_revenue
FROM coffee_sales
GROUP BY `Day Name`
ORDER BY total_revenue DESC;

-- Which 5 products sold the highest number of items?

SELECT
    product_type,
    SUM(transaction_qty) AS total_items_sold
FROM coffee_sales
GROUP BY product_type
ORDER BY total_items_sold DESC
LIMIT 5;

-- What is the average price of products in each category?

SELECT
    product_category,
    ROUND(AVG(unit_price), 2) AS average_price
FROM coffee_sales
GROUP BY product_category
ORDER BY average_price DESC;

-- Which product categories have the highest average transaction quantity?
SELECT
    product_category,
    ROUND(AVG(transaction_qty), 2) AS avg_quantity_per_transaction
FROM coffee_sales
GROUP BY product_category
ORDER BY avg_quantity_per_transaction DESC;

-- Which product categories generate the highest revenue per item sold?
SELECT
    product_category,
    ROUND(
        SUM(Total_bill) / SUM(transaction_qty),
        2
    ) AS revenue_per_item
FROM coffee_sales
GROUP BY product_category
ORDER BY revenue_per_item DESC;

-- Which product types have the highest average selling price?
SELECT
    product_type,
    ROUND(AVG(unit_price), 2) AS average_price
FROM coffee_sales
GROUP BY product_type
ORDER BY average_price DESC
LIMIT 10;

-- Which products generate high revenue but have relatively low sales volume?
SELECT
    product_type,
    ROUND(SUM(Total_bill), 2) AS total_revenue,
    SUM(transaction_qty) AS total_items_sold
FROM coffee_sales
GROUP BY product_type
ORDER BY total_revenue DESC;

-- Which store has the highest average revenue per transaction?
SELECT
    store_location,
    ROUND(
        SUM(Total_bill) / COUNT(DISTINCT transaction_id),
        2
    ) AS avg_revenue_per_transaction
FROM coffee_sales
GROUP BY store_location
ORDER BY avg_revenue_per_transaction DESC;

-- Which product categories have the highest number of transactions?
SELECT
    product_category,
    COUNT(DISTINCT transaction_id) AS total_transactions
FROM coffee_sales
GROUP BY product_category
ORDER BY total_transactions DESC;

-- What is the revenue contribution of each product category?
SELECT
    product_category,
    ROUND(SUM(Total_bill), 2) AS total_revenue,
    ROUND(
        SUM(Total_bill) * 100.0 /
        SUM(SUM(Total_bill)) OVER (),
        2
    ) AS revenue_contribution_pct
FROM coffee_sales
GROUP BY product_category
ORDER BY revenue_contribution_pct DESC;

-- Which store generates the highest revenue for each product category?
SELECT
    product_category,
    store_location,
    ROUND(SUM(Total_bill), 2) AS total_revenue
FROM coffee_sales
GROUP BY product_category, store_location
ORDER BY product_category, total_revenue DESC;

-- Which month generated the highest revenue?
SELECT
    DATE_FORMAT(transaction_date, '%M') AS month_name,
    ROUND(SUM(Total_bill), 2) AS total_revenue
FROM coffee_sales
GROUP BY MONTH(transaction_date), DATE_FORMAT(transaction_date, '%M')
ORDER BY total_revenue DESC
LIMIT 1;