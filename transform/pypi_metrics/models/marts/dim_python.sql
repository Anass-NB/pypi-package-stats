{{
    config(
        materialized='table',
        schema='marts'
    )
}}

/*
Runtime Python dimension (the interpreter that requested the download).
Use python_major_minor ("3.11") for Q2 monthly share; full version for detail.
Each distinct (full version, implementation) is its own member (Type 0/1).
*/

with distinct_pythons as (
    select distinct
        python_version_full,
        python_major_minor,
        python_major,
        python_minor,
        python_patch,
        python_implementation
    from {{ ref('int_downloads_enriched') }}
    where not (python_version_full = 'Unknown' and python_implementation = 'Unknown')
),

keyed as (
    select
        {{ dbt_utils.generate_surrogate_key(['python_version_full', 'python_implementation']) }} as python_key,
        python_version_full,
        python_major_minor,
        python_major,
        python_minor,
        python_patch,
        python_implementation
    from distinct_pythons
)

select
    python_key, python_version_full, python_major_minor,
    python_major, python_minor, python_patch, python_implementation
from keyed
union all
select
    '-1' as python_key, 'Unknown' as python_version_full, 'Unknown' as python_major_minor,
    null as python_major, null as python_minor, null as python_patch,
    'Unknown' as python_implementation
