-- Per-version totals with first/last seen and the prerelease flag.
select
    v.project_version,
    v.version_sort_key,
    v.is_prerelease,
    sum(f.download_count) as downloads,
    min(d.date_day) as first_seen,
    max(d.date_day) as last_seen
from main_marts.fct_downloads as f
join main_marts.dim_date as d using (date_key)
join main_marts.dim_project_version as v using (version_key)
group by 1, 2, 3
order by downloads desc
