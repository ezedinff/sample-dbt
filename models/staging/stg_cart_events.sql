WITH source AS (
    SELECT * FROM {{ source('raw', 'raw_events_cart') }}
)

SELECT
    session_id,
    cart_id,
    user_id,
    event_timestamp,
    event_name,
    currency_code,
    cart_value,
    market
FROM source
