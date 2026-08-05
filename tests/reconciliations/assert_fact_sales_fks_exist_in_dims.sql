-- No orphan FKs on fact_sales for required dimensions.
-- Returns one row per broken relationship type.

with orphans as (

    select 'customer_fk' as fk_name, count(*) as orphan_rows
    from {{ ref('fact_sales') }} as f
    left join {{ ref('dim_customer') }} as d
        on d.customer_pk = f.customer_fk
    where d.customer_pk is null

    union all

    select 'product_fk', count(*)
    from {{ ref('fact_sales') }} as f
    left join {{ ref('dim_product') }} as d
        on d.product_pk = f.product_fk
    where d.product_pk is null

    union all

    select 'order_date_fk', count(*)
    from {{ ref('fact_sales') }} as f
    left join {{ ref('dim_date') }} as d
        on d.date_pk = f.order_date_fk
    where d.date_pk is null

    union all

    select 'geography_fk', count(*)
    from {{ ref('fact_sales') }} as f
    left join {{ ref('dim_geography') }} as d
        on d.geography_pk = f.geography_fk
    where f.geography_fk is not null
      and d.geography_pk is null

    union all

    select 'credit_card_fk', count(*)
    from {{ ref('fact_sales') }} as f
    left join {{ ref('dim_credit_card') }} as d
        on d.credit_card_pk = f.credit_card_fk
    where f.credit_card_fk is not null
      and d.credit_card_pk is null

)

select
    fk_name
    , orphan_rows

from orphans

where orphan_rows > 0
