CREATE DATABASE retail_supply_chain;

DROP TABLE IF EXISTS retail_orders;

CREATE TABLE retail_orders (
    row_id TEXT,
    order_id TEXT,
    order_date TEXT,
    ship_date TEXT,
    customer_id TEXT,
    customer_name TEXT,
    segment TEXT,
    country TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    region TEXT,
    product_id TEXT,
    category TEXT,
    sub_category TEXT,
    product_name TEXT,
    sales TEXT,
    quantity TEXT,
    discount TEXT,
    profit TEXT
);


SELECT * FROM retail_orders ;


ALTER TABLE retail_orders
ADD COLUMN order_date_new DATE;

UPDATE retail_orders
SET order_date_new =
TO_DATE(order_date, 'MM/DD/YYYY');


ALTER TABLE retail_orders
ADD COLUMN ship_date_new DATE;

UPDATE retail_orders
SET ship_date_new =
TO_DATE(ship_date, 'MM/DD/YYYY');



ALTER TABLE retail_orders
ADD COLUMN sales_new NUMERIC(10,2);

UPDATE retail_orders
SET sales_new = sales::NUMERIC;



ALTER TABLE retail_orders
ADD COLUMN quantity_new INT;

UPDATE retail_orders
SET quantity_new = quantity::INT;



ALTER TABLE retail_orders
ADD COLUMN discount_new NUMERIC(5,2);

UPDATE retail_orders
SET discount_new = discount::NUMERIC;



ALTER TABLE retail_orders
ADD COLUMN profit_new NUMERIC(10,2);

UPDATE retail_orders
SET profit_new = profit::NUMERIC;






CREATE TABLE retail_orders_clean AS
SELECT
    row_id,
    order_id,
    order_date_new AS order_date,
    ship_date_new AS ship_date,
    customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    postal_code,
    region,
    product_id,
    category,
    sub_category,
    product_name,
    sales_new AS sales,
    quantity_new AS quantity,
    discount_new AS discount,
    profit_new AS profit
FROM retail_orders;



SELECT *
FROM retail_orders_clean
LIMIT 5;

----- Check Null Values

SELECT *                      
FROM retail_orders
WHERE order_id IS NULL;



----Check Duplicates

SELECT order_id, product_id, COUNT(*)
FROM retail_orders
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;



---Add Delivery Days Column


ALTER TABLE retail_orders
ADD COLUMN delivery_days INT;


---Update Delivery Days

UPDATE retail_orders
SET delivery_days = ship_date_new - order_date_new;


---Total Revenue


SELECT 
    ROUND(SUM(sales), 2) AS total_revenue
FROM retail_orders_clean;

---Total Profit


SELECT 
    ROUND(SUM(profit), 2) AS total_profit
FROM retail_orders_clean;


---Profit Margin %


SELECT 
    ROUND(
        (SUM(profit) / SUM(sales)) * 100,
        2
    ) AS profit_margin_percent
FROM retail_orders_clean;



----Sales by Region


SELECT 
    region,
    ROUND(SUM(sales), 2) AS revenue
FROM retail_orders_clean
GROUP BY region
ORDER BY revenue DESC;


----Profit by Region


SELECT 
    region,
    ROUND(SUM(profit), 2) AS total_profit
FROM retail_orders_clean
GROUP BY region
ORDER BY total_profit DESC;



----Monthly Sales Trend


SELECT 
    DATE_TRUNC('month', order_date) AS month,
    ROUND(SUM(sales), 2) AS monthly_sales
FROM retail_orders_clean
GROUP BY month
ORDER BY month;


---Yearly Sales Trend


SELECT 
    EXTRACT(YEAR FROM order_date) AS year,
    ROUND(SUM(sales), 2) AS yearly_sales
FROM retail_orders_clean
GROUP BY year
ORDER BY year;



----CUSTOMER ANALYTICS

---Top 10 Customers by Revenue



SELECT 
    customer_name,
    ROUND(SUM(sales), 2) AS total_spending
FROM retail_orders_clean
GROUP BY customer_name
ORDER BY total_spending DESC
LIMIT 10;




---Top Customers by Profit


SELECT 
    customer_name,
    ROUND(SUM(profit), 2) AS total_profit
FROM retail_orders_clean
GROUP BY customer_name
ORDER BY total_profit DESC
LIMIT 10;

---Repeat Customers


