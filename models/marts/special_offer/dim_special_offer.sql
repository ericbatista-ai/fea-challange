with special_offer as (

    select
        special_offer_pk
        , special_offer_description
        , discount_pct
        , special_offer_type
        , special_offer_category
        , offer_start_at
        , offer_end_at
        , min_qty
        , max_qty
        , is_promotional_offer
        , special_offer_modified_at

    from {{ ref('int_special_offer') }}

)

select * from special_offer
