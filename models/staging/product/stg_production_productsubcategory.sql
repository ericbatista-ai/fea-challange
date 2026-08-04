with source_productsubcategory as (

    select * from {{ source('adventureworks_raw', 'production_productsubcategory') }}

),

renamed as (

    select
        cast(productsubcategoryid as INT) as product_subcategory_pk
        , cast(productcategoryid as INT) as product_category_fk
        , cast(name as STRING) as product_subcategory_name
        , cast(modifieddate as TIMESTAMP) as product_subcategory_modified_at

    from source_productsubcategory

)

select * from renamed
