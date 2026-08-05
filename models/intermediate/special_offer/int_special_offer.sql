with special_offer as (

    select * from {{ ref('stg_sales_specialoffer') }}

),

special_offer_enriched as (

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
        , case
            when special_offer_pk = 1
              or lower(special_offer_description) = 'no discount'
            then false
            else true
          end as is_promotional_offer
        , special_offer_modified_at

    from special_offer

)

select * from special_offer_enriched
