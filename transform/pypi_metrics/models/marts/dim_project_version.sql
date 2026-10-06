{{
    config(
        materialized='table',
        schema='marts'
    )
}}

/*
Version dimension. Versions are strings ("2.13.0", "2.0.0rc205", "1.0.0.40.21")
parsed upstream in int_file_parsed; version_sort_key orders by true numeric
order (2.9 < 2.13) with prereleases before their final. Each distinct
(project, version) string is its own member (Type 0/1, no SCD).
Answers Q1: downloads per version over time.
*/

with distinct_versions as (
    select distinct
        project_name,
        project_version,
        version_major,
        version_minor,
        version_patch,
        version_extra,
        prerelease_tag,
        is_prerelease,
        version_sort_key
    from {{ ref('int_downloads_enriched') }}
    where not (project_name = 'Unknown' and project_version = 'Unknown')
),

keyed as (
    select
        {{ dbt_utils.generate_surrogate_key(['project_name', 'project_version']) }} as version_key,
        project_name,
        project_version,
        version_major,
        version_minor,
        version_patch,
        version_extra,
        prerelease_tag,
        is_prerelease,
        version_sort_key
    from distinct_versions
)

select
    version_key, project_name, project_version,
    version_major, version_minor, version_patch, version_extra,
    prerelease_tag, is_prerelease, version_sort_key
from keyed
union all
select
    '-1' as version_key, 'Unknown' as project_name, 'Unknown' as project_version,
    null as version_major, null as version_minor, null as version_patch,
    null as version_extra, 'Unknown' as prerelease_tag,
    false as is_prerelease, 'Unknown' as version_sort_key
