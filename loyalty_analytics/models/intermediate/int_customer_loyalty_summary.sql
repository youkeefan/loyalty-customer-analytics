
with customers as (

    select *
    from {{ ref('stg_customers') }}

),

transaction_summary as (

    select
        customer_id,
        count(distinct transaction_id) as total_transactions,
        sum(spend) as total_spend,
        avg(spend) as average_transaction_value,
        sum(points_earned) as total_points_earned

    from {{ ref('stg_transactions') }}
    group by customer_id

),

points_summary as (

    select
        customer_id,

        sum(
            case
                when activity_type = 'EARN'
                then points_change
                else 0
            end
        ) as ledger_points_earned,

        abs(sum(
            case
                when activity_type = 'REDEEM'
                then points_change
                else 0
            end
        )) as total_points_redeemed,

        sum(points_change) as net_points_movement

    from {{ ref('stg_points_ledger') }}
    group by customer_id

)

select
    c.customer_id,
    c.signup_date,
    c.loyalty_tier,
    c.customer_status,

    coalesce(t.total_transactions, 0) as total_transactions,
    coalesce(t.total_spend, 0) as total_spend,
    coalesce(t.average_transaction_value, 0) as average_transaction_value,
    coalesce(t.total_points_earned, 0) as transaction_points_earned,

    coalesce(p.ledger_points_earned, 0) as ledger_points_earned,
    coalesce(p.total_points_redeemed, 0) as total_points_redeemed,
    coalesce(p.net_points_movement, 0) as net_points_movement

from customers c

left join transaction_summary t
    on c.customer_id = t.customer_id

left join points_summary p
    on c.customer_id = p.customer_id
