{{
    config(
        materialized='view',
        schema='intermediate'
    )
}}

/*
Isolates OS/CPU/distro normalization.
os_name values observed: Linux, Windows, Darwin, null. cpu values mix
x86_64/AMD64 and aarch64/arm64/ARM64 with different capitalizations.
*/

with downloads as (
    select event_id, os_name, os_release, cpu_arch, distro
    from {{ ref('int_downloads') }}
)

select
    event_id,
    os_name,
    os_release,
    cpu_arch,
    case
        when os_name is null then null
        when lower(os_name) in ('windows') then 'Windows'
        when lower(os_name) in ('linux') then 'Linux'
        when lower(os_name) in ('darwin', 'macos', 'mac os x') then 'macOS'
        else os_name
    end as os_family,
    case
        when cpu_arch is null then null
        when upper(cpu_arch) in ('X86_64', 'AMD64') then 'x86_64'
        when lower(cpu_arch) in ('aarch64', 'arm64') or cpu_arch = 'ARM64' then 'arm64'
        when lower(cpu_arch) in ('i686', 'i386', 'x86') then 'x86'
        else cpu_arch
    end as cpu_norm,
    distro.name as distro_name,
    distro.version as distro_version,
    distro.id as distro_id
from downloads
