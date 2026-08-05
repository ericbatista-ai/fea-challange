with source_salesperson as (

    select * from {{ source('adventureworks_raw', 'sales_salesperson') }}

),

renamed as (

    select
        cast(businessentityid as INT) as salesperson_pk
        , cast(territoryid as INT) as territory_fk
        , cast(salesquota as DECIMAL(19, 4)) as sales_quota
        , cast(bonus as DECIMAL(19, 4)) as bonus
        , cast(commissionpct as DECIMAL(10, 4)) as commission_pct
        , cast(salesytd as DECIMAL(19, 4)) as sales_ytd
        , cast(saleslastyear as DECIMAL(19, 4)) as sales_last_year
        , cast(modifieddate as TIMESTAMP) as salesperson_modified_at

    from source_salesperson

)

select * from renamed
