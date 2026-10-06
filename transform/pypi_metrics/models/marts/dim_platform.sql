{{
    config(
        materialized='table',
        schema='marts'
    )
}}

/*
Platform dimension: OS + CPU + distro. os_family/cpu_arch are normalized
upstream (Linux/Windows/macOS; x86_64/arm64). Use with dim_country for Q3.
*/

with distinct_platforms as (
    select distinct
        os_name,
        os_release,
        os_family,
        cpu_arch,
        distro_name,
        distro_version
    from {{ ref('int_downloads_enriched') }}
    where not (
        os_name = 'Unknown'
        and os_release = 'Unknown'
        and cpu_arch = 'Unknown'
        and distro_name = 'Unknown'
        and distro_version = 'Unknown'
    )
),

keyed as (
    select
        {{ dbt_utils.generate_surrogate_key(['os_name', 'os_release', 'cpu_arch', 'distro_name', 'distro_version']) }} as platform_key,
        os_name,
        os_release,
        os_family,
        cpu_arch,
        distro_name,
        distro_version
    from distinct_platforms
)

select platform_key, os_name, os_release, os_family, cpu_arch, distro_name, distro_version
from keyed
union all
select '-1' as platform_key, 'Unknown' as os_name, 'Unknown' as os_release, 'Unknown' as os_family, 'Unknown' as cpu_arch, 'Unknown' as distro_name, 'Unknown' as distro_version
