# Winger Backend V2 – Analytics Aggregation Specification

The analytics engine maintains aggregated metrics in `growth.analytics_daily` for instant dashboard queries without performing expensive live table scans across millions of click logs.

---

## 1. Aggregated Metrics
- `clicks`: Total raw referral link clicks.
- `unique_visitors`: Count of unique `visitor_token` instances.
- `conversions`: Count of confirmed sale conversions.
- `gross_revenue`: Total merchandise value generated ($\sum \text{Sale\_Amount}$).
- `commission_total`: Total affiliate commissions earned ($\sum \text{Commission\_Amount}$).
- `conversion_rate`: Derived metric ($\frac{\text{Conversions}}{\text{Clicks}} \times 100$).
