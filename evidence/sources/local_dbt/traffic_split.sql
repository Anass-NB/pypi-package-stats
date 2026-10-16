-- Installer traffic class mix across all time.
with by_type as (
    select
        i.traffic_type,
        sum(f.download_count) as downloads
    from main_marts.fct_downloads as f
    join main_marts.dim_installer as i using (installer_key)
    group by 1
)
select
    traffic_type,
    downloads,
    round(100.0 * downloads / sum(downloads) over (), 2) as share_pct
from by_type
order by downloads desc
