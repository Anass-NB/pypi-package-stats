
--IMPORTS--

WITH

source AS (
    SELECT
       *
    FROM {{ source('external_source', 'raw_pypi_downloads') }}
),

renamed AS(

    SELECT 
        ---------- timestamps
        cast(timestamp as timestamp)              as downloaded_at,

        ---------- file
        file.filename                             as file_name,
        file.project                              as project_name,
        file.version                              as project_version,
        file.type                                 as package_type,

        ---------- installer
        details.installer.name                    as installer_name,
        details.installer.version                 as installer_version,

        ---------- python environment
        details.python                            as python_version,
        details.implementation.name               as python_implementation,
        details.openssl_version                   as openssl_version,
        details.setuptools_version                as setuptools_version,

        ---------- platform
        details.system.name                       as os_name,
        details.system.release                    as os_release,
        details.cpu                               as cpu_arch,
        details.distro                            as distro,
        details.ci                                as is_ci,

        ---------- geo / transport
        country_code                              as country_code,
        tls_protocol                              as tls_protocol,
        tls_cipher                                as tls_cipher        




    FROM source
)



SELECT * FROM renamed