with source_salesterritory as (

    select * from {{ source('adventureworks_raw', 'sales_salesterritory') }}

),

renamed as (

    select
        cast(territoryid as INT) as territory_pk
        , cast(name as STRING) as territory_name
        , cast(countryregioncode as STRING) as country_region_fk
        , cast(`group` as STRING) as territory_group
        , cast(salesytd as DECIMAL(19, 4)) as sales_ytd
        , cast(saleslastyear as DECIMAL(19, 4)) as sales_last_year
        , cast(costytd as DECIMAL(19, 4)) as cost_ytd
        , cast(costlastyear as DECIMAL(19, 4)) as cost_last_year
        , cast(modifieddate as TIMESTAMP) as territory_modified_at

    from source_salesterritory

)

select * from renamed
