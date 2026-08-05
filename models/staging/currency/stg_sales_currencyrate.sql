with source_currencyrate as (

    select * from {{ source('adventureworks_raw', 'sales_currencyrate') }}

),

renamed as (

    select
        cast(currencyrateid as INT) as currency_rate_pk
        , cast(currencyratedate as TIMESTAMP) as currency_rate_at
        , cast(fromcurrencycode as STRING) as from_currency_fk
        , cast(tocurrencycode as STRING) as to_currency_fk
        , cast(averagerate as DECIMAL(19, 4)) as average_rate
        , cast(endofdayrate as DECIMAL(19, 4)) as end_of_day_rate
        , cast(modifieddate as TIMESTAMP) as currency_rate_modified_at

    from source_currencyrate

)

select * from renamed
