
select
    customer_id,
    signup_date,
    loyalty_tier,
    customer_status

from {{ ref('int_customer_loyalty_summary') }}
