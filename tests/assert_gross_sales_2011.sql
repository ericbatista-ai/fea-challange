-- Gross sales audit for 2011 (CEO / accounting alignment).
--
-- Challenge text cites $12,646,112.16, but that figure does not match the
-- AdventureWorks-for-Postgres dataset used in this project.
--
-- Expected value used here: $12,641,672.21
-- Validated against local PostgreSQL:
--   SUM(sales.salesorderheader.subtotal) WHERE year(orderdate) = 2011
--   and against recomputed line totals / Databricks fact_sales.
-- Doc figure vs Postgres delta is ~$4,439.95 (source/edition difference, not a model bug).
--
-- Measure: sum(net_line_total) = AW LineTotal (gross revenue - product discounts).
-- Test fails when any row is returned.

with sales_2011 as (

    select
        coalesce(sum(net_line_total), 0) as gross_sales_2011

    from {{ ref('fact_sales') }}

    where order_year = 2011

)

select
    gross_sales_2011
    , cast(12641672.21 as DECIMAL(19, 4)) as expected_gross_sales_2011
    , abs(gross_sales_2011 - cast(12641672.21 as DECIMAL(19, 4))) as absolute_difference

from sales_2011

where abs(gross_sales_2011 - cast(12641672.21 as DECIMAL(19, 4))) > 0.01
