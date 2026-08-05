with source_detail as (

    select * from {{ source('adventureworks_raw', 'sales_salesorderdetail') }}

),

renamed as (

    select
        cast(salesorderid as INT) as sales_order_fk
        , cast(salesorderdetailid as INT) as sales_order_detail_pk
        , cast(carriertrackingnumber as STRING) as carrier_tracking_number
        , cast(orderqty as INT) as order_qty
        , cast(productid as INT) as product_fk
        , cast(specialofferid as INT) as special_offer_fk
        , cast(unitprice as DECIMAL(19, 4)) as unit_price
        , cast(unitpricediscount as DECIMAL(19, 4)) as unit_price_discount_rate
        , cast(
            cast(unitprice as DECIMAL(19, 4))
            * (1 - cast(unitpricediscount as DECIMAL(19, 4)))
            * cast(orderqty as INT)
            as DECIMAL(19, 4)
          ) as line_total
        , cast(modifieddate as TIMESTAMP) as order_detail_modified_at

    from source_detail

)

select * from renamed
