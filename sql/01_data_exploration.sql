-- =========================================
-- 01 Data Exploration
-- E-commerce Sales & Customer Analysis
-- =========================================

-- 1. Total number of records
SELECT
    COUNT(*) AS total_rows
FROM online_retail;

-- 2. Number of unique customers
SELECT
    COUNT(DISTINCT customer_id) AS unique_customers
FROM online_retail;

-- 3. Missing customer IDs
SELECT
    COUNT(*) AS missing_customer_id
FROM online_retail
WHERE customer_id IS NULL;

-- 4. Check transaction structure
SELECT
    COUNT(*) AS total_transactions,
    COUNT(*) FILTER (
        WHERE invoice_no LIKE 'C%'
    ) AS cancelled_transactions,
    COUNT(*) FILTER (
        WHERE quantity > 0
          AND invoice_no NOT LIKE 'C%'
    ) AS sales_transactions,
    COUNT(*) FILTER (
        WHERE quantity < 0
          AND invoice_no NOT LIKE 'C%'
    ) AS other_negative_transactions
FROM online_retail;

-- 5. Check negative-quantity transactions
SELECT
    COUNT(*) AS negative_quantity_records
FROM online_retail
WHERE quantity < 0;

-- 6. Check cancelled invoices
SELECT
    COUNT(*) AS cancelled_by_invoice
FROM online_retail
WHERE invoice_no LIKE 'C%';
