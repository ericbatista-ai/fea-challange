with salesperson as (

    select
        salesperson_pk
        , salesperson_name
        , salesperson_first_name
        , salesperson_last_name
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
