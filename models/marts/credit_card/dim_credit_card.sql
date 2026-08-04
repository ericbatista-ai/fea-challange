with credit_card as (

    select
        credit_card_pk
        , card_type
        , card_number
        , expiration_month
        , expiration_year
        , credit_card_modified_at

    from {{ ref('int_credit_card') }}

)

select * from credit_card
