-- Runtime Python major.minor lines across all time (Unknown kept as a row).
with by_version as (
    select
        p.python_major_minor,
        sum(f.download_count) as downloads
    from main_marts.fct_downloads as f
    join main_marts.dim_python as p using (python_key)
    group by 1
)
select
    python_major_minor,
    downloads,
    round(100.0 * downloads / sum(downloads) over (), 2) as share_pct
from by_version
order by downloads desc
