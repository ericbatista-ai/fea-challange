with salesperson as (

    select
        salesperson_pk
        , salesperson_name
        , salesperson_first_name
        , salesperson_last_name
        , job_title
        , gender
        , hire_date
        , marital_status
        , department_fk
        , department_name
        , department_group_name
        , territory_fk
        , sales_quota
        , bonus
        , commission_pct
        , sales_ytd
        , sales_last_year
        , salesperson_modified_at

    from {{ ref('int_salesperson') }}

)

select * from salesperson
