-- Downloads per country (all countries seen, incl. Unknown as its own row).
with by_country as (
    select
        c.country_code,
        c.country_name,
        sum(f.download_count) as downloads
    from main_marts.fct_downloads as f
    join main_marts.dim_country as c using (country_key)
    group by 1, 2
)
select
    country_code,
    country_name,
    downloads,
    round(100.0 * downloads / sum(downloads) over (), 2) as share_pct
from by_country
order by downloads desc
