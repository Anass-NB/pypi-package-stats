-- Top Linux distribution name/version combinations (Linux downloads only).
select
    p.distro_name,
    p.distro_version,
    sum(f.download_count) as downloads
from main_marts.fct_downloads as f
join main_marts.dim_platform as p using (platform_key)
where p.distro_name <> 'Unknown'
group by 1, 2
order by downloads desc
limit 15
