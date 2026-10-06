{{
    config(
        materialized='view',
        schema='intermediate'
    )
}}

/*
Isolates the complex operation of parsing details.python ("3.11.6").
Output: one row per event_id with major/minor/patch + "3.11" style short version.
Nulls are preserved here; conforming to 'Unknown' happens in int_downloads_enriched.
*/

with downloads as (
    select event_id, python_version, python_implementation
    from {{ ref('int_downloads') }}
)

select
    event_id,
    python_version as python_version_full,
    python_implementation,
    case
        when python_version is null then null
        else split_part(python_version, '.', 1)
    end as python_major_raw,
    case
        when python_version is null then null
        else split_part(python_version, '.', 2)
    end as python_minor_raw,
    case
        when python_version is null then null
        when split_part(python_version, '.', 3) = '' then null
        else split_part(python_version, '.', 3)
    end as python_patch_raw,
    try_cast(
        nullif(regexp_extract(python_version, '^(\d+)', 1), '')
        as integer
    ) as python_major,
    try_cast(
        nullif(regexp_extract(python_version, '^\d+\.(\d+)', 1), '')
        as integer
    ) as python_minor,
    try_cast(
        nullif(regexp_extract(split_part(python_version, '.', 3), '^(\d+)', 1), '')
        as integer
    ) as python_patch,
    case
        when python_version is null then null
        when split_part(python_version, '.', 2) = '' then split_part(python_version, '.', 1)
        else split_part(python_version, '.', 1) || '.' || split_part(python_version, '.', 2)
    end as python_major_minor
from downloads
