with source_specialoffer as (

    select * from {{ source('adventureworks_raw', 'sales_specialoffer') }}

),

renamed as (

    select
        cast(specialofferid as INT) as special_offer_pk
        , cast(description as STRING) as special_offer_description
        , cast(discountpct as DECIMAL(10, 4)) as discount_pct
        , cast(type as STRING) as special_offer_type
        , cast(category as STRING) as special_offer_category
        , cast(startdate as TIMESTAMP) as offer_start_at
        , cast(enddate as TIMESTAMP) as offer_end_at
        , cast(minqty as INT) as min_qty
        , cast(maxqty as INT) as max_qty
        , cast(modifieddate as TIMESTAMP) as special_offer_modified_at

    from source_specialoffer

)

select * from renamed
