-- Monthly download counts.
select
    cast(date_trunc('month', d.date_day) as date) as month,
    sum(f.download_count) as downloads
from main_marts.fct_downloads as f
join main_marts.dim_date as d using (date_key)
group by 1
order by 1
