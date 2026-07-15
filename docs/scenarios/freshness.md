# Freshness Scenario

User issue example: `Data not refreshed in last 24 hours from order.`

Fixture:

- `seeds/scenarios/freshness_stale_orders/orders.csv`

Models:

- `models/scenarios/freshness/stg_orders_freshness.sql`
- `models/scenarios/freshness/int_order_freshness.sql`
- `models/scenarios/freshness/mart_order_freshness_alerts.sql`

Test:

- `tests/scenarios/test_orders_freshness.sql`

Expected Lighthouse behavior:

- Verify: confirm the latest usable order `loaded_at` is older than 24 hours.
- Trace: identify whether staleness is already present in raw ingestion, staging, or mart logic.
- Generate-fix: produce diagnosis and escalation when the stale point is upstream ingestion.
- Apply-fix: skip when there is no bounded repo-local remediation.
- Publish: skip when no bounded edit was applied.

Expected outcome: diagnosis only.
