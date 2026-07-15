SELECT
    scenario_id,
    record_source,
    ingest_batch_id,
    vin,
    vehicle_id,
    make,
    model,
    market,
    source_updated_at,
    loaded_at
FROM {{ source('raw', 'vehicle') }}
WHERE scenario_id IN ('baseline', 'completeness_missing_100_vins')
