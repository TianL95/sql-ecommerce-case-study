-- =========================================
-- 03 Customer Analysis
-- E-commerce Sales & Customer Analysis
-- =========================================


-- 1. Top 10 customers by total spending
SELECT
    customer_id,
    SUM(quantity * unit_price) AS total_spend
FROM online_retail
WHERE quantity > 0
  AND invoice_no NOT LIKE 'C%'
  AND customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY total_spend DESC
LIMIT 10;


-- 2. Top 10 customers by number of orders
SELECT
    customer_id,
    COUNT(DISTINCT invoice_no) AS total_orders
FROM online_retail
WHERE quantity > 0
  AND invoice_no NOT LIKE 'C%'
  AND customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY total_orders DESC
LIMIT 10;


-- 3. Top 10 customers by average order value (AOV)
SELECT
    customer_id,
    SUM(quantity * unit_price) AS total_spend,
    COUNT(DISTINCT invoice_no) AS total_orders,
    ROUND(
        SUM(quantity * unit_price)
        / COUNT(DISTINCT invoice_no),
        2
    ) AS avg_order_value
FROM online_retail
WHERE quantity > 0
  AND invoice_no NOT LIKE 'C%'
  AND customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY avg_order_value DESC
LIMIT 10;

-- 4. One-time vs repeat customers
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT invoice_no) AS total_orders
    FROM online_retail
    WHERE quantity > 0
      AND invoice_no NOT LIKE 'C%'
      AND customer_id IS NOT NULL
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN total_orders = 1 THEN 'One-time customer'
        ELSE 'Repeat customer'
    END AS customer_type,
    COUNT(*) AS customer_count
FROM customer_orders
GROUP BY customer_type
ORDER BY customer_count DESC;


-- 5. Customer segmentation by order frequency
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT invoice_no) AS total_orders
    FROM online_retail
    WHERE quantity > 0
      AND invoice_no NOT LIKE 'C%'
      AND customer_id IS NOT NULL
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN total_orders = 1 THEN 'One-time'
        WHEN total_orders BETWEEN 2 AND 5 THEN 'Occasional'
        WHEN total_orders BETWEEN 6 AND 20 THEN 'Frequent'
        ELSE 'Very frequent'
    END AS customer_segment,
    COUNT(*) AS customer_count
FROM customer_orders
GROUP BY customer_segment
ORDER BY customer_count DESC;

-- 6. Sales by customer segment
WITH customer_summary AS (
    SELECT
        customer_id,
        COUNT(DISTINCT invoice_no) AS total_orders,
        SUM(quantity * unit_price) AS total_spend
    FROM online_retail
    WHERE quantity > 0
      AND invoice_no NOT LIKE 'C%'
      AND customer_id IS NOT NULL
    GROUP BY customer_id
),
customer_segments AS (
    SELECT
        customer_id,
        total_orders,
        total_spend,
        CASE
            WHEN total_orders = 1 THEN 'One-time'
            WHEN total_orders BETWEEN 2 AND 5 THEN 'Occasional'
            WHEN total_orders BETWEEN 6 AND 20 THEN 'Frequent'
            ELSE 'Very frequent'
        END AS customer_segment
    FROM customer_summary
)
SELECT
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(SUM(total_spend), 2) AS total_sales,
    ROUND(
        SUM(total_spend) * 100.0
        / SUM(SUM(total_spend)) OVER (),
        2
    ) AS sales_share_pct
FROM customer_segments
GROUP BY customer_segment
ORDER BY sales_share_pct DESC;


-- 7. Average spend per customer by segment
WITH customer_summary AS (
    SELECT
        customer_id,
        COUNT(DISTINCT invoice_no) AS total_orders,
        SUM(quantity * unit_price) AS total_spend
    FROM online_retail
    WHERE quantity > 0
      AND invoice_no NOT LIKE 'C%'
      AND customer_id IS NOT NULL
    GROUP BY customer_id
),
customer_segments AS (
    SELECT
        customer_id,
        total_orders,
        total_spend,
        CASE
            WHEN total_orders = 1 THEN 'One-time'
            WHEN total_orders BETWEEN 2 AND 5 THEN 'Occasional'
            WHEN total_orders BETWEEN 6 AND 20 THEN 'Frequent'
            ELSE 'Very frequent'
        END AS customer_segment
    FROM customer_summary
)
SELECT
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(SUM(total_spend), 2) AS total_sales,
    ROUND(
        SUM(total_spend) / COUNT(*),
        2
    ) AS avg_spend_per_customer
