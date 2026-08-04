with source_countryregion as (

    select * from {{ source('adventureworks_raw', 'person_countryregion') }}

),

renamed as (

    select
        cast(countryregioncode as STRING) as country_region_pk
        , cast(name as STRING) as country_region_name
        , cast(modifieddate as TIMESTAMP) as country_region_modified_at

    from source_countryregion

)

select * from renamed
