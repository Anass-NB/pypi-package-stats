{{
    config(
        materialized='table',
        schema='marts'
    )
}}

/*
File/build dimension. python_tag/abi_tag/platform_tag are null for sdists
(conformed to 'Unknown' upstream). build_python_version is the Python
implied by the wheel tag (cp311 -> 3.11, py3 -> 3); compare it to
dim_python for Q5 (build vs runtime).
*/

with distinct_files as (
    select distinct
        file_name,
        package_type,
        python_tag,
        abi_tag,
        platform_tag,
        build_python_version,
        build_platform_family
    from {{ ref('int_downloads_enriched') }}
    where file_name != 'Unknown'
),

keyed as (
    select
        {{ dbt_utils.generate_surrogate_key(['file_name']) }} as file_key,
        file_name,
        package_type,
        python_tag,
        abi_tag,
        platform_tag,
        build_python_version,
        build_platform_family
    from distinct_files
)

select
    file_key, file_name, package_type, python_tag, abi_tag,
    platform_tag, build_python_version, build_platform_family
from keyed
union all
select
    '-1' as file_key, 'Unknown' as file_name, 'Unknown' as package_type,
    'Unknown' as python_tag, 'Unknown' as abi_tag, 'Unknown' as platform_tag,
    'Unknown' as build_python_version, 'Unknown' as build_platform_family
