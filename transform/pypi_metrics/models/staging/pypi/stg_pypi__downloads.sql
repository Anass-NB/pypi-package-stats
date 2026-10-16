
/*
Staging contract: expose raw event fields with light casting only, no business logic.
details/file arrive as struct-like text; missing values are serialized as the
literal text 'NULL' (e.g. 'python': NULL) and regex misses come back as ''.
Both are normalized to SQL NULL here so downstream 'Unknown' conforming works
from real nulls. Installer regexes are scoped to the installer struct: when an
installer is missing, an unscoped name/version pattern would grab values from
the implementation struct instead.
*/

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
        nullif(nullif(trim(regexp_extract(details, '''installer'': \{[^}]*''name'': ([^,}]+)', 1)), ''), 'NULL')
            AS installer_name,
        nullif(nullif(trim(regexp_extract(details, '''installer'': \{[^}]*''version'': ([^,}]+)', 1)), ''), 'NULL')
            AS installer_version,

        -- Python environment
        nullif(nullif(trim(regexp_extract(details, '''python'': ([^,}]+)', 1)), ''), 'NULL')
            AS python_version,
        nullif(nullif(trim(regexp_extract(details, '''implementation'': \{[^}]*''name'': ([^,}]+)', 1)), ''), 'NULL')
            AS python_implementation,
        nullif(nullif(trim(regexp_extract(details, '''openssl_version'': ([^,}]+)', 1)), ''), 'NULL')
            AS openssl_version,
        nullif(nullif(trim(regexp_extract(details, '''setuptools_version'': ([^,}]+)', 1)), ''), 'NULL')
            AS setuptools_version,

        -- Platform
        nullif(nullif(trim(regexp_extract(details, '''system'': \{[^}]*''name'': ([^,}]+)', 1)), ''), 'NULL')
            AS os_name,
        nullif(nullif(trim(regexp_extract(details, '''system'': \{[^}]*''release'': ([^,}]+)', 1)), ''), 'NULL')
            AS os_release,
        nullif(nullif(trim(regexp_extract(details, '''cpu'': ([^,}]+)', 1)), ''), 'NULL')
            AS cpu_arch,
        nullif(nullif(trim(regexp_extract(details, '''distro'': ([^,}]+)', 1)), ''), 'NULL')
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
