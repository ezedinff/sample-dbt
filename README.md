# Sample dbt Client Repo for Lighthouse

This repository is a small, fake client-owned dbt project used to test Lighthouse against an external codebase. It is intentionally separate from the Lighthouse service repository so local demos and future GitHub PR publication tests can operate on a realistic target repo.

## Lineage Overview

The primary metric path is:

```text
raw.raw_events_cart
  -> stg_cart_events
  -> int_abandoned_cart
  -> mart_abandoned_cart_rate
```

`mart_abandoned_cart_rate` is the metric endpoint Lighthouse investigates when the abandoned cart rate drops.

## Intentional Broken Scenario

This repo contains one intentional MVP breakage:

- Scenario: `source_to_staging_field_rename`
- Upstream source contract: `raw.raw_events_cart` now exposes `event_name`
- Outdated staging model: `models/staging/stg_cart_events.sql` still selects `event_type`
- Downstream models and schema tests expect the repaired `event_name` output
- Expected Lighthouse target file: `models/staging/stg_cart_events.sql`
- Expected deterministic edit: replace the stale `event_type` identifier with `event_name`

The mismatch is documented in `models/sources.yml` and kept to a single identifier reference in the staging model so Lighthouse can trace, plan, and apply a bounded fix.

## Local dbt Usage

Install dbt for your warehouse adapter, then run:

```bash
dbt deps
dbt parse
dbt compile
```

`dbt parse` writes `target/manifest.json`, which Lighthouse can use for manifest-based lineage tracing. Generated artifacts under `target/`, `logs/`, and `dbt_packages/` are intentionally ignored.

## Notes for Lighthouse Tests

Use this repository as a client workspace, not as part of the Lighthouse service tree. Stable assumptions for integration tests:

- dbt project root is the repository root
- model root is `models/`
- staging fix target is `models/staging/stg_cart_events.sql`
- metric endpoint is `models/marts/mart_abandoned_cart_rate.sql`
- generated manifests can be recreated locally with `dbt parse`

## Multi-Scenario Sandbox Pack

The repo also contains a Lighthouse scenario pack under `models/scenarios/`,
`seeds/scenarios/`, `tests/scenarios/`, `docs/scenarios/`, and `sql/bootstrap/`.
It broadens validation beyond the cart rename path with freshness,
completeness, and uniqueness fixtures.

The scenario CSV files are Snowflake-loadable fixtures for a dedicated sandbox
schema. They are intentionally not configured as always-on dbt seeds because the
fixture folders reuse natural names like `orders.csv` and `vehicle.csv`.
