-- 1. Stock Summary Statistics
--    Ranks stocks by price level and trading activity
select 
	ticker,
	round(avg(close),2) as avg_close,
	round(max(close),2) as highest_close,
	round(max(close),2) as lowest_close,
	round(avg(volume),0) as avg_volume
from stock_prices
group by ticker
order by avg_close desc;
        
-- 2. 20-Day Moving Average per Stock
-- 	  Identifies whether a stock is in an uptrend or downtrend based on price vs MA

select 
	date,
	ticker,
	close,
	round(avg(close) over ( partition by ticker
	order by date
	rows between 19 preceding and current row),2) as moving_avg_20
from stock_prices
order by ticker, date;

-- 3. Daily Percentage Return
--    Identifies the most volatile single day moves and confirms overall trend direction

select 
	date,
	ticker,
	close,
	lag(close) over (partition by ticker order by date) as prev_close,
	round(((close - lag(close) over ( partition by ticker order by date)) /
		lag(close) over ( partition by ticker order by date)) * 100,2) as daily_return_pct
from stock_prices
order by ticker, date;

-- 4. Top 5 Biggest Single-Day Gains
--    Highlights days with unusual positive volatility

with daily_returns as (
	select
		date,
		ticker,
		close,
		round(((close - lag(close) over (partition by ticker order by date)) /
			lag(close) over (partition by ticker order by date)) * 100,2) as daily_return_pct
	from stock_prices
    )
select * from daily_returns
where daily_return_pct is not null
order by daily_return_pct desc
limit 5;

-- 5. Top 5 Biggest Single-Day Drops
--    Pairs with the gains query to show full volatility picture for each stock
                    
 with daily_returns as (
	select 
		date,
		ticker,
		close,
		round(((close - lag(close) over (partition by ticker order by date)) /
			lag(close) over (partition by ticker order by date)) * 100,2) as daily_return_pct
	from stock_prices
)
select * from daily_returns
where daily_return_pct is not null
order by daily_return_pct asc
limit 5;

-- 6. Stock Ranking by Average Daily Range
-- 	  Identifies which stocks are riskiest and most volatile in absolute price terms

select 
	ticker,
	round(avg(high - low),2) as avg_daily_range,
	rank() over (order by avg(high - low) desc) as volatility_rank
from stock_prices
group by ticker;

-- 7. Monthly Average Closing Price per Stock
--    Reveals whether decline / growth was steady or concentrated in specific months

select
	ticker,
    date_format(date, '%Y-%m') as month,
    round(avg(close), 2) as avg_close
from stock_prices
group by ticker, month
order by ticker, month;

-- 8. Indian vs US Market Comparison
--    Group stocks by market and compare average returns and volatility
select
	case
		when ticker in ('AAPL','MSFT') then 'US'
        else 'India'
	end as market,
    round(avg(close), 2) as avg_close,
    round(avg(high - low),2) as avg_daily_range
from stock_prices
group by market;

-- 9. Stock Summary
--    Usage : call get_stock_summary('TCS');

delimiter //
create procedure get_stock_summary(in ticker_name varchar(20))
begin
	select
		ticker,
        round(avg(close),2) as avg_close,
        round(max(close),2) as highest_close,
        round(min(close),2) as lowest_close,
        round(avg(volume),0) as avg_volume
	from stock_prices
    where ticker=ticker_name
    group by ticker;
end //
delimiter ;

call get_stock_summary('ICICIBANK');

-- 10. stock_performance_summary
create view stock_performance_summary as
select
	ticker,
    round(avg(close),2) as avg_close,
    round(avg(high-low),2) as avg_daily_range,
    round(avg(volume),0) as avg_volume
from stock_prices
group by ticker;

select * from stock_performance_summary
order by avg_close desc;



