USE WAREHOUSE LIGHTHOUSE_DEV_WH;
USE DATABASE LIGHTHOUSE_DEV;

SELECT
  'baseline_orders_populated' AS check_name,
  COUNT(*) AS observed_value,
  5 AS expected_value,
  IFF(COUNT(*) = 5, 'pass', 'fail') AS status
FROM RAW.ORDERS
WHERE scenario_id = 'baseline'

UNION ALL

SELECT
  'baseline_vehicle_populated' AS check_name,
  COUNT(*) AS observed_value,
  5 AS expected_value,
  IFF(COUNT(*) = 5, 'pass', 'fail') AS status
FROM RAW.VEHICLE
WHERE scenario_id = 'baseline'

UNION ALL

SELECT
  'freshness_latest_loaded_at_before_cutoff' AS check_name,
  COUNT(*) AS observed_value,
  3 AS expected_value,
  IFF(MAX(loaded_at) < TO_TIMESTAMP_NTZ('2026-07-14 00:00:00'), 'pass', 'fail') AS status
FROM RAW.ORDERS
WHERE scenario_id = 'freshness_stale_orders'

UNION ALL

SELECT
  'baseline_latest_loaded_at_on_expected_day' AS check_name,
  COUNT(*) AS observed_value,
  5 AS expected_value,
  IFF(MAX(loaded_at) >= TO_TIMESTAMP_NTZ('2026-07-14 00:00:00'), 'pass', 'fail') AS status
FROM RAW.ORDERS
WHERE scenario_id = 'baseline'

UNION ALL

SELECT
  'completeness_recent_order_vins' AS check_name,
  COUNT(DISTINCT vin) AS observed_value,
  120 AS expected_value,
  IFF(COUNT(DISTINCT vin) = 120, 'pass', 'fail') AS status
FROM RAW.ORDERS
WHERE scenario_id = 'completeness_missing_100_vins'

UNION ALL

SELECT
  'completeness_matched_vehicle_vins' AS check_name,
  COUNT(DISTINCT vehicle.vin) AS observed_value,
  20 AS expected_value,
  IFF(COUNT(DISTINCT vehicle.vin) = 20, 'pass', 'fail') AS status
FROM RAW.ORDERS AS orders
INNER JOIN RAW.VEHICLE AS vehicle
  ON orders.scenario_id = vehicle.scenario_id
  AND orders.vin = vehicle.vin
WHERE orders.scenario_id = 'completeness_missing_100_vins'

UNION ALL

SELECT
  'completeness_missing_vehicle_vins' AS check_name,
  COUNT(DISTINCT orders.vin) AS observed_value,
  100 AS expected_value,
  IFF(COUNT(DISTINCT orders.vin) = 100, 'pass', 'fail') AS status
FROM RAW.ORDERS AS orders
LEFT JOIN RAW.VEHICLE AS vehicle
  ON orders.scenario_id = vehicle.scenario_id
  AND orders.vin = vehicle.vin
WHERE orders.scenario_id = 'completeness_missing_100_vins'
  AND vehicle.vin IS NULL

UNION ALL

SELECT
  'uniqueness_source_duplicate_key_count' AS check_name,
  COUNT(*) AS observed_value,
  1 AS expected_value,
  IFF(COUNT(*) >= 1, 'pass', 'fail') AS status
FROM (
  SELECT order_id
  FROM RAW.ORDERS
  WHERE scenario_id = 'uniqueness_source_duplicates'
  GROUP BY order_id
  HAVING COUNT(*) > 1
) AS duplicate_keys

UNION ALL

SELECT
  'uniqueness_join_explosion_extra_rows' AS check_name,
  joined.join_rows - source_orders.source_rows AS observed_value,
  1 AS expected_value,
  IFF(joined.join_rows > source_orders.source_rows, 'pass', 'fail') AS status
FROM (
  SELECT COUNT(*) AS join_rows
  FROM RAW.ORDERS AS orders
  LEFT JOIN RAW.VEHICLE AS vehicle
    ON orders.scenario_id = vehicle.scenario_id
    AND orders.vin = vehicle.vin
  WHERE orders.scenario_id = 'uniqueness_join_explosion'
) AS joined
CROSS JOIN (
  SELECT COUNT(*) AS source_rows
  FROM RAW.ORDERS
  WHERE scenario_id = 'uniqueness_join_explosion'
) AS source_orders

UNION ALL

SELECT
  'uniqueness_join_explosion_repeated_vehicle_keys' AS check_name,
  COUNT(*) AS observed_value,
  1 AS expected_value,
  IFF(COUNT(*) >= 1, 'pass', 'fail') AS status
FROM (
  SELECT vin
  FROM RAW.VEHICLE
  WHERE scenario_id = 'uniqueness_join_explosion'
  GROUP BY vin
  HAVING COUNT(*) > 1
) AS repeated_vehicle_keys
ORDER BY check_name;
