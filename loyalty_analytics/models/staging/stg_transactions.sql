
with source_data as (

    select *
    from {{ source('loyalty_raw', 'transactions') }}

),

renamed as (

    select
        trim(transaction_id)::varchar(20) as transaction_id,
        trim(customer_id)::varchar(20) as customer_id,
        transaction_date::date as transaction_date,
        spend::number(10,2) as spend,
        points_earned::number(10,0) as points_earned

    from source_data

)

select *
from renamed
