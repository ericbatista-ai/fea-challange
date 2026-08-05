-- Debug: 2011 gross sales audit
-- Source-of-truth expected (Postgres AW): 12,641,672.21
-- Challenge brief figure (not used): 12,646,112.16  (diff ~4,439.95 vs this dataset)
--
-- Run pieces in dbt Cloud / Databricks if totals drift again.

-- ---------------------------------------------------------------------------
-- 1) Fact measure vs header SubTotal (once per order — do not sum SubTotal on lines)
-- ---------------------------------------------------------------------------
with fact_2011 as (

    select
        sum(net_line_total) as sum_net_line_total
        , sum(gross_line_value) as sum_gross_line_value
        , sum(discount_amount) as sum_discount_amount
        , count(*) as line_count
        , count(distinct sales_order_id) as order_count

    from {{ ref('fact_sales') }}

    where order_year = 2011

),

header_2011 as (

    select
        sum(order_subtotal) as sum_order_subtotal
        , count(*) as order_count

    from {{ ref('stg_sales_salesorderheader') }}

    where year(order_at) = 2011

)

select
    'fact_net_line_total' as metric
    , f.sum_net_line_total as amount
    , cast(12641672.21 as DECIMAL(19, 4)) as expected
    , f.sum_net_line_total - cast(12641672.21 as DECIMAL(19, 4)) as diff
    , f.line_count
    , f.order_count
from fact_2011 f

union all

select
    'header_subtotal'
    , h.sum_order_subtotal
    , cast(12641672.21 as DECIMAL(19, 4))
    , h.sum_order_subtotal - cast(12641672.21 as DECIMAL(19, 4))
    , null
    , h.order_count
from header_2011 h

union all

select
    'fact_gross_minus_discount'
    , f.sum_gross_line_value - f.sum_discount_amount
    , cast(12641672.21 as DECIMAL(19, 4))
    , (f.sum_gross_line_value - f.sum_discount_amount) - cast(12641672.21 as DECIMAL(19, 4))
    , f.line_count
    , f.order_count
from fact_2011 f

-- ---------------------------------------------------------------------------
-- 2) Raw recompute with SQL Server-like precision (38,6) vs our DECIMAL(19,4)
-- ---------------------------------------------------------------------------
-- with raw_lines as (
--     select
--         d.salesorderid
--         , cast(d.unitprice as DECIMAL(38, 6))
--             * (cast(1.0 as DECIMAL(38, 6)) - cast(d.unitpricediscount as DECIMAL(38, 6)))
--             * cast(d.orderqty as DECIMAL(38, 6)) as line_total_38_6
--         , cast(d.unitprice as DECIMAL(19, 4))
--             * (1 - cast(d.unitpricediscount as DECIMAL(19, 4)))
--             * cast(d.orderqty as INT) as line_total_19_4
--     from {{ source('adventureworks_raw', 'sales_salesorderdetail') }} d
--     inner join {{ source('adventureworks_raw', 'sales_salesorderheader') }} h
--         on h.salesorderid = d.salesorderid
--     where year(h.orderdate) = 2011
-- )
-- select
--     sum(line_total_38_6) as sum_38_6
--     , sum(line_total_19_4) as sum_19_4
--     , sum(line_total_38_6) - sum(line_total_19_4) as precision_diff
-- from raw_lines

-- ---------------------------------------------------------------------------
-- 3) Orders where header SubTotal <> sum(lines) — data quality / rounding
-- ---------------------------------------------------------------------------
-- with line_sum as (
--     select
--         sales_order_id
--         , sum(net_line_total) as sum_lines
--         , max(order_subtotal) as header_subtotal
--     from {{ ref('fact_sales') }}
--     where order_year = 2011
--     group by sales_order_id
-- )
-- select
--     sales_order_id
--     , sum_lines
--     , header_subtotal
--     , sum_lines - header_subtotal as line_vs_header_diff
-- from line_sum
-- where abs(sum_lines - header_subtotal) > 0.01
-- order by abs(sum_lines - header_subtotal) desc
-- limit 50

-- ---------------------------------------------------------------------------
-- 4) Date boundary: year(order_at) vs cast(order_at as date) year
--    (timezone / timestamp edge cases on Dec 31 / Jan 1)
-- ---------------------------------------------------------------------------
-- select
--     year(order_at) as year_ts
--     , year(cast(order_at as date)) as year_date
--     , count(*) as orders
--     , sum(order_subtotal) as subtotal
-- from {{ ref('stg_sales_salesorderheader') }}
-- where year(order_at) = 2011 or year(cast(order_at as date)) = 2011
-- group by 1, 2
