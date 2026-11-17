
with source_data as (

    select *
    from {{ source('loyalty_raw', 'points_ledger') }}

),

renamed as (

    select
        trim(ledger_id)::varchar(20) as ledger_id,
        trim(customer_id)::varchar(20) as customer_id,
        trim(transaction_id)::varchar(20) as transaction_id,
        activity_date::date as activity_date,
        upper(trim(activity_type))::varchar(20) as activity_type,
        points_change::number(10,0) as points_change

    from source_data

)

select *
from renamed
