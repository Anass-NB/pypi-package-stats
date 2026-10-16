-- Headline numbers. "Last N days" windows are anchored to the newest event in
-- the data (max downloaded_at), not CURRENT_DATE, so the numbers stay stable
-- when the dashboard is rebuilt later without new data.
with bounds as (
    select max(downloaded_at) as last_event_at
    from main_marts.fct_downloads
)
select
    sum(f.download_count) as total_downloads,
    count(*) as total_events,
    count(distinct case when f.country_key <> '-1' then f.country_key end) as countries,
    min(f.downloaded_at) as first_event_at,
    max(f.downloaded_at) as last_event_at,
    sum(case when f.downloaded_at > b.last_event_at - interval 30 day
             then f.download_count else 0 end) as downloads_last_30d,
    sum(case when f.downloaded_at > b.last_event_at - interval 7 day
             then f.download_count else 0 end) as downloads_last_7d
from main_marts.fct_downloads as f
cross join bounds as b
