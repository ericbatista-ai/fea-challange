with credit_card as (

    select * from {{ ref('stg_sales_creditcard') }}

),

credit_card_enriched as (

    select
        credit_card_pk
        , card_type
        , card_number
        , expiration_month
        , expiration_year
        , credit_card_modified_at

    from credit_card

)

select * from credit_card_enriched
