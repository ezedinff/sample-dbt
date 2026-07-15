WITH orders AS (
    SELECT *
    FROM {{ source('raw', 'orders') }}
    WHERE scenario_id IN (
        'baseline',
        'uniqueness_source_duplicates',
        'uniqueness_join_explosion'
    )
),
vehicles AS (
    SELECT *
    FROM {{ source('raw', 'vehicle') }}
    WHERE scenario_id IN (
        'baseline',
        'uniqueness_source_duplicates',
        'uniqueness_join_explosion'
    )
)

SELECT
    orders.scenario_id,
    orders.order_id,
    orders.customer_id,
    orders.vin,
    vehicles.vehicle_id,
    orders.market,
    orders.order_amount,
    orders.source_updated_at AS order_source_updated_at,
    vehicles.source_updated_at AS vehicle_source_updated_at,
    orders.loaded_at AS order_loaded_at,
    vehicles.loaded_at AS vehicle_loaded_at
FROM orders
LEFT JOIN vehicles
    ON orders.vin = vehicles.vin
    AND orders.scenario_id = vehicles.scenario_id
