with source_person as (
    select * from {{ source('adventureworks_raw', 'person_person') }}
),

renamed as (

    select
        cast(businessentityid as INT) as person_business_entity_pk
        , cast(persontype as STRING) as person_type
        , cast(firstname as STRING) as person_first_name
        , cast(middlename as STRING) as person_middle_name
        , cast(lastname as STRING) as person_last_name

    from source_person
)

select * from renamed