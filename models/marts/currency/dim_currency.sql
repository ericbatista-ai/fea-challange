with currency as (

    select
        currency_pk
        , currency_name
        , currency_modified_at

    from {{ ref('int_currency') }}

)

select * from currency
