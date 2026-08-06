# Winger Backend V2 – Ledger Subsystem Specification

The Ledger subsystem provides insert-only, immutable storage for all financial debits and credits.

---

## 1. Ledger Schema & Immutability
- **Header Table**: `wallet_ledger.journal_entries`
- **Line Detail Table**: `wallet_ledger.ledger_lines`
- **Constraint**: `UPDATE` and `DELETE` operations are disabled on `ledger_lines`. Corrections require new compensating journal entries.
