with product as (

    select * from {{ ref('stg_production_product') }}

),

subcategory as (

    select * from {{ ref('stg_production_productsubcategory') }}

),

category as (

    select * from {{ ref('stg_production_productcategory') }}

),

product_enriched as (

    select
        product.product_pk
        , product.product_name
        , product.product_number
        , product.is_manufactured
        , product.is_finished_good
        , product.product_color
        , product.standard_cost
        , product.list_price
        , product.product_size
        , product.product_line
        , product.product_class
        , product.product_style
        , product.product_subcategory_fk
        , subcategory.product_subcategory_name
        , subcategory.product_category_fk
        , category.product_category_name
        , product.sell_start_at
        , product.sell_end_at
        , product.discontinued_at
        , product.product_modified_at
        , case
            when product.sell_end_at is not null
                and product.sell_end_at <= current_timestamp()
            then false
            when product.discontinued_at is not null
            then false
            else true
          end as is_sellable

    from product
    left join subcategory
        on subcategory.product_subcategory_pk = product.product_subcategory_fk
    left join category
        on category.product_category_pk = subcategory.product_category_fk

)

select * from product_enriched
