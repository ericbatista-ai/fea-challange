with bridge as (

    select
        sales_order_fk
        , sales_reason_fk
        , sales_reason_name
        , order_reason_modified_at

    from {{ ref('int_bridge_sales_order_reason') }}

)

select * from bridge
