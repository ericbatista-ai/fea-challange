with source_stateprovince as (

    select * from {{ source('adventureworks_raw', 'person_stateprovince') }}

),

renamed as (

    select
        cast(stateprovinceid as INT) as state_province_pk
        , cast(stateprovincecode as STRING) as state_province_code
        , cast(countryregioncode as STRING) as country_region_fk
        , cast(name as STRING) as state_province_name
        , cast(territoryid as INT) as territory_fk
        , cast(modifieddate as TIMESTAMP) as state_province_modified_at

    from source_stateprovince

)

select * from renamed
