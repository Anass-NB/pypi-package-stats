-- Wheel vs sdist share of the most recent 30 days of traffic
-- (anchored to max(downloaded_at), not CURRENT_DATE).
with bounds as (
    select max(downloaded_at) as last_event_at
    from main_marts.fct_downloads
)
select
    sum(case when fi.package_type = 'bdist_wheel' then f.download_count else 0 end) as wheel_downloads_30d,
    sum(case when fi.package_type = 'sdist' then f.download_count else 0 end) as sdist_downloads_30d,
    sum(f.download_count) as total_downloads_30d,
    round(
        100.0 * sum(case when fi.package_type = 'bdist_wheel' then f.download_count else 0 end)
        / sum(f.download_count),
        1
    ) as wheel_share_30d_pct
from main_marts.fct_downloads as f
join main_marts.dim_file as fi using (file_key)
cross join bounds as b
where f.downloaded_at > b.last_event_at - interval 30 day
