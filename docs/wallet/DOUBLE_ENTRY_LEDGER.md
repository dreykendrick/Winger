# Winger Backend V2 – Double-Entry Ledger Specification

The Wallet Ledger enforces immutable, insert-only accounting entries based on double-entry principles.

---

## 1. Core Accounting Equation

$$\text{Assets} = \text{Liabilities} + \text{Equity}$$

$$\sum \text{Debits} = \sum \text{Credits}$$

---

## 2. Insert-Only Ledger Lines
- **Table**: `wallet_ledger.ledger_lines`
- **Immutability**: `UPDATE` and `DELETE` queries are disabled by database policies.
- **Constraints**: Each line MUST be strictly a Debit ($>0$) XOR Credit ($>0$).
- **Corrections**: Correcting prior mistakes requires posting a new compensating journal entry transaction header.
