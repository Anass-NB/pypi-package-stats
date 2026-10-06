{{
    config(
        materialized='view',
        schema='intermediate'
    )
}}

/*
Wide enriched table: the single output marts read (deliberate exception to
the "few outputs" guidance — fact + all dims derive from the same events).

Null conforming happens HERE, not in staging:
every dimension-bound column is coalesced to 'Unknown' so facts never
carry a null FK; dims hold the matching '-1' Unknown member.
Kept as-is (nullable, no logic built on them): tls_*, is_ci, openssl/setuptools.
*/

with base as (
    select * from {{ ref('int_downloads') }}
),
py as (
    select * from {{ ref('int_python_parsed') }}
),
fl as (
    select * from {{ ref('int_file_parsed') }}
),
ins as (
    select * from {{ ref('int_installer_classified') }}
),
plt as (
    select * from {{ ref('int_platform_normalized') }}
)

select
    base.event_id,
    base.event_hash,
    base.downloaded_at,
    base.downloaded_date,

    -- project / file / version (conformed)
    coalesce(base.project_name, 'Unknown') as project_name,
    coalesce(base.project_version, 'Unknown') as project_version,
    coalesce(fl.version_sort_key, 'Unknown') as version_sort_key,
    fl.version_major,
    fl.version_minor,
    fl.version_patch,
    fl.version_extra,
    coalesce(fl.prerelease_tag, 'Unknown') as prerelease_tag,
    coalesce(fl.is_prerelease, false) as is_prerelease,
    coalesce(base.file_name, 'Unknown') as file_name,
    coalesce(base.package_type, 'Unknown') as package_type,
    coalesce(fl.python_tag, 'Unknown') as python_tag,
    coalesce(fl.abi_tag, 'Unknown') as abi_tag,
    coalesce(fl.platform_tag, 'Unknown') as platform_tag,
    coalesce(fl.build_python_version, 'Unknown') as build_python_version,
    coalesce(fl.build_platform_family, 'Unknown') as build_platform_family,

    -- runtime python (conformed)
    coalesce(py.python_version_full, 'Unknown') as python_version_full,
    coalesce(py.python_major_minor, 'Unknown') as python_major_minor,
    py.python_major,
    py.python_minor,
    py.python_patch,
    coalesce(py.python_implementation, 'Unknown') as python_implementation,

    -- installer (conformed)
    coalesce(ins.installer_name, 'Unknown') as installer_name,
    coalesce(ins.installer_version, 'Unknown') as installer_version,
    coalesce(ins.traffic_type, 'unknown') as traffic_type,
    coalesce(ins.is_automated_traffic, false) as is_automated_traffic,

    -- platform (conformed)
    coalesce(plt.os_name, 'Unknown') as os_name,
    coalesce(plt.os_release, 'Unknown') as os_release,
    coalesce(plt.os_family, 'Unknown') as os_family,
    coalesce(plt.cpu_arch, 'Unknown') as cpu_arch_raw,
    coalesce(plt.cpu_norm, 'Unknown') as cpu_arch,
    coalesce(plt.distro_name, 'Unknown') as distro_name,
    coalesce(plt.distro_version, 'Unknown') as distro_version,

    -- geo (conformed)
    coalesce(base.country_code, 'Unknown') as country_code,

    -- degenerate / kept-as-is (may be null or constant in samples)
    base.tls_protocol,
    base.tls_cipher,
    base.is_ci,
    base.openssl_version,
    base.setuptools_version
from base
left join py on base.event_id = py.event_id
left join fl on base.event_id = fl.event_id
left join ins on base.event_id = ins.event_id
left join plt on base.event_id = plt.event_id
