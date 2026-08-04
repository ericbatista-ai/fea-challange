with geography as (

    select
        geography_pk
        , city
        , state_province_name
        , country_region_name

    from {{ ref('int_geography') }}

)

select * from geography
