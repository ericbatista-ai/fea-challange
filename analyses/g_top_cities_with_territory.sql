-- Top cities by sales volume, with commercial territory context.
--
-- Cities come from dim_geography (ship-to on the order), not dim_territory.
-- Territory is the sales region on the order header (fact_sales.territory_fk).
-- Preview: dbt show --select g_top_cities_with_territory

select
    g.city
    , g.state_province_name
    , g.country_region_name as ship_to_country
    , t.territory_name
    , t.territory_group
    , t.country_region_name as territory_country
    , count(distinct f.sales_order_id) as number_of_orders
    , sum(f.order_qty) as quantity_purchased
    , sum(f.net_line_total) as total_transaction_value

from {{ ref('fact_sales') }} as f

left join {{ ref('dim_geography') }} as g
    on g.geography_pk = f.geography_fk

left join {{ ref('dim_territory') }} as t
    on t.territory_pk = f.territory_fk

where f.geography_fk is not null

group by
    g.city
    , g.state_province_name
    , g.country_region_name
    , t.territory_name
    , t.territory_group
    , t.country_region_name

qualify row_number() over (order by sum(f.net_line_total) desc) <= 15

order by
    total_transaction_value desc
