-- fact_sales line count must equal raw sales_salesorderdetail row count.

with raw_lines as (

    select count(*) as row_count
    from {{ source('adventureworks_raw', 'sales_salesorderdetail') }}

),

fact_lines as (

    select count(*) as row_count
    from {{ ref('fact_sales') }}

)

select
    raw_lines.row_count as raw_line_count
    , fact_lines.row_count as fact_line_count
    , fact_lines.row_count - raw_lines.row_count as difference

from raw_lines
cross join fact_lines

where raw_lines.row_count != fact_lines.row_count
