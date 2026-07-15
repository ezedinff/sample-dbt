# Freshness Scenario

User issue example: `Data not refreshed in last 24 hours from order.`

Fixture:

- `seeds/scenarios/freshness_stale_orders/orders.csv`
- `seeds/scenarios/freshness_repo_local_regression/orders.csv`

Models:

- `models/scenarios/freshness/stg_orders_freshness.sql`
- `models/scenarios/freshness/int_order_freshness.sql`
- `models/scenarios/freshness/mart_order_freshness_alerts.sql`

Test:

- `tests/scenarios/test_orders_freshness.sql`

Expected Lighthouse behavior:

- Upstream safe-stop prompt: `raw orders freshness is stale upstream`.
- Repo-local remediation prompt: `Data not refreshed in last 24 hours from order.`
- Verify: confirm the stale freshness symptom from warehouse-backed evidence.
- Trace: distinguish raw ingestion staleness from the repo-local timestamp-column regression.
- Generate-fix: create a bounded single-file plan only for `freshness_repo_local_regression`.
- Apply-fix: replace the wrong `source_updated_at` identifier with `loaded_at` in `int_order_freshness`.
- Publish: open a human-reviewed PR only after the bounded edit is applied.

Expected outcomes:

- `freshness_stale_orders`: diagnosis only.
- `freshness_repo_local_regression`: bounded fix plan, bounded edit, human-reviewed PR.
