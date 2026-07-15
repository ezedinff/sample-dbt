# Uniqueness Scenario

User issue example: `Duplicate record for unique key.`

Fixtures:

- `seeds/scenarios/uniqueness_source_duplicates/orders.csv`
- `seeds/scenarios/uniqueness_join_explosion/orders.csv`
- `seeds/scenarios/uniqueness_join_explosion/vehicle.csv`

Models:

- `models/scenarios/uniqueness/stg_orders_uniqueness.sql`
- `models/scenarios/uniqueness/stg_vehicle_uniqueness.sql`
- `models/scenarios/uniqueness/int_orders_vehicle_enriched.sql`
- `models/scenarios/uniqueness/mart_duplicate_unique_keys.sql`

Test:

- `tests/scenarios/test_duplicate_unique_keys.sql`

Expected Lighthouse behavior:

- Verify: confirm duplicate count, affected key, and when duplication started.
- Trace: separate raw-source duplicate keys from join-produced duplicate keys.
- Generate-fix: stop with diagnosis for raw-source duplicates; propose bounded repo-local remediation for join explosion when the join logic is responsible.
- Apply-fix: block upstream-source cases; allow bounded local edit for repo-controlled join remediation.
- Publish: open a review PR only for a successful bounded local edit.

Expected outcomes:

- `uniqueness_source_duplicates`: diagnosis only.
- `uniqueness_join_explosion`: diagnosis plus bounded fix plan/edit is allowed when evidence supports it.
