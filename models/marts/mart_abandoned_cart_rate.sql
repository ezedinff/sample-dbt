SELECT
    market,
    currency_code,
    COUNT(*) AS created_carts,
    SUM(CASE WHEN is_abandoned THEN 1 ELSE 0 END) AS abandoned_carts,
    CAST(SUM(CASE WHEN is_abandoned THEN 1 ELSE 0 END) AS NUMBER) / NULLIF(COUNT(*), 0) AS abandoned_cart_rate
FROM {{ ref('int_abandoned_cart') }}
GROUP BY 1, 2
