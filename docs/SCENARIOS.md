# Scenario → model → warehouse map

Warehouse loader (Lighthouse repo):

```bash
docker compose exec agent-api python /workspace/tenant-context/example/scripts/load_scenarios.py \
  --scenario <id> --verify
```

| Replay / scenario | Warehouse tables of interest | Repo files the agent should see | Intended solution |
|-------------------|------------------------------|----------------------------------|-------------------|
| `cart_se_drop` | `RAW.RAW_EVENTS_CART` | `mart_abandoned_cart_rate`, `int_abandoned_cart`, `stg_cart_events` | explanation (true drop) |
| `cart_rename_broken` | same as cart_se_drop | **`stg_cart_events.sql`** (`event_type`) | code_fix / mixed |
| `join_explosion` | `RAW_ORDERS`, `RAW_VEHICLE`, `MART_ORDERS_ENRICHED` | **`int_orders_enriched.sql`**, `mart_orders_enriched` | logic_error / code_fix |
| `cast_join_miss` | padded vs unpadded VIN | **`int_orders_vehicle_cast.sql`** | logic_error / code_fix |
| `filter_overreach` | RAW SE present, mart SE empty | **`mart_cart_created.sql`** | logic_error / code_fix |
| `wrong_grain_mart` | `RAW_ORDER_LINES`, grain check mart | **`mart_order_revenue.sql`** | logic_error / code_fix |
| `freshness_stale` | `RAW_ORDERS.loaded_at` | `mart_order_freshness` | explanation |
| `source_duplicates` | duplicate `order_id` in RAW | `stg_orders` | explanation |
| `null_spike` | `RAW_EVENTS_CART.user_id` | `stg_cart_events` | explanation |
| `fx_rate_gap` | `RAW_EXCHANGE_RATES` | `mart_revenue_usd` | explanation |
| `completeness_gap` | unmatched VINs | `mart_order_vehicle_match` | explanation |
| `timezone_boundary` | midnight event clustering | cart models | explanation |

## Lineage (cart)

```text
RAW.RAW_EVENTS_CART
  -> stg_cart_events          # rename break
  -> int_abandoned_cart
  -> mart_abandoned_cart_rate
```

## Lineage (orders enrichment)

```text
RAW.RAW_ORDERS + RAW.RAW_VEHICLE
  -> stg_orders / stg_vehicle
  -> int_orders_enriched      # join fan-out break
  -> mart_orders_enriched
```
