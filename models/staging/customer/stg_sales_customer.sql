with source_sales_customer as (

    select * from {{ source('adventureworks_raw', 'sales_customer') }}

),

renamed as (

    select
        cast(customerid as INT) as customer_pk
        , cast(personid as INT) as person_fk
        , cast(storeid as INT) as store_fk
        , cast(territoryid as INT) as territory_fk
        , cast(rowguid as STRING) as customer_rowguid
        , cast(modifieddate as TIMESTAMP) as customer_modified_at

    from source_sales_customer

)

select * from renamed
