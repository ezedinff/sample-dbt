# sample-dbt

Client-owned dbt project. Lighthouse connects via GitHub
(`GITHUB_REPO_OWNER` / `GITHUB_REPO_NAME`) and reads models only through
GitHub MCP — not from a local checkout.

## Layout

```text
models/
  sources.yml
  staging/
  intermediate/
  marts/
```

## Local dbt (optional)

Point `profiles.yml` at `LIGHTHOUSE_DEV` (see `profiles.yml.example`), then:

```bash
dbt parse
dbt compile --select int_orders_enriched
dbt run --select +int_orders_enriched
```

Generated `target/`, `logs/`, and `dbt_packages/` are gitignored.
