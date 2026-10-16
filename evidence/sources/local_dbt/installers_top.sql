-- Top installer name/version combinations with their traffic class.
select
    i.installer_name,
    i.installer_version,
    i.traffic_type,
    sum(f.download_count) as downloads
from main_marts.fct_downloads as f
join main_marts.dim_installer as i using (installer_key)
group by 1, 2, 3
order by downloads desc
limit 50
