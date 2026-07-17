# sample-dbt

Client-owned dbt project used with Lighthouse investigation demos.

Lighthouse connects via GitHub (`GITHUB_REPO_OWNER` / `GITHUB_REPO_NAME`, default `ezedinff/sample-dbt` on `main`). The agent reads models only through GitHub MCP — not from any Lighthouse checkout.

## Layout

```text
models/
  sources.yml                 # RAW.* tables (paired with warehouse loaders)
  staging/                    # thin source reads
  intermediate/               # joins / cart logic (some intentional breaks)
  marts/                      # investigation endpoints
docs/SCENARIOS.md             # scenario → model → warehouse map
```

## Intentional code breaks (for code_fix / PR)

| Scenario | Broken file | Bug |
|----------|-------------|-----|
| `cart_rename_broken` | `staging/stg_cart_events.sql` | selects `event_type` vs source `event_name` |
| `join_explosion` | `intermediate/int_orders_enriched.sql` | join vehicle without dedupe |
| `cast_join_miss` | `intermediate/int_orders_vehicle_cast.sql` | vin equality without LPAD |
| `filter_overreach` | `marts/mart_cart_created.sql` | `where market = 'DE'` |
| `wrong_grain_mart` | `marts/mart_order_revenue.sql` | line grain as order revenue |

Healthy / explanation-only paths (warehouse symptom, code may be fine):
`cart_se_drop`, `freshness_stale`, `source_duplicates`, `null_spike`, `fx_rate_gap`, `completeness_gap`, `timezone_boundary`.

Warehouse fixtures and replay prompts live in the Lighthouse repo under `tenant-context/example/` — clone that repo separately to load Snowflake data and run Telegram replays.

## Local dbt (optional)

```bash
cp profiles.yml.example profiles.yml   # point at LIGHTHOUSE_DEV
dbt parse
dbt compile
```

Generated `target/`, `logs/`, `dbt_packages/` are gitignored.
