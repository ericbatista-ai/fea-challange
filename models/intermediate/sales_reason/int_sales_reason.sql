with sales_reason as (

    select * from {{ ref('stg_sales_salesreason') }}

),

sales_reason_enriched as (

    select
        sales_reason_pk
        , sales_reason_name
        , sales_reason_type
        , sales_reason_modified_at

    from sales_reason

)

select * from sales_reason_enriched
