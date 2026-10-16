-- Wheels vs sdists per runtime Python major.minor line.
select
    fi.package_type,
    p.python_major_minor as runtime_version,
    sum(f.download_count) as downloads
from main_marts.fct_downloads as f
join main_marts.dim_file as fi using (file_key)
join main_marts.dim_python as p using (python_key)
where fi.package_type in ('bdist_wheel', 'sdist')
    and p.python_major_minor <> 'Unknown'
group by 1, 2
order by 1, downloads desc
