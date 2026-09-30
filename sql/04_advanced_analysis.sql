-- =========================================
-- 04 Advanced Analysis
-- E-commerce Sales & Customer Analysis
-- =========================================


-- 1. Top 10 products by sales
SELECT
    stock_code,
    description,
    SUM(quantity * unit_price) AS total_sales
FROM online_retail
WHERE quantity > 0
  AND invoice_no NOT LIKE 'C%'
  AND stock_code NOT IN ('DOT', 'POST', 'M')
GROUP BY stock_code, description
ORDER BY total_sales DESC
LIMIT 10;


-- 2. Top 10 products by quantity sold
SELECT
    stock_code,
    description,
    SUM(quantity) AS total_quantity
FROM online_retail
WHERE quantity > 0
  AND invoice_no NOT LIKE 'C%'
  AND stock_code NOT IN ('DOT', 'POST', 'M')
GROUP BY stock_code, description
ORDER BY total_quantity DESC
LIMIT 10;


-- 3. Top 10 products by sales with quantity
--    and average unit price
SELECT
    stock_code,
    description,
    SUM(quantity) AS total_quantity,
    SUM(quantity * unit_price) AS total_sales,
    ROUND(
        SUM(quantity * unit_price)
        / SUM(quantity),
        2
    ) AS avg_unit_price
FROM online_retail
WHERE quantity > 0
  AND invoice_no NOT LIKE 'C%'
  AND stock_code NOT IN ('DOT', 'POST', 'M')
GROUP BY stock_code, description
ORDER BY total_sales DESC
LIMIT 10;

-- 4. Product cancellation rate
WITH product_sales AS (
    SELECT
        stock_code,
        description,
        SUM(quantity) AS sold_quantity
    FROM online_retail
    WHERE quantity > 0
      AND invoice_no NOT LIKE 'C%'
      AND stock_code NOT IN (
          'DOT',
          'POST',
          'M',
          'AMAZONFEE',
          'CRUK',
          'BANK CHARGES',
          'D',
          'S',
          'SAMPLES'
      )
    GROUP BY stock_code, description
),
product_cancellations AS (
    SELECT
        stock_code,
        description,
        SUM(ABS(quantity)) AS cancelled_quantity
    FROM online_retail
    WHERE quantity < 0
      AND invoice_no LIKE 'C%'
      AND stock_code NOT IN (
          'DOT',
          'POST',
          'M',
          'AMAZONFEE',
          'CRUK',
          'BANK CHARGES',
          'D',
          'S',
          'SAMPLES'
      )
    GROUP BY stock_code, description
)
SELECT
    s.stock_code,
    s.description,
    s.sold_quantity,
    COALESCE(c.cancelled_quantity, 0) AS cancelled_quantity,
    ROUND(
        COALESCE(c.cancelled_quantity, 0) * 100.0
        / s.sold_quantity,
        2
    ) AS cancellation_rate_pct
FROM product_sales s
LEFT JOIN product_cancellations c
    ON s.stock_code = c.stock_code
   AND s.description = c.description
WHERE s.sold_quantity >= 100
ORDER BY cancellation_rate_pct DESC
LIMIT 10;

-- 5. Top 10 products by cancellation amount
SELECT
    stock_code,
    description,
    SUM(ABS(quantity)) AS cancelled_quantity,
    ROUND(
        SUM(ABS(quantity) * unit_price),
        2
    ) AS cancelled_amount
FROM online_retail
WHERE quantity < 0
  AND invoice_no LIKE 'C%'
  AND stock_code NOT IN (
      'DOT',
      'POST',
      'M',
      'AMAZONFEE',
      'CRUK',
      'BANK CHARGES',
      'D',
      'S',
      'SAMPLES'
  )
GROUP BY stock_code, description
ORDER BY cancelled_amount DESC
LIMIT 10;

-- 6. Investigate unusually large cancellation transactions
SELECT
    invoice_no,
    stock_code,
    description,
    quantity,
    invoice_date,
    unit_price,
    customer_id,
    country
FROM online_retail
WHERE quantity < 0
  AND invoice_no LIKE 'C%'
  AND stock_code = '23843'
ORDER BY ABS(quantity) DESC;
