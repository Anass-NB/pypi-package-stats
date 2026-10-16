-- Weekly download counts (weeks start on Monday).
select
    cast(date_trunc('week', d.date_day) as date) as week,
    sum(f.download_count) as downloads
from main_marts.fct_downloads as f
join main_marts.dim_date as d using (date_key)
group by 1
order by 1
