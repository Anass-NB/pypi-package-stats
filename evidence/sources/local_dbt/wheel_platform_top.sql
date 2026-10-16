-- Top platform tags among platform-specific wheels (excludes pure wheels).
select
    fi.platform_tag,
    sum(f.download_count) as downloads
from main_marts.fct_downloads as f
join main_marts.dim_file as fi using (file_key)
where fi.package_type = 'bdist_wheel'
    and fi.platform_tag not in ('any', 'Unknown')
group by 1
order by 2 desc
limit 12
