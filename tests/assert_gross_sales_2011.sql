-- CEO audit (Carlos Silveira): gross sales in 2011 = $12,646,112.16
-- Uses net_line_total (AW LineTotal = gross revenue - product discounts).
-- Test fails when any row is returned.

with sales_2011 as (

    select
        coalesce(sum(net_line_total), 0) as gross_sales_2011

    from {{ ref('fact_sales') }}

    where order_year = 2011

)

select
    gross_sales_2011
    , cast(12646112.16 as DECIMAL(19, 4)) as expected_gross_sales_2011
    , abs(gross_sales_2011 - cast(12646112.16 as DECIMAL(19, 4))) as absolute_difference

from sales_2011

where abs(gross_sales_2011 - cast(12646112.16 as DECIMAL(19, 4))) > 0.01
