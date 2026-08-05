-- Highest sales volume by country (from dim_territory country_region).
-- Commercial territory country — not ship-to address country.
-- Preview: dbt show --select g_sales_volume_by_territory_country

select
    t.country_region_name
    , t.country_region_fk
    , count(distinct t.territory_pk) as territory_count
    , count(distinct f.sales_order_id) as number_of_orders
    , sum(f.order_qty) as quantity_purchased
    , sum(f.net_line_total) as total_transaction_value

from {{ ref('fact_sales') }} as f

inner join {{ ref('dim_territory') }} as t
    on t.territory_pk = f.territory_fk

group by
    t.country_region_name
    , t.country_region_fk

order by
    total_transaction_value desc
