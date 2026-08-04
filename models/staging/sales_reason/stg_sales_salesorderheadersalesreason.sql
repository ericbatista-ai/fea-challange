with source_order_reason as (

    select * from {{ source('adventureworks_raw', 'sales_salesorderheadersalesreason') }}

),

renamed as (

    select
        cast(salesorderid as INT) as sales_order_fk
        , cast(salesreasonid as INT) as sales_reason_fk
        , cast(modifieddate as TIMESTAMP) as order_reason_modified_at

    from source_order_reason

)

select * from renamed
