# Winger Backend V2 – Wallet Projections Specification

Wallets are read-only projections dynamically computed from underlying double-entry ledger lines.

---

## 1. Wallet Balances
- `available_balance`: Funds available for immediate withdrawal or purchase.
- `pending_balance`: Escrowed funds awaiting delivery confirmation.
- `reserved_balance`: Funds reserved for pending payouts or dispute holds.
- `lifetime_earnings`: Aggregate cumulative credit earnings.
- `lifetime_payouts`: Aggregate cumulative completed payout disbursements.
