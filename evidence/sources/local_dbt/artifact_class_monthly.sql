-- Monthly artifact mix: how downloads split across distribution formats.
-- 'unresolved tag' = wheels whose filename tags could not be parsed (mostly
-- older artifacts / non-standard names) — kept visible on purpose.
with monthly as (
    select
        cast(date_trunc('month', d.date_day) as date) as month,
        case
            when fi.package_type = 'sdist' then 'sdist'
            when fi.python_tag = 'Unknown' then 'wheel: unresolved tag'
            when fi.python_tag = 'py2.py3' then 'wheel: py2.py3 (legacy)'
            when fi.platform_tag = 'any' then 'wheel: pure Python'
            else 'wheel: platform-specific'
        end as artifact_class,
        sum(f.download_count) as downloads
    from main_marts.fct_downloads as f
    join main_marts.dim_date as d using (date_key)
    join main_marts.dim_file as fi using (file_key)
    group by 1, 2
)
select
    month,
    artifact_class,
    downloads
from monthly
order by month, artifact_class
