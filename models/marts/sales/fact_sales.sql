with sales as (

    select
        sales_order_detail_pk
        , sales_order_id
        , customer_fk
        , product_fk
        , special_offer_fk
        , credit_card_fk
        , sales_person_fk
        , currency_rate_fk
        , currency_fk
        , from_currency_fk
        , order_date_fk
        , geography_fk
        , ship_to_address_fk
        , bill_to_address_fk
        , territory_fk
        , order_date
        , order_year
        , order_month
        , order_year_month
        , order_status_id
        , order_status_name
        , is_online_order
        , order_at
        , due_at
        , ship_at
        , order_qty
        , unit_price
        , unit_price_discount_rate
        , gross_line_value
        , discount_amount
        , net_line_total
        , order_subtotal
        , order_tax_amount
        , order_freight
        , order_total_due
        , average_rate
        , end_of_day_rate
        , order_detail_modified_at
        , order_modified_at

    from {{ ref('int_fact_sales') }}

)

select * from sales
