with customer as (
    select
        customer_pk
        ,territory_fk
        ,customer_modified_at
        ,customer_type
        ,customer_display_name -- can be a store or a customer base on the customer_type column
        ,person_full_name
        ,store_name

    from {{ ref('int_dim_customer') }}
)

select * from customer