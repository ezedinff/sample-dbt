# Lighthouse Scenario Pack

This sample-dbt repo is the sandbox client repository for Lighthouse scenario testing. The existing abandoned-cart path remains intact. New scenario assets are isolated under:

- `models/scenarios/freshness/`
- `models/scenarios/completeness/`
- `models/scenarios/uniqueness/`
- `seeds/scenarios/`
- `tests/scenarios/`
- `sql/bootstrap/`

The CSV files under `seeds/scenarios/` are Snowflake-loadable fixtures. They are intentionally not configured as always-on dbt seeds because the scenario folders reuse natural fixture names like `orders.csv` and `vehicle.csv`.

Trust boundaries are unchanged:

- Lighthouse investigates Snowflake through read-only access.
- dbt repo edits are bounded to local workspace files.
- PR publication is for human review only.
- No merge or deploy capability is introduced.

Scenario outcomes:

| Scenario | Expected outcome |
| --- | --- |
| Freshness stale orders | Diagnosis only; stop before bounded code remediation unless evidence later points to repo logic. |
| Completeness missing 100 VINs | Diagnosis first; bounded fix only if dbt join/filter logic is responsible. |
| Uniqueness source duplicates | Diagnosis only; upstream source duplicate should not force a repo fix. |
| Uniqueness join explosion | Diagnosis plus bounded fix plan/edit is allowed when duplicate keys are introduced by repo-controlled join logic. |

Use `sql/bootstrap/create_raw_tables.sql` to create the raw sandbox tables and `sql/bootstrap/load_scenario.sql` as the Snowflake loading template.

For the executable local load workflow and expected verification output, see `docs/scenarios/snowflake_load.md`.

For the latest local verification run, see `docs/scenarios/verification_log.md`.
