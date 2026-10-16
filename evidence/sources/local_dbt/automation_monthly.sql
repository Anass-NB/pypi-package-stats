-- Monthly automated vs total downloads (automated = ci + mirror + scripted +
-- explicitly tagged automated installers). Share is computed on the page.
select
    cast(date_trunc('month', d.date_day) as date) as month,
    sum(case when coalesce(i.is_automated_traffic, false)
             then f.download_count else 0 end) as automated_downloads,
    sum(f.download_count) as downloads
from main_marts.fct_downloads as f
join main_marts.dim_date as d using (date_key)
join main_marts.dim_installer as i using (installer_key)
group by 1
order by 1
