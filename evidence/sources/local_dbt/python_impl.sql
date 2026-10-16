-- Runtime Python implementation (CPython, PyPy, ...).
select
    p.python_implementation,
    sum(f.download_count) as downloads
from main_marts.fct_downloads as f
join main_marts.dim_python as p using (python_key)
group by 1
order by 2 desc
