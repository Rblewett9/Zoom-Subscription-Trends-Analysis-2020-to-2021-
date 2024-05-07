--STEP 1: INVESTIGATE INPUT TABLES USING SELECT *
--STEP 2: CLEAN UP DATA AND CREATE SUPPLEMENTARY COLUMNS
--STEP 3: JOIN TABLES TOGETHER TO CREATE MORE ROBUST DATASET
--STEP 4: COMBINE TEMP TABLES TO CTEs

--STEP 1
select * from finance.daily_subs;


--STEP 2: add date columns, supplementary subscription name
create or replace temp table finance.daily_subs_clean as (
    select sub_start_ts::date as sub_start_date,
        date_trunc('week',sub_start_ts::date) as sub_start_week,
        date_trunc('month',sub_start_ts::date) as sub_start_month,
        date_trunc('quarter',sub_start_ts::date) as sub_start_quarter,
        date_trunc('year',sub_start_ts::date) as sub_start_year,
        user,
        sub,
        sub_period,
        concat(sub, ' ', sub_period) as full_sub_name,
        price as local_price,
        price_usd,
        currency,
        country_code
    from finance.daily_subs
);

select * from finance.daily_subs_clean;

--STEP 3: add geographic region data, convert to USD
create or replace temp table finance.daily_subs_clean_country as (
    select *
    from finance.daily_subs_clean
    left join finance.geo_lookup
    on lower(daily_subs_clean.country_code) = lower(geo_lookup.country_iso)
);

select * from finance.daily_subs_clean_country limit 10;

--join daily subs clean table to exchange rates to get usd price
create or replace temp table finance.daily_subs_country_rates as (
    select daily_subs_clean_country.*,
        --error on current line
        case when daily_subs_clean_country.currency = 'USD' then local_price else local_price*rate end as price_usd_calc
    from finance.daily_subs_clean_country
    left join finance.exchange_rates
        on lower(daily_subs_clean_country.currency) = lower(exchange_rates.currency)
        and daily_subs_clean_country.sub_start_month = exchange_rates.date);

select * from finance.daily_subs_country_rates;

--INTERMEDIATE SQL (BONUS POINTS): COMBINE ALL CALCULATIONS INTO ONE QUERY USING CTEs
--create a script using CTEs to do all calculations in one query
with daily_subs_clean as (
    select sub_start_ts::date as sub_start_date,
        date_trunc('week',sub_start_ts::date) as sub_start_week,
        date_trunc('month',sub_start_ts::date) as sub_start_month,
        date_trunc('quarter',sub_start_ts::date) as sub_start_quarter,
        date_trunc('year',sub_start_ts::date) as sub_start_year,
        user,
        sub,
        sub_period,
        concat(sub, ' ', sub_period) as full_sub_name,
        price as local_price,
        price_usd,
        currency,
        country_code
    from finance.daily_subs
),

daily_subs_clean_country as (
    select *
    from finance.daily_subs_clean
    left join finance.geo_lookup
    on lower(daily_subs_clean.country_code) = lower(geo_lookup.country_iso)
),

daily_subs_country_rates as (
    select daily_subs_clean_country.*,
        --error on current line
        case when daily_subs_clean_country.currency = 'USD' then local_price else local_price*rate end as price_usd_calc
    from finance.daily_subs_clean_country
    left join finance.exchange_rates
        on lower(daily_subs_clean_country.currency) = lower(exchange_rates.currency)
        and daily_subs_clean_country.sub_start_month = exchange_rates.date)

select * from daily_subs_country_rates;