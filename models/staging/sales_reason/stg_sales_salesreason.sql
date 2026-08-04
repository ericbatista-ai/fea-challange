with source_salesreason as (

    select * from {{ source('adventureworks_raw', 'sales_salesreason') }}

),

renamed as (

    select
        cast(salesreasonid as INT) as sales_reason_pk
        , cast(name as STRING) as sales_reason_name
        , cast(reasontype as STRING) as sales_reason_type
        , cast(modifieddate as TIMESTAMP) as sales_reason_modified_at

    from source_salesreason

)

select * from renamed
