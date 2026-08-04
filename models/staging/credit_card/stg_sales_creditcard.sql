with source_creditcard as (

    select * from {{ source('adventureworks_raw', 'sales_creditcard') }}

),

renamed as (

    select
        cast(creditcardid as INT) as credit_card_pk
        , cast(cardtype as STRING) as card_type
        , cast(cardnumber as STRING) as card_number
        , cast(expmonth as INT) as expiration_month
        , cast(expyear as INT) as expiration_year
        , cast(modifieddate as TIMESTAMP) as credit_card_modified_at

    from source_creditcard

)

select * from renamed
