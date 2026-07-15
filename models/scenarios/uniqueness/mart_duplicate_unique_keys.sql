WITH raw_order_duplicates AS (
    SELECT
        scenario_id,
        order_id AS unique_key,
        'raw_source_duplicate' AS duplicate_family,
        COUNT(*) AS duplicate_count,
        MIN(source_updated_at) AS first_seen_at
    FROM {{ source('raw', 'orders') }}
    WHERE scenario_id IN (
        'uniqueness_source_duplicates',
        'uniqueness_join_explosion'
    )
    GROUP BY 1, 2, 3
    HAVING COUNT(*) > 1
),
join_explosion_duplicates AS (
    SELECT
        scenario_id,
        order_id AS unique_key,
        'join_explosion' AS duplicate_family,
        COUNT(*) AS duplicate_count,
        MIN(order_source_updated_at) AS first_seen_at
    FROM {{ ref('int_orders_vehicle_enriched') }}
    GROUP BY 1, 2, 3
    HAVING COUNT(*) > 1
)

SELECT * FROM raw_order_duplicates
UNION ALL
SELECT * FROM join_explosion_duplicates
