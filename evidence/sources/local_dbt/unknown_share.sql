-- Share of downloads with an unresolved value per dimension, for the
-- data-quality note on the Overview page. 'Unknown' here means the raw event
-- did not carry the field (it is not an ingestion error).
select
    'Runtime Python' as dimension,
    round(100.0 * sum(case when p.python_major_minor = 'Unknown' then f.download_count else 0 end) / max(t.total), 1) as unknown_pct
from main_marts.fct_downloads as f
join main_marts.dim_python as p using (python_key)
cross join (select sum(download_count) as total from main_marts.fct_downloads) as t
union all
select
    'Installer',
    round(100.0 * sum(case when i.traffic_type = 'unknown' then f.download_count else 0 end) / max(t.total), 1)
from main_marts.fct_downloads as f
join main_marts.dim_installer as i using (installer_key)
cross join (select sum(download_count) as total from main_marts.fct_downloads) as t
union all
select
    'Country',
    round(100.0 * sum(case when c.country_name = 'Unknown' then f.download_count else 0 end) / max(t.total), 1)
from main_marts.fct_downloads as f
join main_marts.dim_country as c using (country_key)
cross join (select sum(download_count) as total from main_marts.fct_downloads) as t
union all
select
    'Platform',
    round(100.0 * sum(case when p.os_family = 'Unknown' then f.download_count else 0 end) / max(t.total), 1)
from main_marts.fct_downloads as f
join main_marts.dim_platform as p using (platform_key)
cross join (select sum(download_count) as total from main_marts.fct_downloads) as t
union all
select
    'Version',
    round(100.0 * sum(case when v.project_version = 'Unknown' then f.download_count else 0 end) / max(t.total), 1)
from main_marts.fct_downloads as f
join main_marts.dim_project_version as v using (version_key)
cross join (select sum(download_count) as total from main_marts.fct_downloads) as t
order by unknown_pct desc
