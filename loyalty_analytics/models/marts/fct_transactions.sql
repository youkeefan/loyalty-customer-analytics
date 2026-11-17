
select
    transaction_id,
    customer_id,
    transaction_date,
    spend,
    points_earned

from {{ ref('stg_transactions') }}
