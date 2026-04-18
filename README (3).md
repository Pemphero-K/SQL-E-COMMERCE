# Funnel Analysis — SQL

PostgreSQL queries for analysing user purchase funnel behaviour from the `user_events` table.

## Queries

| # | Query | Description |
|---|-------|-------------|
| 1 | Sales Funnel Stages | Distinct user counts and drop-off rates across all five funnel stages |
| 2 | Funnel by Traffic Source | Conversion rates broken down by acquisition channel |
| 3 | Time to Conversion | Average minutes between stages for users who completed a purchase |
| 4 | Revenue Funnel | AOV, revenue per buyer, and revenue per visitor |

## Expected Schema

```sql
user_events (
    user_id        TEXT,
    event_type     TEXT,   -- 'page_view' | 'add_to_cart' | 'checkout_start' | 'payment_info' | 'purchase'
    event_date     TIMESTAMP,
    traffic_source TEXT,
    amount         NUMERIC  -- populated for 'purchase' events only
)
```

## Usage

Run queries individually in sequence — each is self-contained with its own CTE.

```bash
psql -U <user> -d <database> -f funnel_analysis.sql
```

## Requirements

- PostgreSQL 12+
- No extensions required
