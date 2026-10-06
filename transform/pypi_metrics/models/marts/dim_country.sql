{{
    config(
        materialized='table',
        schema='marts'
    )
}}

/*
Country dimension, enriched with the country_codes seed.
Codes not in the seed keep a null name (still a real member, not Unknown).
*/

with distinct_countries as (
    select distinct country_code
    from {{ ref('int_downloads_enriched') }}
    where country_code != 'Unknown'
),

keyed as (
    select
        {{ dbt_utils.generate_surrogate_key(['distinct_countries.country_code']) }} as country_key,
        distinct_countries.country_code,
        seed.country_name as country_name
    from distinct_countries
    left join {{ ref('country_codes') }} as seed
        on distinct_countries.country_code = seed.country_code
)

select country_key, country_code, country_name from keyed
union all
select '-1' as country_key, 'Unknown' as country_code, 'Unknown' as country_name
