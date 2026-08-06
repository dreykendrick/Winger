# Winger Backend V2 – Cron Scheduler Specification

Schedules recurring maintenance, analytics, and cleanup tasks.

---

## 1. Recurring Cron Tasks
- Expire Stale Checkout Sessions (every 15 min)
- Release Expired Escrows (every 1 hour)
- Audit Ledger Double-Entry Balance (every 24 hours)
