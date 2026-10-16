-- Monthly downloads for the six most-downloaded Python major.minor lines;
-- everything else is grouped as 'Other'. Rows with unknown runtime Python are
-- excluded here (they are shown separately on the Python page).
with monthly as (
    select
        cast(date_trunc('month', d.date_day) as date) as month,
        p.python_major_minor as python_version,
        sum(f.download_count) as downloads
    from main_marts.fct_downloads as f
    join main_marts.dim_date as d using (date_key)
    join main_marts.dim_python as p using (python_key)
    where p.python_major_minor <> 'Unknown'
    group by 1, 2
),
totals as (
    select
        python_version,
        sum(downloads) as total_downloads
    from monthly
    group by 1
),
top_versions as (
    select python_version
    from totals
    order by total_downloads desc
    limit 6
),
grouped as (
    select
        month,
        case
            when python_version in (select python_version from top_versions)
                then python_version
            else 'Other'
        end as python_version,
        sum(downloads) as downloads
    from monthly
    group by 1, 2
)
select
    month,
    python_version,
    downloads
from grouped
order by month, python_version
