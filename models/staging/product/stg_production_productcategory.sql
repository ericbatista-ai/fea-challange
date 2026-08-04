with source_productcategory as (

    select * from {{ source('adventureworks_raw', 'production_productcategory') }}

),

renamed as (

    select
        cast(productcategoryid as INT) as product_category_pk
        , cast(name as STRING) as product_category_name
        , cast(modifieddate as TIMESTAMP) as product_category_modified_at

    from source_productcategory

)

select * from renamed
