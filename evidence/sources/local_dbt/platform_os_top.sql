-- Top raw OS name/release combinations (unmerged values, for the drill-down
-- table). Unknown rows are excluded to keep the list readable.
select
    p.os_name,
    p.os_release,
    sum(f.download_count) as downloads
from main_marts.fct_downloads as f
join main_marts.dim_platform as p using (platform_key)
where p.os_name <> 'Unknown'
group by 1, 2
order by downloads desc
limit 15
