-- Question a
-- Number of orders, quantity purchased, and total transaction value
-- by product, card type, sales reason, sales date, customer, status,
-- city, state, and country.
--
-- Grain note: sales reason is M:N with orders via bridge_sales_order_reason.
-- Joining the bridge attributes measures to each reason on the order.
-- An order with 2 reasons contributes its lines once per reason.
-- Compile: dbt compile --select a_orders_qty_value_by_dims
-- Preview:  dbt show --select a_orders_qty_value_by_dims --limit 100

select
    p.product_name
    , cc.card_type
    , b.sales_reason_name
    , f.order_date
    , c.customer_display_name
    , f.order_status_name
    , g.city
    , g.state_province_name
    , g.country_region_name
    , count(distinct f.sales_order_id) as number_of_orders
    , sum(f.order_qty) as quantity_purchased
    , sum(f.net_line_total) as total_transaction_value

from {{ ref('fact_sales') }} as f

inner join {{ ref('dim_product') }} as p
    on p.product_pk = f.product_fk

left join {{ ref('dim_credit_card') }} as cc
    on cc.credit_card_pk = f.credit_card_fk

left join {{ ref('bridge_sales_order_reason') }} as b
    on b.sales_order_fk = f.sales_order_id

inner join {{ ref('dim_customer') }} as c
    on c.customer_pk = f.customer_fk

left join {{ ref('dim_geography') }} as g
    on g.geography_pk = f.geography_fk

group by
    p.product_name
    , cc.card_type
    , b.sales_reason_name
    , f.order_date
    , c.customer_display_name
    , f.order_status_name
    , g.city
    , g.state_province_name
    , g.country_region_name

order by
    total_transaction_value desc
