with source_currency as (

    select * from {{ source('adventureworks_raw', 'sales_currency') }}

),

renamed as (

    select
        cast(currencycode as STRING) as currency_pk
        , cast(name as STRING) as currency_name
        , cast(modifieddate as TIMESTAMP) as currency_modified_at

    from source_currency

)

select * from renamed
