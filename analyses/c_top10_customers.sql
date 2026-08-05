-- Question c
-- Top 10 customers by total transaction value.
-- Optional filters (product, card type, sales reason, date, status, geo)
-- are applied in the `filtered` CTE — uncomment / adjust as needed.
--
-- Reason filter uses a semi-join so multi-reason orders are not double-counted.
-- Preview: dbt show --select c_top10_customers --limit 10

with filtered as (

    select
        f.customer_fk
        , f.sales_order_id
        , f.net_line_total

    from {{ ref('fact_sales') }} as f

    left join {{ ref('dim_product') }} as p
        on p.product_pk = f.product_fk

    left join {{ ref('dim_credit_card') }} as cc
        on cc.credit_card_pk = f.credit_card_fk

    left join {{ ref('dim_geography') }} as g
        on g.geography_pk = f.geography_fk

    where 1 = 1
    -- and p.product_name = 'Mountain-100 Black, 42'
    -- and cc.card_type = 'ColonialVoice'
    -- and f.order_year = 2013
    -- and f.order_status_name = 'Shipped'
    -- and g.city = 'London'
    -- and g.state_province_name = 'England'
    -- and g.country_region_name = 'United Kingdom'
    -- and exists (
    --     select 1
    --     from {{ ref('bridge_sales_order_reason') }} as b
    --     where b.sales_order_fk = f.sales_order_id
    --       and b.sales_reason_name = 'Promotion'
    -- )

),

by_customer as (

    select
        c.customer_display_name
        , c.customer_type
        , sum(f.net_line_total) as total_transaction_value
        , count(distinct f.sales_order_id) as number_of_orders

    from filtered as f

    inner join {{ ref('dim_customer') }} as c
        on c.customer_pk = f.customer_fk

    group by
        c.customer_display_name
        , c.customer_type

)

select
    customer_display_name
    , customer_type
    , total_transaction_value
    , number_of_orders

from by_customer

qualify row_number() over (order by total_transaction_value desc) <= 10


order by
    total_transaction_value desc
