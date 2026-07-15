SELECT scenario_id
FROM {{ ref('mart_missing_vehicle_vins') }}
WHERE scenario_id = 'completeness_missing_100_vins'
GROUP BY 1
HAVING COUNT(*) = 100
