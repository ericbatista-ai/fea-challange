with order_detail as (

    select * from {{ ref('stg_sales_salesorderdetail') }}

),

order_header as (

    select * from {{ ref('stg_sales_salesorderheader') }}

),

ship_address as (

    select
        address_pk
        , city
        , state_province_fk

    from {{ ref('stg_person_address') }}

),

state_province as (

    select
        state_province_pk
        , country_region_fk

    from {{ ref('stg_person_stateprovince') }}

),

sales_lines as (

    select
        -- degenerate / grain
        order_detail.sales_order_detail_pk
        , order_detail.sales_order_fk as sales_order_id

        -- dimension FKs
        , order_header.customer_fk
        , order_detail.product_fk
        , order_header.credit_card_fk
        , cast(date_format(order_header.order_at, 'yyyyMMdd') as INT) as order_date_fk
        , cast(
            md5(
                lower(trim(ship_address.city))
                || '|'
                || cast(ship_address.state_province_fk as STRING)
                || '|'
                || upper(trim(state_province.country_region_fk))
            ) as STRING
          ) as geography_fk
        , order_header.ship_to_address_fk
        , order_header.bill_to_address_fk
        , order_header.territory_fk

        -- date helpers (also joinable to dim_date)
        , cast(order_header.order_at as DATE) as order_date
        , cast(year(order_header.order_at) as INT) as order_year
        , cast(month(order_header.order_at) as INT) as order_month
        , cast(date_format(order_header.order_at, 'yyyy-MM') as STRING) as order_year_month

        -- status (degenerate dimension)
        , order_header.order_status_id
        , case order_header.order_status_id
            when 1 then 'In process'
            when 2 then 'Approved'
            when 3 then 'Backordered'
            when 4 then 'Rejected'
            when 5 then 'Shipped'
            when 6 then 'Cancelled'
            else 'Unknown'
          end as order_status_name

        , order_header.is_online_order
        , order_header.order_at
        , order_header.due_at
        , order_header.ship_at

        -- measures
        , order_detail.order_qty
        , order_detail.unit_price
        , order_detail.unit_price_discount_rate
        , cast(
            order_detail.unit_price * order_detail.order_qty as DECIMAL(19, 4)
          ) as gross_line_value
        , cast(
            order_detail.unit_price
            * order_detail.unit_price_discount_rate
            * order_detail.order_qty as DECIMAL(19, 4)
          ) as discount_amount
        -- AW LineTotal = UnitPrice * (1 - UnitPriceDiscount) * OrderQty
        -- = gross revenue - product discounts (transaction value / AOV numerator)
        , order_detail.line_total as net_line_total

        , order_header.order_subtotal
        , order_header.order_tax_amount
        , order_header.order_freight
        , order_header.order_total_due
        , order_detail.order_detail_modified_at
        , order_header.order_modified_at

    from order_detail
    inner join order_header
        on order_header.sales_order_pk = order_detail.sales_order_fk
    left join ship_address
        on ship_address.address_pk = order_header.ship_to_address_fk
    left join state_province
        on state_province.state_province_pk = ship_address.state_province_fk

)

select * from sales_lines
