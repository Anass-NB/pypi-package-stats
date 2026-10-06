{{
    config(
        materialized='view',
        schema='intermediate'
    )
}}

/*
Grain: one row per download event (no dedupe — legitimate duplicates are kept).
Adds a stable event_id: hash of the staging business columns plus a
row_number suffix so truly identical rows stay distinct.
Structural simplification: base for all narrow intermediate models.
*/

with source as (
    select * from {{ ref('stg_pypi__downloads') }}
),

hashed as (
    select
        source.*,
        {{ dbt_utils.generate_surrogate_key([
            'downloaded_at',
            'file_name',
            'project_name',
            'project_version',
            'package_type',
            'installer_name',
            'installer_version',
            'python_version',
            'python_implementation',
            'os_name',
            'os_release',
            'cpu_arch',
            'country_code',
            'tls_protocol',
            'tls_cipher'
        ]) }} as event_hash
    from source
),

numbered as (
    select
        hashed.*,
        row_number() over (
            partition by event_hash
            order by downloaded_at, file_name
        ) as event_dup_rank
    from hashed
)

select
    event_hash || '-' || cast(event_dup_rank as varchar) as event_id,
    event_hash,
    cast(downloaded_at as timestamp) as downloaded_at,
    cast(downloaded_at as date) as downloaded_date,
    file_name,
    project_name,
    project_version,
    package_type,
    installer_name,
    installer_version,
    python_version,
    python_implementation,
    openssl_version,
    setuptools_version,
    os_name,
    os_release,
    cpu_arch,
    distro,
    is_ci,
    country_code,
    tls_protocol,
    tls_cipher
from numbered
