with customer as (
    select * from {{ ref('stg_sales_customer') }}
)
,

    person as (
        select * from {{ ref('stg_person_person') }}
    )
,

    store as (
        select * from {{ ref('stg_sales_store') }}
    )
,

    customer_enriched as (
        select
            customer.customer_pk
            ,customer.territory_fk
            ,person.person_business_entity_pk
            ,store.store_business_entity_pk
            ,customer.customer_modified_at
            , case
                when person.person_business_entity_pk is not null and store.store_business_entity_pk is not null then 'store_contact'
                when store.store_business_entity_pk is not null then 'store'
                when person.person_business_entity_pk is not null then 'person'
                else 'unknown'
            end as customer_type
            ,coalesce(person.person_full_name, store.store_name) as customer_display_name -- can be a store or a customer base on the customer_type column
            ,person.person_full_name
            ,store.store_name

        from customer
        left join person on person.person_business_entity_pk = customer.person_fk
        left join store on store.store_business_entity_pk = customer.store_fk
    )

select * from customer_enriched