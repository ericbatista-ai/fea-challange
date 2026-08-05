with territory as (

    select
        territory_pk
        , territory_name
        , country_region_fk
        , country_region_name
        , territory_group
        , sales_ytd
        , sales_last_year
        , cost_ytd
        , cost_last_year
        , territory_modified_at

    from {{ ref('int_territory') }}

)

select * from territory
