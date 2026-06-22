create database stock_analysis;
use stock_analysis;

create table stock_prices(
	id int auto_increment primary key,
    date date not null,
    open decimal(10,4),
    high decimal(10,4),
    low decimal(10,4),
    close decimal(10,4),
    volume bigint,
    ticker varchar(40)
    );
    
desc stock_prices;

show variables like 'secure_file_priv';

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/all_stocks.csv'
into table stock_prices
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(date,open,high,low,close,volume,ticker);