-- Monthly downloads for the eight most-downloaded ingestr versions; everything
-- else is grouped as 'Other'. Unknown versions are excluded (see the data
-- quality note on the page).
with monthly as (
    select
        cast(date_trunc('month', d.date_day) as date) as month,
        v.project_version as version,
        sum(f.download_count) as downloads
    from main_marts.fct_downloads as f
    join main_marts.dim_date as d using (date_key)
    join main_marts.dim_project_version as v using (version_key)
    where v.project_version <> 'Unknown'
    group by 1, 2
),
totals as (
    select
        version,
        sum(downloads) as total_downloads
    from monthly
    group by 1
),
top_versions as (
    select version
    from totals
    order by total_downloads desc
    limit 8
),
grouped as (
    select
        month,
        case
            when version in (select version from top_versions) then version
            else 'Other'
        end as version,
        sum(downloads) as downloads
    from monthly
    group by 1, 2
)
select
    month,
    version,
    downloads
from grouped
order by month, version
