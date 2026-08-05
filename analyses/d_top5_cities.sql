-- Question d
-- Top 5 cities by total transaction value (ship-to geography).
-- Optional filters mirror question c — adjust the where clause as needed.
-- Reason filter uses a semi-join to avoid measure inflation.
-- Preview: dbt show --select d_top5_cities --limit 5

with filtered as (

    select
        f.geography_fk
        , f.sales_order_id
        , f.net_line_total

    from {{ ref('fact_sales') }} as f

    left join {{ ref('dim_product') }} as p
        on p.product_pk = f.product_fk

    left join {{ ref('dim_credit_card') }} as cc
        on cc.credit_card_pk = f.credit_card_fk

    left join {{ ref('dim_customer') }} as c
        on c.customer_pk = f.customer_fk

    where 1 = 1
      and f.geography_fk is not null
    -- and p.product_name = 'Mountain-100 Black, 42'
    -- and cc.card_type = 'ColonialVoice'
    -- and c.customer_display_name = 'Some Customer'
    -- and f.order_year = 2013
    -- and f.order_status_name = 'Shipped'
    -- and exists (
    --     select 1
    --     from {{ ref('bridge_sales_order_reason') }} as b
    --     where b.sales_order_fk = f.sales_order_id
    --       and b.sales_reason_name = 'Promotion'
    -- )

),

by_city as (

    select
        g.city
        , g.state_province_name
        , g.country_region_name
        , sum(f.net_line_total) as total_transaction_value
        , count(distinct f.sales_order_id) as number_of_orders

    from filtered as f

    inner join {{ ref('dim_geography') }} as g
        on g.geography_pk = f.geography_fk

    group by
        g.city
        , g.state_province_name
        , g.country_region_name

)

select
    city
    , state_province_name
    , country_region_name
    , total_transaction_value
    , number_of_orders

from by_city

order by
    total_transaction_value desc

limit 5
