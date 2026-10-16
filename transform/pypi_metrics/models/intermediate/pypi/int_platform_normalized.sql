
{{
    config(
        materialized='view',
        schema='intermediate'
    )
}}

with downloads as (
    select
        event_id,
        os_name,
        os_release,
        cpu_arch,
        distro
    from {{ ref('int_downloads') }}
)

select
    event_id,
    os_name,
    os_release,
    cpu_arch,

    -- OS normalization
    case
        when os_name is null then null
        when lower(os_name) = 'windows' then 'Windows'
        when lower(os_name) = 'linux' then 'Linux'
        when lower(os_name) in ('darwin', 'macos', 'mac os x') then 'macOS'
        else os_name
    end as os_family,

    -- CPU normalization
    case
        when cpu_arch is null then null
        when upper(cpu_arch) in ('X86_64', 'AMD64') then 'x86_64'
        when lower(cpu_arch) in ('aarch64', 'arm64') then 'arm64'
        when lower(cpu_arch) in ('i686', 'i386', 'x86') then 'x86'
        else cpu_arch
    end as cpu_norm,

    -- Distro metadata stored as VARCHAR
    trim(regexp_extract(distro, '''name'': ([^,}]+)', 1))
        as distro_name,

    trim(regexp_extract(distro, '''version'': ([^,}]+)', 1))
        as distro_version,

    trim(regexp_extract(distro, '''id'': ([^,}]+)', 1))
        as distro_id

from downloads
    