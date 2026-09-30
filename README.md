# E-commerce Sales & Customer Analysis

## Overview

A SQL-based analysis of an online retail dataset to identify sales trends, customer purchasing patterns, product performance, and transaction anomalies.

**Tools:** PostgreSQL · pgAdmin · SQL

## Business Questions

* How are sales distributed across countries and time?
* What are the purchasing patterns of customers?
* Which customer segments contribute most to sales?
* Which products generate the highest sales?
* Are there unusual cancellation patterns?

## SQL Analysis

The project uses four SQL scripts:

* **Data Exploration** — data quality, missing values, and transaction structure
* **Sales Analysis** — total sales, country performance, monthly trends, and MoM growth
* **Customer Analysis** — customer spending, AOV, repeat behavior, segmentation, and RFM analysis
* **Advanced Analysis** — product performance, cancellation rates, cancellation amounts, and anomaly investigation

### SQL Skills Demonstrated

`SELECT` · `WHERE` · `GROUP BY` · `ORDER BY` · `JOIN` · `CASE WHEN` · `CTE` · Aggregate Functions · Window Functions · `LAG()` · `NTILE()`

## Key Findings

* Total sales were approximately **£10.64M** based on positive-quantity, non-cancelled transactions.
* The **UK accounted for 84.58%** of total sales.
* **Repeat customers represented 65.57%** of qualifying customers.
* Frequent and very frequent customers represented **20.10% of customers but contributed 66.27% of sales**.
* The project-defined **High Value RFM segment represented 22.08% of customers and contributed 64.60% of sales**.
* An unusually large cancellation transaction of **80,995 units** was identified for *PAPER CRAFT, LITTLE BIRDIE* and flagged for further investigation.

## Business Recommendations

* Develop targeted retention strategies for high-value customers.
* Encourage one-time customers to make repeat purchases.
* Monitor the business's high dependence on the UK market.
* Investigate unusually large cancellation transactions.
* Monitor customer segments that contribute a high proportion of sales.

## Project Structure

```text
sql-ecommerce-case-study/
├── README.md
└── sql/
    ├── 01_data_exploration.sql
    ├── 02_sales_analysis.sql
    ├── 03_customer_analysis.sql
    └── 04_advanced_analysis.sql
```

## Dataset

Online Retail transactional dataset containing **541,909 records** from December 2010 to December 2011.
