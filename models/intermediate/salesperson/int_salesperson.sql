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

salesperson_enriched as (

    select
        salesperson.salesperson_pk
        , person.person_full_name as salesperson_name
        , person.person_first_name as salesperson_first_name
        , person.person_last_name as salesperson_last_name
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

)

select * from salesperson_enriched
