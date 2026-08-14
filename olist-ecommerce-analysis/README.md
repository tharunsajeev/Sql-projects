# E-Commerce Sales Analysis — SQL Portfolio Project

A end-to-end SQL project analysing 100,000+ real orders from a Brazilian e-commerce platform.  
Built to demonstrate data analyst SQL skills across joins, aggregations, CTEs, window functions, subqueries, indexing, and stored procedures.

---

## Project Structure

```
olist-ecommerce-sql/
│
├── olist_db_setup.sql           # Schema design, table creation, data import & cleaning
├── olist_ecommerce_analysis.sql # 25 business analysis queries
└── README.md
```

---

## Dataset

**Source:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — Kaggle  
**Size:** 100,000+ orders across 8 relational tables  
**Period:** 2016 – 2018

### Schema

```
customers ──── orders ──── order_items ──── products ──── categories
                  │
                  ├──── order_payments
                  │
                  └──── order_reviews
                             │
                         order_items ──── sellers
```

| Table | Rows | Description |
|---|---|---|
| orders | 99,441 | Order status and timestamps |
| customers | 99,441 | Customer location and ID |
| order_items | 112,650 | Products, sellers, prices per order |
| products | 32,951 | Product dimensions and category |
| categories | 71 | Portuguese to English category translation |
| order_payments | 103,886 | Payment type and value |
| order_reviews | 99,224 | Review scores and comments |
| sellers | 3,095 | Seller location |

---

## Business Questions Answered

### Revenue Analysis
| # | Question | Skills |
|---|---|---|
| 1 | Total revenue per product category | Joins, Aggregation |
| 2 | Total orders placed per month | Date functions |
| 3 | Top 10 sellers by revenue | Aggregation |
| 4 | Average order value by payment type | Aggregation |

### Customer & Review Analysis
| # | Question | Skills |
|---|---|---|
| 5 | Average review score per category — lowest rated | Joins, Aggregation |
| 6 | How many customers placed more than one order? | Subquery, Aggregation |

### Delivery Analysis
| # | Question | Skills |
|---|---|---|
| 7 | Late deliveries and their % of total orders | Subquery |
| 8 | Top 10 most frequently ordered products | Joins, Aggregation |
| 9 | Customers spending above average lifetime value | Nested subqueries |
| 10 | Top 5 Brazilian states by revenue | Joins, Aggregation |
| 11 | Monthly cancellation rate | Subquery, JOIN |
| 12 | Average delivery days per product category | DATEDIFF, Joins |

### CTE-Based Analysis
| # | Question | Skills |
|---|---|---|
| 13 | 3-month rolling average of monthly revenue | CTE, Window function |
| 14 | Top product category per state | CTE, RANK() |
| 15 | Month-over-month revenue growth % | CTE, LAG() |
| 16 | Customer segmentation into high/mid/low tiers | CTE, CASE WHEN |

### Window Function Analysis
| # | Question | Skills |
|---|---|---|
| 17 | Top seller per category by revenue | RANK(), CTE |
| 18 | Month with the biggest revenue drop | LAG() |
| 19 | Months with consistently declining order volume | LEAD() |
| 20 | Running total — when did revenue cross 10M? | SUM() OVER() |
| 21 | Top 20 customers by total spend | DENSE_RANK() |
| 22 | Best selling month per seller | ROW_NUMBER() |

### Performance & Reporting
| # | Question | Skills |
|---|---|---|
| 23 | Index creation and EXPLAIN analysis | Indexing, EXPLAIN |
| 24 | Complete monthly business report | CTE, Window functions |
| 25 | Stored procedure for monthly report | Stored Procedure |

---

## SQL Skills Demonstrated

| Skill | Used In |
|---|---|
| **Joins** (INNER, multi-table) | Q1, Q5, Q7, Q8, Q9, Q10, Q12, Q14 |
| **Aggregation** (SUM, COUNT, AVG, ROUND) | Q1–Q6, Q10–Q12 |
| **Subqueries** (nested, correlated) | Q6, Q7, Q8, Q9, Q11 |
| **CTEs** (single and chained) | Q13, Q14, Q15, Q16, Q17, Q18, Q21 |
| **Window Functions** | Q13, Q14, Q15, Q17, Q18, Q19, Q20, Q21, Q22, Q24 |
| **RANK / DENSE_RANK / ROW_NUMBER** | Q17, Q21, Q22 |
| **LAG / LEAD** | Q15, Q18, Q19 |
| **Date Functions** (DATEDIFF, DATE_FORMAT, EXTRACT) | Q2, Q7, Q12, Q13 |
| **CASE WHEN** | Q16 |
| **Indexing + EXPLAIN** | Q23 |
| **Stored Procedures** | Q25 |

---

## Setup Instructions

### Requirements
- MySQL 8.0
- MySQL Workbench 8.0 CE
- [Olist dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) downloaded from Kaggle

### Steps

**1. Create the database**
```sql
CREATE DATABASE olist;
USE olist;
```

**2. Run the setup file**

Open `olist_db_setup.sql` in MySQL Workbench and run it. This will:
- Create all 8 tables with correct data types
- Load data from CSV files using `LOAD DATA INFILE`
- Handle NULL values and data quality issues in orders, products, and reviews tables

> **Note:** Update the CSV file paths in `olist_db_setup.sql` to match your local `secure_file_priv` directory.  
> Run `SHOW VARIABLES LIKE 'secure_file_priv';` to find your path.

**3. Run the analysis file**

Open `olist_ecommerce_analysis.sql` and run queries individually or all at once.

---

## Key Findings

- **Health & Beauty** is the highest revenue-generating category
- Around **7–8%** of delivered orders arrive after the estimated delivery date
- Cumulative revenue crossed **10 million** by mid-2017
- Repeat customers account for a small but high-value segment of the customer base
- **Credit card** is the dominant payment method by both volume and value
- Indexing foreign key columns reduced rows scanned from **~100k to 1** on join-heavy queries

---

## Tools Used

- **MySQL 8.0** — query engine
- **MySQL Workbench 8.0 CE** — IDE
- **Python (pandas)** — CSV data cleaning before import
- **Kaggle** — dataset source

---

##  Author

**Tharun Sajeev**  
**Aspiring Data Analyst**
