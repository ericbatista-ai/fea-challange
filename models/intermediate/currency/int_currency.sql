with currency as (

    select * from {{ ref('stg_sales_currency') }}

),

currency_enriched as (

    select
        currency_pk
        , currency_name
        , currency_modified_at

    from currency

)

select * from currency_enriched
