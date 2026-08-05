-- dim_salesperson row count must equal raw sales_salesperson.

with raw_dim as (

    select count(*) as row_count
    from {{ source('adventureworks_raw', 'sales_salesperson') }}

),

mart_dim as (

    select count(*) as row_count
    from {{ ref('dim_salesperson') }}

)

select
    raw_dim.row_count as raw_row_count
    , mart_dim.row_count as dim_row_count
    , mart_dim.row_count - raw_dim.row_count as difference

from raw_dim
cross join mart_dim

where raw_dim.row_count != mart_dim.row_count
