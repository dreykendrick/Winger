# Winger Backend V2 – Refund Infrastructure Specification

Refunds issue compensating ledger entries without mutating original payment records.

---

## 1. Refund Accounting Entries
`INTENT_CUSTOMER_REFUND`: Debit `2000_ESCROW_HOLDING`, Credit `1000_CLEARING`.