FROM customer_segments
GROUP BY customer_segment
ORDER BY avg_spend_per_customer DESC;

-- 8. Customer RFM metrics
WITH customer_rfm AS (
    SELECT
        customer_id,
        DATE '2011-12-09' - MAX(invoice_date)::date AS recency,
        COUNT(DISTINCT invoice_no) AS frequency,
        SUM(quantity * unit_price) AS monetary
    FROM online_retail
    WHERE quantity > 0
      AND invoice_no NOT LIKE 'C%'
      AND customer_id IS NOT NULL
    GROUP BY customer_id
)
SELECT
    customer_id,
    recency,
    frequency,
    ROUND(monetary, 2) AS monetary
FROM customer_rfm
ORDER BY monetary DESC;

-- 9. RFM scoring
WITH customer_rfm AS (
    SELECT
        customer_id,
        DATE '2011-12-09' - MAX(invoice_date)::date AS recency,
        COUNT(DISTINCT invoice_no) AS frequency,
        SUM(quantity * unit_price) AS monetary
    FROM online_retail
    WHERE quantity > 0
      AND invoice_no NOT LIKE 'C%'
      AND customer_id IS NOT NULL
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        recency,
        frequency,
        monetary,

        NTILE(5) OVER (
            ORDER BY recency DESC
        ) AS r_score,

        NTILE(5) OVER (
            ORDER BY frequency ASC
        ) AS f_score,

        NTILE(5) OVER (
            ORDER BY monetary ASC
        ) AS m_score

    FROM customer_rfm
)
SELECT
    customer_id,
    recency,
    frequency,
    ROUND(monetary, 2) AS monetary,
    r_score,
    f_score,
    m_score
FROM rfm_scores
ORDER BY r_score DESC, f_score DESC, m_score DESC;

-- 10. Combined RFM score
WITH customer_rfm AS (
    SELECT
        customer_id,
        DATE '2011-12-09' - MAX(invoice_date)::date AS recency,
        COUNT(DISTINCT invoice_no) AS frequency,
        SUM(quantity * unit_price) AS monetary
    FROM online_retail
    WHERE quantity > 0
      AND invoice_no NOT LIKE 'C%'
      AND customer_id IS NOT NULL
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        recency,
        frequency,
        monetary,

        NTILE(5) OVER (
            ORDER BY recency DESC
        ) AS r_score,

        NTILE(5) OVER (
            ORDER BY frequency ASC
        ) AS f_score,

        NTILE(5) OVER (
            ORDER BY monetary ASC
        ) AS m_score

    FROM customer_rfm
)
SELECT
    customer_id,
    recency,
    frequency,
    ROUND(monetary, 2) AS monetary,
    r_score,
    f_score,
    m_score,
    CONCAT(r_score, f_score, m_score) AS rfm_score
FROM rfm_scores
ORDER BY rfm_score DESC;

-- 11. RFM customer segmentation
WITH customer_rfm AS (
    SELECT
        customer_id,
        DATE '2011-12-09' - MAX(invoice_date)::date AS recency,
        COUNT(DISTINCT invoice_no) AS frequency,
        SUM(quantity * unit_price) AS monetary
    FROM online_retail
    WHERE quantity > 0
      AND invoice_no NOT LIKE 'C%'
      AND customer_id IS NOT NULL
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        monetary,

        NTILE(5) OVER (
            ORDER BY recency DESC
        ) AS r_score,

        NTILE(5) OVER (
            ORDER BY frequency ASC
        ) AS f_score,

        NTILE(5) OVER (
            ORDER BY monetary ASC
        ) AS m_score

    FROM customer_rfm
),
customer_segments AS (
    SELECT
        customer_id,
        monetary,
        r_score,
        f_score,
        m_score,

        CASE
            WHEN r_score >= 4
             AND f_score >= 4
             AND m_score >= 4
                THEN 'High Value'

            WHEN r_score >= 4
             AND (f_score < 4 OR m_score < 4)
                THEN 'Recent'

            WHEN r_score < 4
             AND f_score >= 4
             AND m_score >= 4
                THEN 'Previously Valuable'

            ELSE 'Low Engagement'
        END AS customer_segment

    FROM rfm_scores
)
SELECT
    customer_segment,
    COUNT(*) AS customer_count
FROM customer_segments
GROUP BY customer_segment
ORDER BY customer_count DESC;
