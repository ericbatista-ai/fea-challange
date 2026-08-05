-- Staging sales tables must preserve raw row counts (1:1 landing check).

with checks as (

    select
        'stg_sales_salesorderdetail' as model_name
        , (select count(*) from {{ source('adventureworks_raw', 'sales_salesorderdetail') }}) as raw_count
        , (select count(*) from {{ ref('stg_sales_salesorderdetail') }}) as stg_count

    union all

    select
        'stg_sales_salesorderheader'
        , (select count(*) from {{ source('adventureworks_raw', 'sales_salesorderheader') }})
        , (select count(*) from {{ ref('stg_sales_salesorderheader') }})

    union all

    select
        'stg_sales_customer'
        , (select count(*) from {{ source('adventureworks_raw', 'sales_customer') }})
        , (select count(*) from {{ ref('stg_sales_customer') }})

    union all

    select
        'stg_production_product'
        , (select count(*) from {{ source('adventureworks_raw', 'production_product') }})
        , (select count(*) from {{ ref('stg_production_product') }})

    union all

    select
        'stg_sales_creditcard'
        , (select count(*) from {{ source('adventureworks_raw', 'sales_creditcard') }})
        , (select count(*) from {{ ref('stg_sales_creditcard') }})

    union all

    select
        'stg_sales_salesreason'
        , (select count(*) from {{ source('adventureworks_raw', 'sales_salesreason') }})
        , (select count(*) from {{ ref('stg_sales_salesreason') }})

    union all

    select
        'stg_sales_salesperson'
        , (select count(*) from {{ source('adventureworks_raw', 'sales_salesperson') }})
        , (select count(*) from {{ ref('stg_sales_salesperson') }})

    union all

    select
        'stg_sales_currency'
        , (select count(*) from {{ source('adventureworks_raw', 'sales_currency') }})
        , (select count(*) from {{ ref('stg_sales_currency') }})

    union all

    select
        'stg_sales_currencyrate'
        , (select count(*) from {{ source('adventureworks_raw', 'sales_currencyrate') }})
        , (select count(*) from {{ ref('stg_sales_currencyrate') }})

    union all

    select
        'stg_sales_specialoffer'
        , (select count(*) from {{ source('adventureworks_raw', 'sales_specialoffer') }})
        , (select count(*) from {{ ref('stg_sales_specialoffer') }})

    union all

    select
        'stg_humanresources_employee'
        , (select count(*) from {{ source('adventureworks_raw', 'humanresources_employee') }})
        , (select count(*) from {{ ref('stg_humanresources_employee') }})

    union all

    select
        'stg_humanresources_department'
        , (select count(*) from {{ source('adventureworks_raw', 'humanresources_department') }})
        , (select count(*) from {{ ref('stg_humanresources_department') }})

    union all

    select
        'stg_humanresources_employeedepartmenthistory'
        , (select count(*) from {{ source('adventureworks_raw', 'humanresources_employeedepartmenthistory') }})
        , (select count(*) from {{ ref('stg_humanresources_employeedepartmenthistory') }})

)

select
    model_name
    , raw_count
    , stg_count
    , stg_count - raw_count as difference

from checks

where raw_count != stg_count
