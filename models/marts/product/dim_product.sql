with product as (

    select
        product_pk
        , product_name
        , product_number
        , is_manufactured
        , is_finished_good
        , product_color
        , standard_cost
        , list_price
        , product_size
        , product_line
        , product_class
        , product_style
        , product_subcategory_fk
        , product_subcategory_name
        , product_category_fk
        , product_category_name
        , sell_start_at
        , sell_end_at
        , discontinued_at
        , product_modified_at
        , is_sellable

    from {{ ref('int_product') }}

)

select * from product
