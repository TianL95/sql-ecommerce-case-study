-- =========================================
-- 02 Sales Analysis
-- E-commerce Sales & Customer Analysis
-- =========================================


-- 1. Total sales
SELECT
    SUM(quantity * unit_price) AS total_sales
FROM online_retail
WHERE quantity > 0
  AND invoice_no NOT LIKE 'C%';


-- 2. Sales by country
SELECT
    country,
    SUM(quantity * unit_price) AS total_sales
FROM online_retail
WHERE quantity > 0
  AND invoice_no NOT LIKE 'C%'
GROUP BY country
ORDER BY total_sales DESC;


-- 3. Top 10 countries by sales
SELECT
    country,
    SUM(quantity * unit_price) AS total_sales
FROM online_retail
WHERE quantity > 0
  AND invoice_no NOT LIKE 'C%'
GROUP BY country
ORDER BY total_sales DESC
LIMIT 10;


-- 4. Sales share by country
SELECT
    country,
    ROUND(
        SUM(quantity * unit_price)
        / SUM(SUM(quantity * unit_price)) OVER () * 100,
        2
    ) AS sales_share_pct
FROM online_retail
WHERE quantity > 0
  AND invoice_no NOT LIKE 'C%'
GROUP BY country
ORDER BY sales_share_pct DESC
LIMIT 10;

-- 5. Monthly sales
SELECT
    DATE_TRUNC('month', invoice_date) AS month,
    SUM(quantity * unit_price) AS monthly_sales
FROM online_retail
WHERE quantity > 0
  AND invoice_no NOT LIKE 'C%'
GROUP BY month
ORDER BY month;

-- 6. Month-over-month sales growth
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', invoice_date) AS month,
        SUM(quantity * unit_price) AS monthly_sales
    FROM online_retail
    WHERE quantity > 0
      AND invoice_no NOT LIKE 'C%'
    GROUP BY month
)
SELECT
    month,
    monthly_sales,
    LAG(monthly_sales) OVER (
        ORDER BY month
    ) AS previous_month_sales,
    ROUND(
        (
            monthly_sales
            - LAG(monthly_sales) OVER (ORDER BY month)
        )
        / LAG(monthly_sales) OVER (ORDER BY month)
        * 100,
        2
    ) AS mom_growth_pct
FROM monthly_sales
ORDER BY month;
