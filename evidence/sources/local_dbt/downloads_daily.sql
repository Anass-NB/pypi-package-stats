-- Daily download counts (full history; single project: ingestr).
-- Small (~960 rows), so the published site can filter it client-side.
select
    d.date_day,
    sum(f.download_count) as downloads
from main_marts.fct_downloads as f
join main_marts.dim_date as d using (date_key)
group by 1
order by 1
