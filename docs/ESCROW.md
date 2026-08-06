# Winger Backend V2 – Escrow Accounting Specification

Escrow accounting isolates locked order funds in `2000_ESCROW_HOLDING` liabilities.

---

## 1. Escrow Accounting Entries
- **Funding**: Debit `1000_CLEARING`, Credit `2000_ESCROW_HOLDING`.
- **Release**: Debit `2000_ESCROW_HOLDING`, Credit `2100_VENDOR_PAYABLE`.
