
WITH customer_metrics AS (

    SELECT
        CUSTOMER_ID,
        TOTAL_TRANSACTIONS,
        TOTAL_SPEND,
        AVERAGE_TRANSACTION_VALUE,
        TRANSACTION_POINTS_EARNED,
        LEDGER_POINTS_EARNED,
        TOTAL_POINTS_REDEEMED,
        NET_POINTS_MOVEMENT

    FROM {{ ref('int_customer_loyalty_summary') }}

),

customer_scores AS (

    SELECT
        *,

        NTILE(4) OVER (
            ORDER BY TOTAL_SPEND, CUSTOMER_ID
        ) AS SPEND_QUARTILE,

        NTILE(4) OVER (
            ORDER BY TOTAL_TRANSACTIONS, CUSTOMER_ID
        ) AS FREQUENCY_QUARTILE

    FROM customer_metrics

)

SELECT
    *,

    CASE
        WHEN SPEND_QUARTILE = 4
             AND FREQUENCY_QUARTILE = 4
            THEN 'HIGH_VALUE'

        WHEN SPEND_QUARTILE = 4
             AND FREQUENCY_QUARTILE < 4
            THEN 'BIG_SPENDER'

        WHEN SPEND_QUARTILE < 4
             AND FREQUENCY_QUARTILE = 4
            THEN 'FREQUENT_CUSTOMER'

        ELSE 'DEVELOPING_CUSTOMER'
    END AS CUSTOMER_SEGMENT

FROM customer_scores
