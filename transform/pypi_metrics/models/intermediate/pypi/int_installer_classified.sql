{{
    config(
        materialized='view',
        schema='intermediate'
    )
}}

/*
Isolates installer normalization + traffic classification.
Separates human installs from automated traffic:
mirror/proxy (devpi, bandersnatch, Nexus), build systems (Bazel),
CI (is_ci flag), scripted (requests/Browser), automated (poetry),
interactive (pip, uv, setuptools, ...).
*/

with downloads as (
    select event_id, installer_name, installer_version, is_ci
    from {{ ref('int_downloads') }}
),

classified as (
    select
        event_id,
        installer_name,
        installer_version,
        is_ci,
        lower(coalesce(installer_name, '')) as installer_norm
    from downloads
)

select
    event_id,
    installer_name,
    installer_version,
    is_ci,
    case
        when installer_name is null then 'unknown'
        when installer_norm in ('devpi', 'bandersnatch', 'nexus', 'artifactory', 'pypiserver') then 'mirror'
        when installer_norm in ('bazel') then 'build_system'
        when is_ci = true then 'ci'
        when installer_norm in ('poetry', 'pdm', 'hatch') then 'automated'
        when installer_norm in ('pip', 'uv', 'pipenv', 'rye', 'setuptools', 'conda', 'mamba', 'micromamba') then 'interactive'
        when installer_norm in ('requests', 'curl', 'wget', 'browser', 'urllib3', 'httpie') then 'scripted'
        else 'other'
    end as traffic_type,
    case
        when installer_name is null then false
        when lower(coalesce(installer_name, '')) in ('devpi', 'bandersnatch', 'nexus', 'artifactory', 'bazel', 'poetry')
            then true
        when is_ci = true then true
        else false
    end as is_automated_traffic
from classified
