with source_history as (

    select * from {{ source('adventureworks_raw', 'humanresources_employeedepartmenthistory') }}

),

renamed as (

    select
        cast(businessentityid as INT) as employee_fk
        , cast(departmentid as INT) as department_fk
        , cast(startdate as DATE) as department_start_date
        , cast(enddate as DATE) as department_end_date
        , cast(modifieddate as TIMESTAMP) as department_history_modified_at

    from source_history

)

select * from renamed
