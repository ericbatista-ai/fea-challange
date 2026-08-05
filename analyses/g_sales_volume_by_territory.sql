-- Sales volume by commercial sales territory (region grain).
-- Uses fact_sales.territory_fk → dim_territory (not ship-to geography).
-- territory_group ≈ continent/region (North America, Europe, Pacific)
-- Preview: dbt show --select g_sales_volume_by_territory

select
    t.territory_group
    , t.country_region_name
    , t.territory_name
    , count(distinct f.sales_order_id) as number_of_orders
    , sum(f.order_qty) as quantity_purchased
    , sum(f.net_line_total) as total_transaction_value

from {{ ref('fact_sales') }} as f

inner join {{ ref('dim_territory') }} as t
    on t.territory_pk = f.territory_fk

group by
    t.territory_group
    , t.country_region_name
    , t.territory_name

order by
    total_transaction_value desc
