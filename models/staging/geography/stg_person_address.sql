with source_address as (

    select * from {{ source('adventureworks_raw', 'person_address') }}

),

renamed as (

    select
        cast(addressid as INT) as address_pk
        , cast(addressline1 as STRING) as address_line_1
        , cast(addressline2 as STRING) as address_line_2
        , cast(city as STRING) as city
        , cast(stateprovinceid as INT) as state_province_fk
        , cast(postalcode as STRING) as postal_code
        , cast(modifieddate as TIMESTAMP) as address_modified_at

    from source_address

)

select * from renamed
