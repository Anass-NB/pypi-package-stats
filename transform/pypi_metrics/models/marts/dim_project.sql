{{
    config(
        materialized='table',
        schema='marts'
    )
}}

/*
Type 1 dimension (overwrite on change, no history).
NOTE on future SCD2: if project metadata (owner, license, classifiers)
is added later, convert to a dbt snapshot (see snapshots/snp_project.sql,
currently disabled) and add valid_from/valid_to/is_current here.
*/

with distinct_projects as (
    select distinct project_name
    from {{ ref('int_downloads_enriched') }}
    where project_name != 'Unknown'
),

keyed as (
    select
        {{ dbt_utils.generate_surrogate_key(['project_name']) }} as project_key,
        project_name
    from distinct_projects
)

select project_key, project_name from keyed
union all
select '-1' as project_key, 'Unknown' as project_name
