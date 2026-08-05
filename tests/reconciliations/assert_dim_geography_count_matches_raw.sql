-- dim_geography grain = distinct city + state + country from addresses (same key as int_geography).

with raw_geo as (

    select count(*) as row_count
    from (

        select distinct
            lower(trim(a.city)) as city_norm
            , a.stateprovinceid
            , upper(trim(sp.countryregioncode)) as country_norm

        from {{ source('adventureworks_raw', 'person_address') }} as a
        inner join {{ source('adventureworks_raw', 'person_stateprovince') }} as sp
            on sp.stateprovinceid = a.stateprovinceid

    ) as distinct_geo

),

mart_geo as (

    select count(*) as row_count
    from {{ ref('dim_geography') }}

)

select
    raw_geo.row_count as raw_distinct_geography_count
    , mart_geo.row_count as dim_geography_count
    , mart_geo.row_count - raw_geo.row_count as difference

from raw_geo
cross join mart_geo

where raw_geo.row_count != mart_geo.row_count
