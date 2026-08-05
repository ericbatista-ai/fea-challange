-- Sum of net_line_total (all time) must match sum of header SubTotal from staging.
-- Uses one SubTotal per order (max) so header amounts are not multiplied by lines.

with header_total as (

    select coalesce(sum(order_subtotal), 0) as amount
    from {{ ref('stg_sales_salesorderheader') }}

),

fact_total as (

    select coalesce(sum(net_line_total), 0) as amount
    from {{ ref('fact_sales') }}

)

select
    header_total.amount as header_subtotal_sum
    , fact_total.amount as fact_net_line_total_sum
    , abs(fact_total.amount - header_total.amount) as absolute_difference

from header_total
cross join fact_total

where abs(fact_total.amount - header_total.amount) > 0.05
