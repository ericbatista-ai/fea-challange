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

    union all

    select 'sales_person_fk', count(*)
    from {{ ref('fact_sales') }} as f
    left join {{ ref('dim_salesperson') }} as d
        on d.salesperson_pk = f.sales_person_fk
    where f.sales_person_fk is not null
      and d.salesperson_pk is null

    union all

    select 'currency_fk', count(*)
    from {{ ref('fact_sales') }} as f
    left join {{ ref('dim_currency') }} as d
        on d.currency_pk = f.currency_fk
    where f.currency_fk is not null
      and d.currency_pk is null

    union all

    select 'from_currency_fk', count(*)
    from {{ ref('fact_sales') }} as f
    left join {{ ref('dim_currency') }} as d
        on d.currency_pk = f.from_currency_fk
    where f.from_currency_fk is not null
      and d.currency_pk is null

    union all

    select 'special_offer_fk', count(*)
    from {{ ref('fact_sales') }} as f
    left join {{ ref('dim_special_offer') }} as d
        on d.special_offer_pk = f.special_offer_fk
    where f.special_offer_fk is not null
      and d.special_offer_pk is null

)

select
    fk_name
    , orphan_rows

from orphans

where orphan_rows > 0
