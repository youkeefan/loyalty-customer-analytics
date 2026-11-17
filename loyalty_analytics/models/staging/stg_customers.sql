
with source_data as (

    select *
    from {{ source('loyalty_raw', 'customers') }}

),

renamed as (

    select
        trim(customer_id)::varchar(20) as customer_id,
        signup_date::date as signup_date,
        upper(trim(loyalty_tier)) as loyalty_tier,
        upper(trim(customer_status)) as customer_status

    from source_data

)

select *
from renamed
