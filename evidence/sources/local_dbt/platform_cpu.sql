-- CPU architecture mix (normalized: x86_64 / arm64 / Unknown).
select
    p.cpu_arch,
    sum(f.download_count) as downloads
from main_marts.fct_downloads as f
join main_marts.dim_platform as p using (platform_key)
group by 1
order by 2 desc
