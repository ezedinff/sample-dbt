# Completeness Scenario

User issue example: `Missing 100 new order VIN from vehicle table.`

Fixtures:

- `seeds/scenarios/completeness_missing_100_vins/orders.csv`
- `seeds/scenarios/completeness_missing_100_vins/vehicle.csv`

The fixture contains 120 recent order VINs and only 20 matching vehicle VINs, leaving exactly 100 missing VINs.

Models:

- `models/scenarios/completeness/stg_orders_completeness.sql`
- `models/scenarios/completeness/stg_vehicle_completeness.sql`
- `models/scenarios/completeness/int_order_vehicle_coverage.sql`
- `models/scenarios/completeness/mart_missing_vehicle_vins.sql`

Test:

- `tests/scenarios/test_missing_vehicle_vins.sql`

Expected Lighthouse behavior:

- Verify: confirm exactly 100 recent order VINs do not resolve in the vehicle table.
- Trace: distinguish source sync lateness from dbt join/filter loss.
- Generate-fix: propose a bounded dbt fix only if join/filter logic caused the gap.
- Apply-fix: proceed only for repo-local bounded remediation.
- Publish: open a review PR only after a successful bounded edit.

Expected outcome: diagnosis first; bounded fix path only when evidence points to repo logic.
