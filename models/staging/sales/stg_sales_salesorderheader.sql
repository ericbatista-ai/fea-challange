with source_header as (

    select * from {{ source('adventureworks_raw', 'sales_salesorderheader') }}

),

renamed as (

    select
        cast(salesorderid as INT) as sales_order_pk
        , cast(revisionnumber as INT) as revision_number
        , cast(orderdate as TIMESTAMP) as order_at
        , cast(duedate as TIMESTAMP) as due_at
        , cast(shipdate as TIMESTAMP) as ship_at
        , cast(status as INT) as order_status_id
        , cast(onlineorderflag as BOOLEAN) as is_online_order
        , cast(purchaseordernumber as STRING) as purchase_order_number
        , cast(accountnumber as STRING) as account_number
        , cast(customerid as INT) as customer_fk
        , cast(salespersonid as INT) as sales_person_fk
        , cast(territoryid as INT) as territory_fk
        , cast(billtoaddressid as INT) as bill_to_address_fk
        , cast(shiptoaddressid as INT) as ship_to_address_fk
        , cast(shipmethodid as INT) as ship_method_fk
        , cast(creditcardid as INT) as credit_card_fk
        , cast(creditcardapprovalcode as STRING) as credit_card_approval_code
        , cast(currencyrateid as INT) as currency_rate_fk
        , cast(subtotal as DECIMAL(19, 4)) as order_subtotal
        , cast(taxamt as DECIMAL(19, 4)) as order_tax_amount
        , cast(freight as DECIMAL(19, 4)) as order_freight
        , cast(totaldue as DECIMAL(19, 4)) as order_total_due
        , cast(modifieddate as TIMESTAMP) as order_modified_at

    from source_header

)

select * from renamed
