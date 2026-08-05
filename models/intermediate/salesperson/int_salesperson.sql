with salesperson as (

    select * from {{ ref('stg_sales_salesperson') }}

),

person as (

    select
        person_business_entity_pk
        , person_full_name
        , person_first_name
        , person_last_name

    from {{ ref('stg_person_person') }}

),

employee as (

    select * from {{ ref('stg_humanresources_employee') }}

),

current_department as (

    select
        history.employee_fk
        , history.department_fk
        , department.department_name
        , department.department_group_name
        , history.department_start_date
        , row_number() over (
            partition by history.employee_fk
            order by history.department_start_date desc
          ) as assignment_rank

    from {{ ref('stg_humanresources_employeedepartmenthistory') }} as history
    left join {{ ref('stg_humanresources_department') }} as department
        on department.department_pk = history.department_fk

    where history.department_end_date is null

),

salesperson_enriched as (

    select
        salesperson.salesperson_pk
        , person.person_full_name as salesperson_name
        , person.person_first_name as salesperson_first_name
        , person.person_last_name as salesperson_last_name
        , employee.job_title
        , employee.gender
        , employee.hire_date
        , employee.marital_status
        , current_department.department_fk
        , current_department.department_name
        , current_department.department_group_name
        , salesperson.territory_fk
        , salesperson.sales_quota
        , salesperson.bonus
        , salesperson.commission_pct
        , salesperson.sales_ytd
        , salesperson.sales_last_year
        , salesperson.salesperson_modified_at

    from salesperson
    left join person
        on person.person_business_entity_pk = salesperson.salesperson_pk
    left join employee
        on employee.employee_pk = salesperson.salesperson_pk
    left join current_department
        on current_department.employee_fk = salesperson.salesperson_pk
        and current_department.assignment_rank = 1

)

select * from salesperson_enriched
