
WITH source AS (
    SELECT *
    FROM {{ source('external_source', 'raw_ingestr_pypi_downloads') }}
),

renamed AS (
    SELECT
        -- Timestamps
        CAST(timestamp AS TIMESTAMP) AS downloaded_at,

        -- File metadata
        trim(regexp_extract(file, '''filename'': ([^,}]+)', 1))
            AS file_name,
        trim(regexp_extract(file, '''project'': ([^,}]+)', 1))
            AS project_name,
        trim(regexp_extract(file, '''version'': ([^,}]+)', 1))
            AS project_version,
        trim(regexp_extract(file, '''type'': ([^,}]+)', 1))
            AS package_type,

        -- Installer
        trim(regexp_extract(details, '''name'': ([^,}]+)', 1))
            AS installer_name,
        trim(regexp_extract(details, '''version'': ([^,}]+)', 1))
            AS installer_version,

        -- Python environment
        trim(regexp_extract(details, '''python'': ([^,}]+)', 1))
            AS python_version,
        trim(regexp_extract(details, '''implementation'': \{[^}]*''name'': ([^,}]+)', 1))
            AS python_implementation,
        trim(regexp_extract(details, '''openssl_version'': ([^,}]+)', 1))
            AS openssl_version,
        trim(regexp_extract(details, '''setuptools_version'': ([^,}]+)', 1))
            AS setuptools_version,

        -- Platform
        trim(regexp_extract(details, '''system'': \{[^}]*''name'': ([^,}]+)', 1))
            AS os_name,
        trim(regexp_extract(details, '''system'': \{[^}]*''release'': ([^,}]+)', 1))
            AS os_release,
        trim(regexp_extract(details, '''cpu'': ([^,}]+)', 1))
            AS cpu_arch,
        trim(regexp_extract(details, '''distro'': ([^,}]+)', 1))
            AS distro,
        try_cast(trim(regexp_extract(details, '''ci'': ([^,}]+)', 1)) as boolean)
            AS is_ci,

        -- Geo / transport
        country_code,
        tls_protocol,
        tls_cipher

    FROM source
)

SELECT *
FROM renamed
