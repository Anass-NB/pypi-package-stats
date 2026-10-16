-- Wheel vs sdist mix across all time.
select
    fi.package_type,
    sum(f.download_count) as downloads
from main_marts.fct_downloads as f
join main_marts.dim_file as fi using (file_key)
group by 1
order by 2 desc
