CREATE TABLE orders (
    row_id              INT,
    order_id            VARCHAR(20),
    order_date          DATE,
    ship_date           DATE,
    ship_mode           VARCHAR(50),
    customer_id         VARCHAR(20),
    customer_name       VARCHAR(100),
    segment             VARCHAR(50),
    country             VARCHAR(50),
    city                VARCHAR(100),
    state               VARCHAR(100),
    postal_code         VARCHAR(10),
    region              VARCHAR(50),
    product_id          VARCHAR(20),
    category            VARCHAR(50),
    sub_category        VARCHAR(50),
    product_name        VARCHAR(200),
    sales               DECIMAL(10,2),
    order_year           INT,
    order_month          INT,
    order_month_name     VARCHAR(10),
    delivery_time_days   INT
);


  SELECT COUNT(*) AS total_rows FROM orders;
  SELECT * FROM orders LIMIT 10;
  SELECT MIN(order_date), MAX(order_date) FROM orders;
  
  
  SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month_label,
    SUM(sales) AS total_sales,
    COUNT(DISTINCT order_id) AS num_orders
FROM orders
GROUP BY order_month_label
ORDER BY order_month_label;


WITH yearly_region_sales AS (
    SELECT
        region,
        order_year,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY region, order_year
)
SELECT
    region,
    order_year,
    total_sales,
    LAG(total_sales) OVER (PARTITION BY region ORDER BY order_year) AS prev_year_sales,
    ROUND(
        (total_sales - LAG(total_sales) OVER (PARTITION BY region ORDER BY order_year))
        / LAG(total_sales) OVER (PARTITION BY region ORDER BY order_year) * 100, 2
    ) AS yoy_growth_pct
FROM yearly_region_sales
ORDER BY region, order_year;


SELECT product_name, total_sales, sales_rank
FROM (
    SELECT
        product_name,
        SUM(sales) AS total_sales,
        RANK() OVER (ORDER BY SUM(sales) DESC) AS sales_rank
    FROM orders
    GROUP BY product_name
) ranked
WHERE sales_rank <= 10;


SELECT
    category,
    sub_category,
    SUM(sales) AS total_sales,
    COUNT(DISTINCT order_id) AS num_orders,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM orders
GROUP BY category, sub_category
ORDER BY category, total_sales DESC;


SELECT
    segment,
    SUM(sales) AS total_sales,
    ROUND(SUM(sales) * 100.0 / (SELECT SUM(sales) FROM orders), 2) AS pct_of_total_sales
FROM orders
GROUP BY segment
ORDER BY total_sales DESC;


SELECT
    region,
    ship_mode,
    ROUND(AVG(delivery_time_days), 2) AS avg_delivery_days
FROM orders
GROUP BY region, ship_mode
ORDER BY region, avg_delivery_days;


SELECT
    customer_id,
    customer_name,
    COUNT(DISTINCT order_id) AS num_orders,
    SUM(sales) AS total_spend,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM orders
GROUP BY customer_id, customer_name
ORDER BY total_spend DESC
LIMIT 10;



SELECT region, state, total_sales, state_rank
FROM (
    SELECT
        region,
        state,
        SUM(sales) AS total_sales,
        RANK() OVER (PARTITION BY region ORDER BY SUM(sales) DESC) AS state_rank
    FROM orders
    GROUP BY region, state
) ranked
WHERE state_rank <= 3
ORDER BY region, state_rank;


SELECT
    ship_mode,
    COUNT(DISTINCT order_id) AS num_orders,
    SUM(sales) AS total_sales,
    ROUND(AVG(sales), 2) AS avg_sales_per_line_item
FROM orders
GROUP BY ship_mode
ORDER BY total_sales DESC;


WITH monthly AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS order_month_label,
        SUM(sales) AS monthly_sales
    FROM orders
    GROUP BY order_month_label
)
SELECT
    order_month_label,
    monthly_sales,
    SUM(monthly_sales) OVER (ORDER BY order_month_label) AS running_total_sales
FROM monthly
ORDER BY order_month_label;



SELECT
    order_month_name,
    order_month,
    SUM(sales) AS total_sales
FROM orders
GROUP BY order_month_name, order_month
ORDER BY order_month;



SELECT
    order_id,
    customer_name,
    region,
    ship_mode,
    delivery_time_days
FROM orders
ORDER BY delivery_time_days DESC
LIMIT 10;