SELECT 
    customer_id,
    customer_name,
    COUNT(DISTINCT order_id) AS total_orders
FROM retail_orders_clean
GROUP BY customer_id, customer_name
HAVING COUNT(DISTINCT order_id) > 5
ORDER BY total_orders DESC;


---Customer Segment Performance


SELECT 
    segment,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM retail_orders_clean
GROUP BY segment
ORDER BY total_sales DESC;


----Average Customer Order Value


SELECT 
    ROUND(
        SUM(sales) / COUNT(DISTINCT order_id),
        2
    ) AS average_order_value
FROM retail_orders_clean;




---PRODUCT ANALYTICS

---Top Selling Products


SELECT 
    product_name,
    ROUND(SUM(sales), 2) AS total_sales
FROM retail_orders_clean
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 10;


---Most Profitable Products

SELECT 
    product_name,
    ROUND(SUM(profit), 2) AS total_profit
FROM retail_orders_clean
GROUP BY product_name
ORDER BY total_profit DESC
LIMIT 10;


---Loss-Making Products

SELECT 
    product_name,
    ROUND(SUM(profit), 2) AS total_loss
FROM retail_orders_clean
GROUP BY product_name
HAVING SUM(profit) < 0
ORDER BY total_loss;


---Products with Highest Discounts


SELECT 
    product_name,
    ROUND(AVG(discount) * 100, 2) AS avg_discount_percent
FROM retail_orders_clean
GROUP BY product_name
ORDER BY avg_discount_percent DESC
LIMIT 10;


---Product Category Performance

SELECT 
    category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM retail_orders_clean
GROUP BY category
ORDER BY total_sales DESC;

---Sub-Category Performance



---SUPPLY CHAIN ANALYTICS


---Add Delivery Days Column

ALTER TABLE retail_orders_clean
ADD COLUMN delivery_days INT;



---Update Delivery Days


UPDATE retail_orders_clean
SET delivery_days = ship_date - order_date;





---Average Delivery Time


SELECT 
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days
FROM retail_orders_clean;





---Delivery Performance by Region

SELECT 
    region,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days
FROM retail_orders_clean
GROUP BY region
ORDER BY avg_delivery_days DESC;



----Delayed Orders



SELECT 
    order_id,
    customer_name,
    region,
    delivery_days
FROM retail_orders_clean
WHERE delivery_days > 7
ORDER BY delivery_days DESC;



----INVENTORY & DEMAND ANALYTICS

---High Demand Products

SELECT 
    product_name,
    SUM(quantity) AS total_quantity_sold
FROM retail_orders_clean
GROUP BY product_name
ORDER BY total_quantity_sold DESC
LIMIT 10;



----Most Ordered Categories

SELECT 
    category,
    SUM(quantity) AS total_quantity
FROM retail_orders_clean
GROUP BY category
ORDER BY total_quantity DESC;


---Region-wise Product Demand


SELECT 
    region,
    SUM(quantity) AS total_quantity
FROM retail_orders_clean
GROUP BY region
ORDER BY total_quantity DESC;









-----Customer Ranking Using Window Functions


SELECT 
    customer_name,
    ROUND(SUM(sales), 2) AS total_sales,
    RANK() OVER (
        ORDER BY SUM(sales) DESC
    ) AS customer_rank
FROM retail_orders_clean
GROUP BY customer_name;


----Running Monthly Sales


SELECT
    DATE_TRUNC('month', order_date) AS month,
    SUM(sales) AS monthly_sales,
    SUM(SUM(sales)) OVER (
        ORDER BY DATE_TRUNC('month', order_date)
    ) AS running_total_sales
FROM retail_orders_clean
GROUP BY month
ORDER BY month;




----Year-over-Year Growth


SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    ROUND(SUM(sales), 2) AS yearly_sales,
    
    ROUND(
        LAG(SUM(sales)) OVER (
            ORDER BY EXTRACT(YEAR FROM order_date)
        ),
        2
    ) AS previous_year_sales
FROM retail_orders_clean
GROUP BY year
ORDER BY year;





----Top Products in Each Category


SELECT *
FROM (
    SELECT
        category,
        product_name,
        ROUND(SUM(sales), 2) AS total_sales,
        
        RANK() OVER (
            PARTITION BY category
            ORDER BY SUM(sales) DESC
        ) AS rank_in_category
        
    FROM retail_orders_clean
    GROUP BY category, product_name
) ranked_products
WHERE rank_in_category <= 3;






