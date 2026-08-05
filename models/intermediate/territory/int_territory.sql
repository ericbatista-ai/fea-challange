with territory as (

    select * from {{ ref('stg_sales_salesterritory') }}

),

country_region as (

    select
        country_region_pk
        , country_region_name

    from {{ ref('stg_person_countryregion') }}

),

territory_enriched as (

    select
        territory.territory_pk
        , territory.territory_name
        , territory.country_region_fk
        , country_region.country_region_name
        , territory.territory_group
        , territory.sales_ytd
        , territory.sales_last_year
        , territory.cost_ytd
        , territory.cost_last_year
        , territory.territory_modified_at

    from territory
    left join country_region
        on country_region.country_region_pk = territory.country_region_fk

)

select * from territory_enriched
