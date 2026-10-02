
with

downloads as (

    select * from {{ ref('stg_pypi__downloads') }}

),




processed AS(

    SELECT 
    {{ dbt_utils.generate_surrogate_key(['downloaded_at', 'os_name', 'os_release', 'project_version', 'project_name', 'country_code', 'python_version', 'cpu_arch']) }} as download_id,
    CASE
            WHEN details.python IS NULL THEN NULL
            ELSE CONCAT(
                SPLIT_PART(details.python, '.', 1),
                '.',
                SPLIT_PART(details.python, '.', 2)
            )
        END AS python_version


)