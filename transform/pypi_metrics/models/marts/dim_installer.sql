{{
    config(
        materialized='table',
        schema='marts'
    )
}}

/*
Installer dimension, grain (installer_name, installer_version, traffic_type).
traffic_type depends on the event-level is_ci flag, so the same installer
version appears twice when seen both in CI and interactively — intentional.
Use traffic_type for Q4 (interactive vs ci/mirror/build_system/automated).
Installer version differences are separate members (Type 0/1, no SCD).
*/

with distinct_installers as (
    select distinct
        installer_name,
        installer_version,
        traffic_type,
        is_automated_traffic
    from {{ ref('int_downloads_enriched') }}
    where not (installer_name = 'Unknown' and installer_version = 'Unknown')
),

keyed as (
    select
        {{ dbt_utils.generate_surrogate_key(['installer_name', 'installer_version', 'traffic_type']) }} as installer_key,
        installer_name,
        installer_version,
        traffic_type,
        is_automated_traffic
    from distinct_installers
)

select installer_key, installer_name, installer_version, traffic_type, is_automated_traffic
from keyed
union all
select '-1' as installer_key, 'Unknown' as installer_name, 'Unknown' as installer_version, 'unknown' as traffic_type, false as is_automated_traffic
