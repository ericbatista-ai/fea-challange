with customer as (

    select * from {{ ref('stg_sales_customer') }}

),

person as (

    select * from {{ ref('stg_person_person') }}

),

store as (

    select * from {{ ref('stg_sales_store') }}

),

customer_enriched as (

    select
        customer.customer_pk
        , customer.person_fk
        , customer.store_fk
        , customer.territory_fk
        , customer.customer_modified_at
        , case
            when customer.person_fk is not null and customer.store_fk is not null then 'store_contact'
            when customer.store_fk is not null then 'store'
            when customer.person_fk is not null then 'person'
            else 'unknown'
          end as customer_type
        , coalesce(person.person_full_name, store.store_name) as customer_display_name
        , person.person_full_name
        , store.store_name

    from customer
    left join person
        on person.person_business_entity_pk = customer.person_fk
    left join store
        on store.store_business_entity_pk = customer.store_fk

)

select * from customer_enriched
