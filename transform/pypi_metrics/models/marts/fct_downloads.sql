{{
    config(
        materialized='incremental',
        schema='marts',
        unique_key='event_id',
        incremental_strategy='delete+insert'
    )
}}

/*
Fact at grain = one download event. No aggregation, no dedupe.
FKs never null: each join coalesces to '-1', matching the dims' Unknown member.
Incremental on downloaded_at (append-only event stream).
Measures: download_count = 1 per row; sum it for Q1-Q5.
*/

with enriched as (
    select * from {{ ref('int_downloads_enriched') }}
    {% if is_incremental() %}
    where downloaded_at > (select coalesce(max(downloaded_at), cast('1970-01-01' as timestamp)) from {{ this }})
    {% endif %}
)

select
    e.event_id,
    cast(strftime(e.downloaded_date, '%Y%m%d') as integer) as date_key,
    e.downloaded_at,
    coalesce(p.project_key, '-1') as project_key,
    coalesce(v.version_key, '-1') as version_key,
    coalesce(f.file_key, '-1') as file_key,
    coalesce(py.python_key, '-1') as python_key,
    coalesce(i.installer_key, '-1') as installer_key,
    coalesce(pl.platform_key, '-1') as platform_key,
    coalesce(c.country_key, '-1') as country_key,
    1 as download_count,
    -- degenerate dimensions (kept, no logic built on them)
    e.tls_protocol,
    e.tls_cipher,
    e.is_ci
from enriched as e
left join {{ ref('dim_project') }} as p
    on e.project_name = p.project_name
left join {{ ref('dim_project_version') }} as v
    on e.project_name = v.project_name
    and e.project_version = v.project_version
left join {{ ref('dim_file') }} as f
    on e.file_name = f.file_name
left join {{ ref('dim_python') }} as py
    on e.python_version_full = py.python_version_full
    and e.python_implementation = py.python_implementation
left join {{ ref('dim_installer') }} as i
    on e.installer_name = i.installer_name
    and e.installer_version = i.installer_version
    and e.traffic_type = i.traffic_type
left join {{ ref('dim_platform') }} as pl
    on e.os_name = pl.os_name
    and e.os_release = pl.os_release
    and e.cpu_arch = pl.cpu_arch
    and e.distro_name = pl.distro_name
    and e.distro_version = pl.distro_version
left join {{ ref('dim_country') }} as c
    on e.country_code = c.country_code
