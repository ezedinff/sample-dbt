# Scenario Load Verification Log

Verified against the local Snowflake sandbox on 2026-07-15 using:

```bash
python scripts/load_snowflake_scenarios.py --verify
```

Loaded fixtures:

| Scenario | Orders | Vehicle |
| --- | ---: | ---: |
| `baseline` | 5 | 5 |
| `freshness_stale_orders` | 3 | 0 |
| `freshness_repo_local_regression` | 3 | 0 |
| `completeness_missing_100_vins` | 120 | 20 |
| `uniqueness_source_duplicates` | 4 | 0 |
| `uniqueness_join_explosion` | 3 | 4 |

Verification output:

| Check | Observed | Expected | Status |
| --- | ---: | ---: | --- |
| `baseline_latest_loaded_at_on_expected_day` | 5 | 5 | pass |
| `baseline_orders_populated` | 5 | 5 | pass |
| `baseline_vehicle_populated` | 5 | 5 | pass |
| `completeness_matched_vehicle_vins` | 20 | 20 | pass |
| `completeness_missing_vehicle_vins` | 100 | 100 | pass |
| `completeness_recent_order_vins` | 120 | 120 | pass |
| `freshness_latest_loaded_at_before_cutoff` | 3 | 3 | pass |
| `freshness_repo_local_raw_loaded_at_fresh` | 3 | 3 | pass |
| `freshness_repo_local_source_updated_at_stale` | 3 | 3 | pass |
| `uniqueness_join_explosion_extra_rows` | 1 | 1 | pass |
| `uniqueness_join_explosion_repeated_vehicle_keys` | 1 | 1 | pass |
| `uniqueness_source_duplicate_key_count` | 1 | 1 | pass |

`dbt parse --profiles-dir /root/.dbt` also completed successfully in the local dbt container.
Use `dbt run --select tag:scenario:freshness --profiles-dir /root/.dbt` to materialize the
intentional repo-local freshness regression. `dbt build` is expected to flag the freshness
data test while the regression is present.
