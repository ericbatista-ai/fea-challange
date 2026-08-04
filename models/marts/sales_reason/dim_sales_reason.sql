with sales_reason as (

    select
        sales_reason_pk
        , sales_reason_name
        , sales_reason_type
        , sales_reason_modified_at

    from {{ ref('int_sales_reason') }}

)

select * from sales_reason
