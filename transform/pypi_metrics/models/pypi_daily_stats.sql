WITH pre_aggregated_data AS (
    SELECT
        timestamp :: date as download_date,
        details.system.name AS system_name,
        details.system.release AS system_release,
        file.version AS version,
        project,
        country_code,
        details.cpu,
        CASE
            WHEN details.python IS NULL THEN NULL
            ELSE CONCAT(
                SPLIT_PART(details.python, '.', 1),
                '.',
                SPLIT_PART(details.python, '.', 2)
            )
        END AS python_version
    FROM
    's3://us-prd-motherduck-open-datasets/pypi/sample_tutorial/pypi_file_downloads/*/*/*.parquet'
    WHERE
        download_date >= '{{ var("START_DATE") }}'
        AND download_date < '{{ var("END_DATE") }}'
)

SELECT
    MD5(CONCAT_WS('|', download_date, system_name, system_release, version, project, country_code, cpu, python_version)) AS load_id,
    download_date,
    system_name,
    system_release,
    version,
    project,
    country_code,
    cpu,
    python_version,
    COUNT(*) AS daily_download_sum 
FROM
    pre_aggregated_data
GROUP BY
    ALL