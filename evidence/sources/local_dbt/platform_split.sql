-- OS family mix (Linux / Windows / macOS / Unknown).
with by_os as (
    select
        p.os_family,
        sum(f.download_count) as downloads
    from main_marts.fct_downloads as f
    join main_marts.dim_platform as p using (platform_key)
    group by 1
)
select
    os_family,
    downloads,
    round(100.0 * downloads / sum(downloads) over (), 2) as share_pct
from by_os
order by downloads desc
