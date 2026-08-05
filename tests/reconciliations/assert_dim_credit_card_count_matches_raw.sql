-- dim_credit_card row count must equal raw sales_creditcard.

with raw_dim as (

    select count(*) as row_count
    from {{ source('adventureworks_raw', 'sales_creditcard') }}

),

mart_dim as (

    select count(*) as row_count
    from {{ ref('dim_credit_card') }}

)

select
    raw_dim.row_count as raw_row_count
    , mart_dim.row_count as dim_row_count
    , mart_dim.row_count - raw_dim.row_count as difference

from raw_dim
cross join mart_dim

where raw_dim.row_count != mart_dim.row_count
