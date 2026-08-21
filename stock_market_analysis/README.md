# Stock Market Analysis (India vs US) - SQL

> Picks up from the data collection and EDA here: [python-projects/stock_market_analysis](https://github.com/tharunsajeev/python-projects/tree/main/stock_market_analysis)

## What this is

This is the SQL half of the stock market project same dataset, different angle. The Python side covers collecting the data from the Alpha Vantage API and doing the first pass of exploration with pandas. Here I loaded that same data into MySQL and wrote a set of queries to dig into it more analytically, using a lot of the same techniques from my Olist project :- window functions, CTEs, ranking applied to a different kind of dataset this time.

## The data

800 rows, 7 columns :- `date`, `open`, `high`, `low`, `close`, `volume`, `ticker` covering 100 trading days for 6 Indian stocks (RELIANCE, TCS, INFY, HDFCBANK, WIPRO, ICICIBANK) and 2 US stocks (AAPL, MSFT), Jan to Jun 2026.

## What's in the queries

- summary stats per stock :- average, highest, lowest close, average volume
- a 20-day moving average calculated directly in SQL with `AVG() OVER (PARTITION BY ... ROWS BETWEEN ...)`, instead of the `.rolling()` version I'd already done in pandas
- daily percentage return using `LAG()` to compare each row to the day before it
- the 5 biggest single-day gains and the 5 biggest single-day drops, using a CTE to get around the fact that you can't filter directly on a window function result
- a volatility ranking across all 8 stocks using `RANK()`
- month-by-month average close using `DATE_FORMAT()`
- a quick India vs US comparison using `CASE WHEN`
- a stored procedure to pull up summary stats for any one ticker on demand
- a view that bundles the return and volatility numbers together so I'm not rewriting the same aggregation query every time

## What I found

TCS came out as the most volatile stock by average daily price range, and WIPRO the least which lines up with what the Python EDA found independently, so it was a nice sanity check that both approaches agree. Grouping by market also confirmed the broader pattern from the Python side: the Indian stocks had a lower average close and a wider average daily range than the two US stocks over this stretch, and the monthly breakdown showed the IT stock decline wasn't one sharp drop but a slow slide across most of the months.

## Tools

MySQL 8.0, MySQL Workbench

## A few things that tripped me up

- `LOAD DATA INFILE` kept failing with a `secure_file_priv` error turns out MySQL only allows file imports from one specific folder, which I had to look up with `SHOW VARIABLES LIKE 'secure_file_priv'` before the load would work
- I originally set prices as `DECIMAL(10,2)`, which quietly truncated any value with more than 2 decimal places some of the source data had 4. Switched to `DECIMAL(10,4)` to keep the original precision and just round when displaying instead
- Couldn't filter or sort directly on a window function's output in the same query had to calculate it inside a CTE first, then filter in the outer query

## How to run

Create the table, load `all_stocks.csv` from the Python repo using `LOAD DATA INFILE`, then run through `stock_analysis_queries.sql`.

---

[Tharun Sajeev](https://github.com/tharunsajeev)

Aspiring Data Analyst
