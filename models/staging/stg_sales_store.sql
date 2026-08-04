with source_sales_store as (
    select * from {{ source('adventureworks_raw', 'sales_store') }}
),

renamed as (
    select
        cast(businessentityid as INT) as store_business_entity_pk
        , cast(name as STRING) as store_name

    from source_sales_store
)

select * from renamed