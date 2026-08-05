with source_employee as (

    select * from {{ source('adventureworks_raw', 'humanresources_employee') }}

),

renamed as (

    select
        cast(businessentityid as INT) as employee_pk
        , cast(jobtitle as STRING) as job_title
        , cast(gender as STRING) as gender
        , cast(hiredate as DATE) as hire_date
        , cast(maritalstatus as STRING) as marital_status
        , cast(salariedflag as BOOLEAN) as is_salaried
        , cast(currentflag as BOOLEAN) as is_current_employee
        , cast(modifieddate as TIMESTAMP) as employee_modified_at

    from source_employee

)

select * from renamed
