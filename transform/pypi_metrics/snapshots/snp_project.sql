{% snapshot snp_project %}
{{
    config(
        target_schema='snapshots',
        unique_key='project_name',
        strategy='check',
        check_cols=['project_name'],
        enabled=False
    )
}}
/*
DISABLED placeholder for the future SCD2 path of dim_project (Type 1 today).

Enable only if project-level metadata (owner, license, classifiers, …)
is added to the model: point this at the metadata source, enable the
snapshot, then rebuild dim_project with valid_from / valid_to / is_current
from the snapshot instead of the current DISTINCT list.
*/
select
    cast('Unknown' as varchar) as project_name
where false
{% endsnapshot %}
