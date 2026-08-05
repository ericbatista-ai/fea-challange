-- Bridge row count must equal raw salesorderheadersalesreason.

with raw_bridge as (

    select count(*) as row_count
    from {{ source('adventureworks_raw', 'sales_salesorderheadersalesreason') }}

),

mart_bridge as (

    select count(*) as row_count
    from {{ ref('bridge_sales_order_reason') }}

)

select
    raw_bridge.row_count as raw_row_count
    , mart_bridge.row_count as bridge_row_count
    , mart_bridge.row_count - raw_bridge.row_count as difference

from raw_bridge
cross join mart_bridge

where raw_bridge.row_count != mart_bridge.row_count
