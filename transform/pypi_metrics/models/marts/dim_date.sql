{{
    config(
        materialized='table',
        schema='marts'
    )
}}

/*
Date dimension generated from the min/max of the full event data
(not hardcoded — the sample only covers ~12 minutes, the full table spans more).
One row per calendar date. No Unknown member: downloaded_at is NOT NULL
by staging contract, so fct date_key is never null.
*/

with bounds as (
    select
        min(downloaded_date) as min_date,
        max(downloaded_date) as max_date
    from {{ ref('int_downloads_enriched') }}
),

spine as (
    select unnest(
        range(
            (select min_date from bounds),
            (select max_date from bounds) + interval 1 day,
            interval 1 day
        )
    )::date as date_day
    from bounds
)

select
    cast(strftime(date_day, '%Y%m%d') as integer) as date_key,
    date_day,
    year(date_day) as year,
    quarter(date_day) as quarter,
    month(date_day) as month,
    monthname(date_day) as month_name,
    strftime(date_day, '%Y-%m') as year_month,
    week(date_day) as week,
    dayofweek(date_day) as day_of_week,
    dayname(date_day) as day_name,
    case when dayofweek(date_day) in (0, 6) then true else false end as is_weekend
from spine
