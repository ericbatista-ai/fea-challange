-- Distinct orders in fact_sales must equal raw sales_salesorderheader row count.

with raw_orders as (

    select count(*) as row_count
    from {{ source('adventureworks_raw', 'sales_salesorderheader') }}

),

fact_orders as (

    select count(distinct sales_order_id) as row_count
    from {{ ref('fact_sales') }}

)

select
    raw_orders.row_count as raw_order_count
    , fact_orders.row_count as fact_distinct_order_count
    , fact_orders.row_count - raw_orders.row_count as difference

from raw_orders
cross join fact_orders

where raw_orders.row_count != fact_orders.row_count
