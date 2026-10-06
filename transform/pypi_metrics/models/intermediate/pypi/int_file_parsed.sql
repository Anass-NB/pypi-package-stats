{{
    config(
        materialized='view',
        schema='intermediate'
    )
}}

/*
Isolates two complex operations:
1. Parsing project_version strings ("2.13.0", "2.0.0rc205", "1.0.0.40.21")
   into sortable numeric parts. String sorting would put 2.9 after 2.13.
2. Parsing wheel filenames into python/abi/platform tags so the downloaded
   build (e.g. cp311) can be compared to the requesting runtime.
Nulls preserved; 'Unknown' conforming happens downstream.
Wheel filename spec: {name}-{version}(-{build})?-{pytag}-{abitag}-{plattag}.whl
*/

with downloads as (
    select event_id, file_name, project_name, project_version, package_type
    from {{ ref('int_downloads') }}
),

version_parsed as (
    select
        event_id,
        file_name,
        project_name,
        project_version,
        package_type,
        try_cast(nullif(regexp_extract(project_version, '^(\d+)', 1), '') as integer)
            as version_major,
        try_cast(nullif(regexp_extract(project_version, '^\d+\.(\d+)', 1), '') as integer)
            as version_minor,
        try_cast(nullif(regexp_extract(project_version, '^\d+\.\d+\.(\d+)', 1), '') as integer)
            as version_patch,
        nullif(regexp_extract(project_version, '^\d+\.\d+\.\d+\.(.+)$', 1), '')
            as version_extra,
        nullif(regexp_extract(project_version, '(rc\d+|a\d+|b\d+|\.dev\d*|alpha\d*|beta\d*)$', 1), '')
            as prerelease_tag,
        case
            when regexp_extract(project_version, '(rc\d+|a\d+|b\d+|\.dev\d*|alpha\d*|beta\d*)$', 1) <> '' then true
            else false
        end as is_prerelease
    from downloads
),

file_tagged as (
    select
        version_parsed.*,
        case
            when package_type = 'bdist_wheel' and file_name like '%.whl' then
                list_extract(list_reverse(string_split(file_name, '-')), 3)
            else null
        end as python_tag,
        case
            when package_type = 'bdist_wheel' and file_name like '%.whl' then
                list_extract(list_reverse(string_split(file_name, '-')), 2)
            else null
        end as abi_tag,
        case
            when package_type = 'bdist_wheel' and file_name like '%.whl' then
                regexp_replace(
                    list_extract(list_reverse(string_split(file_name, '-')), 1),
                    '\.whl$', ''
                )
            else null
        end as platform_tag
    from version_parsed
)

select
    event_id,
    file_name,
    project_name,
    project_version,
    package_type,
    version_major,
    version_minor,
    version_patch,
    version_extra,
    prerelease_tag,
    is_prerelease,
    -- sortable key: zero-padded numerics so 2.9 < 2.13; prereleases sort before finals
    printf(
        '%010d.%010d.%010d|%s',
        coalesce(version_major, 0),
        coalesce(version_minor, 0),
        coalesce(version_patch, 0),
        coalesce(prerelease_tag, '~')
    ) as version_sort_key,
    python_tag,
    abi_tag,
    platform_tag,
    case
        when package_type <> 'bdist_wheel' or python_tag is null then null
        when python_tag like 'cp%' then
            regexp_extract(python_tag, '^cp(\d)(\d+).*$', 1)
            || '.' || regexp_extract(python_tag, '^cp(\d)(\d+).*$', 2)
        when python_tag like 'pp%' then
            'pypy ' || regexp_extract(python_tag, '^pp(\d)(\d*).*$', 1)
            || coalesce('.' || nullif(regexp_extract(python_tag, '^pp(\d)(\d*).*$', 2), ''), '')
        when python_tag = 'py3' then '3'
        when python_tag = 'py2' then '2'
        when python_tag = 'py2.py3' then '2/3'
        else python_tag
    end as build_python_version,
    case
        when package_type = 'sdist' then 'source'
        when platform_tag is null then null
        when lower(platform_tag) like 'any%' then 'any'
        when lower(platform_tag) like '%win%' then 'Windows'
        when lower(platform_tag) like '%macosx%' or lower(platform_tag) like '%macos%' then 'macOS'
        when lower(platform_tag) like '%manylinux%' or lower(platform_tag) like '%linux%' then 'Linux'
        else platform_tag
    end as build_platform_family
from file_tagged
