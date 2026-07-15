SELECT *
FROM {{ ref('mart_duplicate_unique_keys') }}
WHERE scenario_id IN (
    'uniqueness_source_duplicates',
    'uniqueness_join_explosion'
)
