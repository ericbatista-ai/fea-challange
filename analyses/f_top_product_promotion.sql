-- Question f
-- Product with the highest number of units purchased for the Promotion
-- sales reason.
--
-- AdventureWorks note: reason Name = 'On Promotion', ReasonType = 'Promotion'.
-- We filter on type = 'Promotion' (matches the brief wording) via dim_sales_reason.
-- Aggregate qty once per line so multi-reason tags do not inflate units.
-- Preview: dbt show --select f_top_product_promotion

with promotion_orders as (

    select distinct
        b.sales_order_fk as sales_order_id

    from {{ ref('bridge_sales_order_reason') }} as b

    inner join {{ ref('dim_sales_reason') }} as sr
        on sr.sales_reason_pk = b.sales_reason_fk

    where sr.sales_reason_type = 'Promotion'
       or sr.sales_reason_name = 'On Promotion'

),

by_product as (

    select
        p.product_name
        , sum(f.order_qty) as units_purchased
        , count(distinct f.sales_order_id) as number_of_orders
        , sum(f.net_line_total) as total_transaction_value

    from {{ ref('fact_sales') }} as f

    inner join promotion_orders as po
        on po.sales_order_id = f.sales_order_id

    inner join {{ ref('dim_product') }} as p
        on p.product_pk = f.product_fk

    group by
        p.product_name

)

select
    product_name
    , units_purchased
    , number_of_orders
    , total_transaction_value

from by_product

qualify row_number() over (order by units_purchased desc) = 1
