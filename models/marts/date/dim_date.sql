-- dim_date is generated (no raw source table).
-- Step: dbt_utils.date_spine creates one row per calendar day;
-- then we derive attributes used in questions a–e (date, month, year).

with date_spine as (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2010-01-01' as date)",
        end_date="cast('2015-01-01' as date)"
    ) }}

),

renamed as (

    select
        cast(date_day as DATE) as date_day
        , cast(date_format(date_day, 'yyyyMMdd') as INT) as date_pk
        , cast(year(date_day) as INT) as calendar_year
        , cast(month(date_day) as INT) as calendar_month
        , cast(day(date_day) as INT) as calendar_day
        , cast(quarter(date_day) as INT) as calendar_quarter
        , cast(dayofweek(date_day) as INT) as day_of_week
        , cast(date_format(date_day, 'EEEE') as STRING) as day_name
        , cast(date_format(date_day, 'MMM') as STRING) as month_name_short
        , cast(date_format(date_day, 'MMMM') as STRING) as month_name
        , cast(date_format(date_day, 'yyyy-MM') as STRING) as year_month
        , cast(trunc(date_day, 'MM') as DATE) as month_start_date
        , cast(last_day(date_day) as DATE) as month_end_date
        , case
            when dayofweek(date_day) in (1, 7) then true
            else false
          end as is_weekend

    from date_spine

)

select * from renamed
