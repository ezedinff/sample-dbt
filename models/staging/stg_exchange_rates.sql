SELECT
    currency_code,
    rate_to_usd,
    valid_on
FROM {{ source('raw', 'raw_exchange_rates') }}
