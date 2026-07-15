-- Load one Lighthouse sandbox scenario after staging its CSV files.
-- For local Docker/LocalStack runs, prefer:
--   python scripts/load_snowflake_scenarios.py --reset --verify
--
-- 1. Run sql/bootstrap/create_raw_tables.sql.
-- 2. Stage fixture files under @~/lighthouse_scenarios/<scenario_id>/.
-- 3. Replace <scenario_id> below with one of:
--    baseline
--    freshness_stale_orders
--    completeness_missing_100_vins
--    uniqueness_source_duplicates
--    uniqueness_join_explosion
--
-- Example SnowSQL staging command from this repo:
-- PUT file://seeds/scenarios/completeness_missing_100_vins/orders.csv @~/lighthouse_scenarios/completeness_missing_100_vins AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
-- PUT file://seeds/scenarios/completeness_missing_100_vins/vehicle.csv @~/lighthouse_scenarios/completeness_missing_100_vins AUTO_COMPRESS=FALSE OVERWRITE=TRUE;

USE WAREHOUSE LIGHTHOUSE_DEV_WH;
USE DATABASE LIGHTHOUSE_DEV;

SET scenario_id = '<scenario_id>';

DELETE FROM RAW.ORDERS WHERE scenario_id = $scenario_id;
DELETE FROM RAW.VEHICLE WHERE scenario_id = $scenario_id;

COPY INTO RAW.ORDERS (
  scenario_id,
  record_source,
  ingest_batch_id,
  order_id,
  customer_id,
  vin,
  market,
  order_status,
  order_amount,
  source_updated_at,
  loaded_at
)
FROM @~/lighthouse_scenarios/<scenario_id>/orders.csv
FILE_FORMAT = (FORMAT_NAME = RAW.LIGHTHOUSE_SCENARIO_CSV)
ON_ERROR = ABORT_STATEMENT;

-- Run this COPY only for scenarios with a vehicle.csv fixture.
COPY INTO RAW.VEHICLE (
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
)
FROM @~/lighthouse_scenarios/<scenario_id>/vehicle.csv
FILE_FORMAT = (FORMAT_NAME = RAW.LIGHTHOUSE_SCENARIO_CSV)
ON_ERROR = ABORT_STATEMENT;

INSERT INTO RAW.SCENARIO_LOAD_AUDIT
SELECT
  $scenario_id,
  CURRENT_TIMESTAMP(),
  CURRENT_USER(),
  (SELECT COUNT(*) FROM RAW.ORDERS WHERE scenario_id = $scenario_id),
  (SELECT COUNT(*) FROM RAW.VEHICLE WHERE scenario_id = $scenario_id);
