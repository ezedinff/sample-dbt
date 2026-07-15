# Snowflake Scenario Load

This workflow loads the Lighthouse scenario fixtures into the dedicated sandbox warehouse. These are operator setup steps. Lighthouse investigation remains read-only after the fixtures are loaded.

## Target

- Warehouse: `LIGHTHOUSE_DEV_WH`
- Database: `LIGHTHOUSE_DEV`
- Schema: `RAW`
- Tables: `RAW.ORDERS`, `RAW.VEHICLE`, `RAW.SCENARIO_LOAD_AUDIT`

## Local Docker Workflow

From the sample-dbt repo root inside the Lighthouse Docker workspace:

```bash
python scripts/load_snowflake_scenarios.py --reset --verify
```

Load one scenario:

```bash
python scripts/load_snowflake_scenarios.py --scenario completeness_missing_100_vins --verify
```

The loader reads CSV files from `seeds/scenarios/<scenario_id>/`, creates the raw tables through `sql/bootstrap/create_raw_tables.sql`, deletes existing rows for the selected scenario, inserts the fixture rows, and optionally runs `sql/bootstrap/verify_scenario_load.sql`.

## SnowSQL-Style Workflow

For a human-run Snowflake setup outside the local Docker helper:

1. Run `sql/bootstrap/create_raw_tables.sql`.
2. Stage the CSVs for the desired scenario.
3. Run `sql/bootstrap/load_scenario.sql` after replacing `<scenario_id>`.
4. Run `sql/bootstrap/verify_scenario_load.sql`.

## Expected Verification

The verification script should report `pass` for:

- baseline order and vehicle rows are populated
- freshness latest `loaded_at` is older than 24 hours
- completeness has 120 order VINs, 20 matched vehicle VINs, and 100 missing VINs
- uniqueness source duplicates contain at least one duplicate business key
- uniqueness join explosion has more joined rows than source order rows
- uniqueness join explosion has repeated vehicle-side keys

## Boundary

The setup workflow writes fixture data by design. Lighthouse runtime investigation still uses read-only Snowflake access, and no merge or deploy capability is added.
