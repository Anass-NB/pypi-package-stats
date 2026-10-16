-- Full runtime Python versions with first/last seen dates.
select
    p.python_version_full,
    p.python_major_minor,
    p.python_implementation,
    sum(f.download_count) as downloads,
    min(d.date_day) as first_seen,
    max(d.date_day) as last_seen
from main_marts.fct_downloads as f
join main_marts.dim_date as d using (date_key)
join main_marts.dim_python as p using (python_key)
group by 1, 2, 3
order by downloads desc
