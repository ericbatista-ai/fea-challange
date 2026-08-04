with order_reason as (

    select * from {{ ref('stg_sales_salesorderheadersalesreason') }}

),

sales_reason as (

    select
        sales_reason_pk
        , sales_reason_name

    from {{ ref('stg_sales_salesreason') }}

),

bridge as (

    select
        order_reason.sales_order_fk
        , order_reason.sales_reason_fk
        , sales_reason.sales_reason_name
        , order_reason.order_reason_modified_at

    from order_reason
    inner join sales_reason
        on sales_reason.sales_reason_pk = order_reason.sales_reason_fk

)

select * from bridge
