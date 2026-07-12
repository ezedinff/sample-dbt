WITH events AS (
    SELECT * FROM {{ ref('stg_cart_events') }}
),
created AS (
    SELECT
        cart_id,
        session_id,
        user_id,
        market,
        currency_code,
        cart_value,
        MIN(event_timestamp) AS cart_created_at
    FROM events
    WHERE event_name = 'cart_created'
    GROUP BY 1, 2, 3, 4, 5, 6
),
abandoned AS (
    SELECT
        cart_id,
        MIN(event_timestamp) AS cart_abandoned_at
    FROM events
    WHERE event_name = 'cart_abandoned'
    GROUP BY 1
)

SELECT
    created.cart_id,
    created.session_id,
    created.user_id,
    created.market,
    created.currency_code,
    created.cart_value,
    created.cart_created_at,
    abandoned.cart_abandoned_at,
    abandoned.cart_abandoned_at IS NOT NULL AS is_abandoned
FROM created
LEFT JOIN abandoned ON created.cart_id = abandoned.cart_id
