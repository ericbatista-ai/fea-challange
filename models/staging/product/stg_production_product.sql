with source_product as (

    select * from {{ source('adventureworks_raw', 'production_product') }}

),

renamed as (

    select
        cast(productid as INT) as product_pk
        , cast(name as STRING) as product_name
        , cast(productnumber as STRING) as product_number
        , cast(makeflag as BOOLEAN) as is_manufactured
        , cast(finishedgoodsflag as BOOLEAN) as is_finished_good
        , cast(color as STRING) as product_color
        , cast(safetystocklevel as INT) as safety_stock_level
        , cast(reorderpoint as INT) as reorder_point
        , cast(standardcost as DECIMAL(19, 4)) as standard_cost
        , cast(listprice as DECIMAL(19, 4)) as list_price
        , cast(size as STRING) as product_size
        , cast(sizeunitmeasurecode as STRING) as size_unit_measure_code
        , cast(weightunitmeasurecode as STRING) as weight_unit_measure_code
        , cast(weight as DECIMAL(8, 2)) as product_weight
        , cast(daystomanufacture as INT) as days_to_manufacture
        , cast(productline as STRING) as product_line
        , cast(class as STRING) as product_class
        , cast(style as STRING) as product_style
        , cast(productsubcategoryid as INT) as product_subcategory_fk
        , cast(productmodelid as INT) as product_model_fk
        , cast(sellstartdate as TIMESTAMP) as sell_start_at
        , cast(sellenddate as TIMESTAMP) as sell_end_at
        , cast(discontinueddate as TIMESTAMP) as discontinued_at
        , cast(modifieddate as TIMESTAMP) as product_modified_at

    from source_product

)

select * from renamed
