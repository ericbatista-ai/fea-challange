with customer as (

    select
        customer_pk
        , territory_fk
        , customer_modified_at
        , customer_type
        , customer_display_name
        , person_full_name
        , store_name

    from {{ ref('int_customer') }}

)

select * from customer
