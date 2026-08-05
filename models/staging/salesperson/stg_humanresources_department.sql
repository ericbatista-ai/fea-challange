with source_department as (

    select * from {{ source('adventureworks_raw', 'humanresources_department') }}

),

renamed as (

    select
        cast(departmentid as INT) as department_pk
        , cast(name as STRING) as department_name
        , cast(groupname as STRING) as department_group_name
        , cast(modifieddate as TIMESTAMP) as department_modified_at

    from source_department

)

select * from renamed
