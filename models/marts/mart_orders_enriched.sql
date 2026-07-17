-- Publishes the join-explosion enrichment for investigation.
select * from {{ ref('int_orders_enriched') }}
