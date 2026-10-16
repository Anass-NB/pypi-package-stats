-- Monthly downloads by installer traffic class
-- (interactive / ci / mirror / scripted / automated / unknown).
select
    cast(date_trunc('month', d.date_day) as date) as month,
    i.traffic_type,
    sum(f.download_count) as downloads
from main_marts.fct_downloads as f
join main_marts.dim_date as d using (date_key)
join main_marts.dim_installer as i using (installer_key)
group by 1, 2
order by 1, 2
