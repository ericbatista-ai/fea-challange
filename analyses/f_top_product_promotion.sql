-- Question f
-- Product with the highest number of units purchased for sales reason
-- "Promotion".
--
-- Rule: include order lines whose header is tagged Promotion on the bridge.
-- Aggregate qty once per line (semi-join / distinct filter) so multi-reason
-- tags do not inflate units.
-- Preview: dbt show --select f_top_product_promotion --limit 10

with promotion_orders as (

    select distinct
        sales_order_fk as sales_order_id

    from {{ ref('bridge_sales_order_reason') }}

    where sales_reason_name = 'Promotion'

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

order by
    units_purchased desc

limit 1
