# Funnel Analysis — SQL

PostgreSQL queries for analysing user purchase funnel behaviour from the `user_events` table, covering stage drop-off, traffic source performance, time-to-conversion, and revenue metrics.

---

## Table of Contents

- [Overview](#overview)
- [Schema](#schema)
- [Queries](#queries)
- [Key Findings](#key-findings)
- [Recommendations](#recommendations)
- [Usage](#usage)
- [Requirements](#requirements)

---

## Overview

This project analyses the end-to-end e-commerce purchase funnel — from first page view through to completed purchase — to identify where users drop off, which acquisition channels perform best, and where revenue is being lost or won.

---

## Schema

```sql
user_events (
    user_id        TEXT,
    event_type     TEXT,       -- 'page_view' | 'add_to_cart' | 'checkout_start'
                               -- | 'payment_info' | 'purchase'
    event_date     TIMESTAMP,
    traffic_source TEXT,       -- e.g. 'email', 'social', 'organic', 'paid_search'
    amount         NUMERIC     -- populated for 'purchase' events only
)
```

---

## Queries

### 1. Sales Funnel Stages
Counts distinct users at each of the five funnel stages and calculates the step-by-step and overall conversion rates.

| Column | Description |
|--------|-------------|
| `stage_1_views` → `stage_5_purchase` | Distinct users at each stage |
| `view_to_cart_rate` | % of viewers who added to cart |
| `cart_to_checkout_rate` | % of cart users who started checkout |
| `checkout_to_payment_rate` | % who reached payment info |
| `payment_to_purchase_rate` | % who completed purchase |
| `overall_conversion_rate` | End-to-end visitor → buyer rate |

---

### 2. Funnel by Traffic Source
Breaks down views, cart adds, and purchases by acquisition channel, with per-channel conversion rates ordered by purchase volume.

| Column | Description |
|--------|-------------|
| `cart_conversion_rate` | % of channel visitors who added to cart |
| `purchase_conversion_rate` | % of channel visitors who purchased |
| `cart_to_purchase_conversion_rate` | % of cart adds that converted to purchase |

---

### 3. Time to Conversion
For users who completed a purchase, calculates the average time (in minutes) between each funnel stage.

| Column | Description |
|--------|-------------|
| `converted_users` | Total users who completed a purchase |
| `avg_view_to_cart_minutes` | Avg minutes from first view to cart add |
| `avg_cart_to_purchase_minutes` | Avg minutes from cart add to purchase |
| `avg_total_journey_minutes` | Avg total minutes from first view to purchase |

---

### 4. Revenue Funnel
Summarises revenue performance across the full visitor base.

| Column | Description |
|--------|-------------|
| `avg_order_value` | Total revenue / total orders |
| `revenue_per_buyer` | Total revenue / distinct buyers |
| `revenue_per_visitor` | Total revenue / all visitors (incl. non-buyers) |

---

## Key Findings

- **Checkout flow is not the problem** — conversion rates from Checkout Start through to Purchase are ~80%+, meaning the technical payment flow is frictionless.
- **Social Media drives volume but not value** — Social accounts for ~30% of traffic but has the lowest conversion rate (~6%). These users are largely window shoppers.
- **Email is the highest converting channel** — Email traffic converts at ~13%+, more than double the Social rate.
- **Average Order Value is ~$115** — this is the baseline for evaluating paid acquisition economics.

---

## Recommendations

### 1. UX & Website Optimisation
- **Do not redesign the checkout flow.** The data shows it is working. Any redesign risks breaking a process that is already converting at ~80%+.

### 2. Marketing Strategy
- **Stop over-investing in Social for direct sales.** Shift Social ad budget away from "Traffic" objectives. Instead, focus on "Retargeting" or "Lead Gen" campaigns to capture emails from high-volume Social visitors.
- **Double down on Email Marketing.** At ~13%+ conversion, email is the strongest channel. Implement an aggressive email capture popup for Social visitors — the data shows that getting a user onto the email list significantly increases their likelihood of purchasing.

### 3. Financial & Revenue
- **Audit ad spend against AOV.** With an AOV of ~$115, set a strict Customer Acquisition Cost (CAC) ceiling of **$30–$40**. Any Social Media campaigns exceeding this CAC limit are likely loss-making on a per-transaction basis and should be paused or restructured.

---

## Usage

Run all queries sequentially from the file:

```bash
psql -U <user> -d <database> -f funnel_analysis.sql
```

Or run a single section by copying the relevant CTE block into your SQL client (DBeaver, DataGrip, psql, etc.).

---

## Requirements

- PostgreSQL 12+
- No extensions required
- All conversion rates use `100.0` float multiplication and `::numeric` casting to avoid integer division truncation
