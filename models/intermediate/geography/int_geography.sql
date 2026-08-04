with address as (

    select * from {{ ref('stg_person_address') }}

),

state_province as (

    select * from {{ ref('stg_person_stateprovince') }}

),

country_region as (

    select * from {{ ref('stg_person_countryregion') }}

),

geography_enriched as (

    select distinct
        cast(
            md5(
                lower(trim(address.city))
                || '|'
                || cast(address.state_province_fk as STRING)
                || '|'
                || upper(trim(state_province.country_region_fk))
            ) as STRING
        ) as geography_pk
        , address.city
        , address.state_province_fk
        , state_province.state_province_code
        , state_province.state_province_name
        , state_province.country_region_fk as country_region_code
        , country_region.country_region_name

    from address
    inner join state_province
        on state_province.state_province_pk = address.state_province_fk
    left join country_region
        on country_region.country_region_pk = state_province.country_region_fk

)

select * from geography_enriched
