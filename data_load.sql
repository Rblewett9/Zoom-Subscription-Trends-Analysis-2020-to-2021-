use database analytics_accelerator;

--create stages for tables
create or replace temp stage finance.exchange_rates;
create or replace temp stage finance.daily_subs;
create or replace temp stage finance.daily_subs_2;
create or replace temp stage finance.geo_lookup;

--create table fields
create or replace table finance.exchange_rates (record_date VARCHAR, country VARCHAR, currency VARCHAR, currency_detail VARCHAR, rate VARCHAR, year VARCHAR, month VARCHAR, day VARCHAR);
create or replace table finance.daily_subs (user INTEGER, sub VARCHAR, sub_period VARCHAR, sub_start_ts VARCHAR, sub_end_ts TIMESTAMP, price VARCHAR, price_usd VARCHAR, currency VARCHAR, country_code VARCHAR);
create or replace table finance.daily_subs_2 (user INTEGER, sub VARCHAR, sub_period VARCHAR, sub_start_ts VARCHAR, sub_end_ts TIMESTAMP, price VARCHAR, price_usd VARCHAR, currency VARCHAR, country_code VARCHAR);
create or replace table finance.geo_lookup (continent VARCHAR, full_country_name VARCHAR, continent_iso VARCHAR, country_iso VARCHAR, region VARCHAR, region_detail VARCHAR);

--load files into stages
put file:///Users/Lingyi/Documents/exchange_rates.csv @finance.exchange_rates auto_compress=false;
put file:///Users/Lingyi/Documents/geo_lookup.csv @finance.geo_lookup auto_compress=false;
put file:///Users/Lingyig/Documents/0_Analytics_Accelerator/daily_subs.csv @finance.daily_subs auto_compress=false;
put file:///Users/Lingyi/Documents/0_Analytics_Accelerator/daily_subs_2.csv @finance.daily_subs_2 auto_compress=false;

--copy data from stages to tables
copy into finance.exchange_rates
from @finance.exchange_rates/exchange_rates.csv
file_format = (type = csv, skip_header=1)
on_error = CONTINUE;

copy into finance.geo_lookup
from @finance.geo_lookup/geo_lookup.csv
file_format = (type = csv, skip_header=1)
on_error = CONTINUE;

copy into finance.daily_subs
from @finance.daily_subs/daily_subs.csv
file_format = (type = csv, skip_header=1);

copy into finance.daily_subs_2
from @finance.daily_subs/daily_subs_2.csv
file_format = (type = csv, skip_header=1);


--check table outputs
select * from finance.exchange_rates;
select * from finance.geo_lookup;
select * from finance.daily_subs;
select * from finance.daily_subs_2;
