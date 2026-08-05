-- Question e
-- Number of orders, quantity purchased, and total transaction value
-- by month and year (time-series friendly).
-- Preview: dbt show --select e_timeseries_month_year --limit 100

select
    f.order_year
    , f.order_month
    , f.order_year_month
    , count(distinct f.sales_order_id) as number_of_orders
    , sum(f.order_qty) as quantity_purchased
    , sum(f.net_line_total) as total_transaction_value

from {{ ref('fact_sales') }} as f

group by
    f.order_year
    , f.order_month
    , f.order_year_month

order by
    f.order_year
    , f.order_month
