-- Question b
-- Products with the highest average order value (AOV) by month, year,
-- city, state, and country.
--
-- AOV = sum(net_line_total) / count(distinct sales_order_id)
--     = (gross line value - product discounts) / orders in the slice
-- Compile / preview with dbt show --select b_aov_by_product_geo_time --limit 50

select
    p.product_name
    , f.order_year
    , f.order_month
    , f.order_year_month
    , g.city
    , g.state_province_name
    , g.country_region_name
    , count(distinct f.sales_order_id) as number_of_orders
    , sum(f.net_line_total) as total_transaction_value
    , sum(f.net_line_total) / count(distinct f.sales_order_id) as average_order_value

from {{ ref('fact_sales') }} as f

inner join {{ ref('dim_product') }} as p
    on p.product_pk = f.product_fk

left join {{ ref('dim_geography') }} as g
    on g.geography_pk = f.geography_fk

group by
    p.product_name
    , f.order_year
    , f.order_month
    , f.order_year_month
    , g.city
    , g.state_province_name
    , g.country_region_name

order by
    average_order_value desc
