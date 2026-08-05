-- How to answer challenge questions with fact_sales (+ dims / bridge).
-- Not executed by dbt — reference only for analysts.

-- a) Orders, qty, transaction value by product, card type, reason, date,
--    customer, status, city, state, country
-- select
--     p.product_name,
--     cc.card_type,
--     sr.sales_reason_name,
--     d.date_day,
--     c.customer_display_name,
--     f.order_status_name,
--     g.city,
--     g.state_province_name,
--     g.country_region_name,
--     count(distinct f.sales_order_id) as number_of_orders,
--     sum(f.order_qty) as quantity_purchased,
--     sum(f.net_line_total) as total_transaction_value
-- from {{ ref('fact_sales') }} f
-- left join {{ ref('dim_product') }} p on p.product_pk = f.product_fk
-- left join {{ ref('dim_credit_card') }} cc on cc.credit_card_pk = f.credit_card_fk
-- left join {{ ref('bridge_sales_order_reason') }} b on b.sales_order_fk = f.sales_order_id
-- left join {{ ref('dim_sales_reason') }} sr on sr.sales_reason_pk = b.sales_reason_fk
-- left join {{ ref('dim_date') }} d on d.date_pk = f.order_date_fk
-- left join {{ ref('dim_customer') }} c on c.customer_pk = f.customer_fk
-- left join {{ ref('dim_geography') }} g on g.geography_pk = f.geography_fk
-- group by 1,2,3,4,5,6,7,8,9;

-- b) AOV by product, month, year, city, state, country
-- AOV = sum(net_line_total) / count(distinct sales_order_id)

-- c) Top 10 customers by sum(net_line_total) with the same filters

-- d) Top 5 cities by sum(net_line_total) with the same filters

-- e) Time series by month/year
-- select order_year, order_month, order_year_month,
--        count(distinct sales_order_id), sum(order_qty), sum(net_line_total)
-- from fact_sales
-- group by 1,2,3;

-- f) Product with most units for Promotion
-- select p.product_name, sum(f.order_qty) as units
-- from fact_sales f
-- inner join bridge_sales_order_reason b on b.sales_order_fk = f.sales_order_id
-- inner join dim_product p on p.product_pk = f.product_fk
-- where b.sales_reason_name = 'Promotion'
-- group by 1
-- order by units desc
-- limit 1;
