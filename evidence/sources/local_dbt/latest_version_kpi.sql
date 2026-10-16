-- Newest published version and its share of the most recent 30 days of
-- traffic (anchored to max(downloaded_at), not CURRENT_DATE).
with bounds as (
    select max(downloaded_at) as last_event_at
    from main_marts.fct_downloads
),
latest as (
    select
        version_key,
        project_version
    from main_marts.dim_project_version
    where project_version <> 'Unknown'
    order by version_sort_key desc
    limit 1
)
select
    l.project_version as latest_version,
    sum(case when f.version_key = l.version_key then f.download_count else 0 end) as latest_downloads_30d,
    sum(f.download_count) as total_downloads_30d
from main_marts.fct_downloads as f
cross join bounds as b
cross join latest as l
where f.downloaded_at > b.last_event_at - interval 30 day
group by l.project_version
