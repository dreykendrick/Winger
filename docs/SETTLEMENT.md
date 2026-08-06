# Winger Backend V2 – Settlement Foundation Specification

Settlements handle internal clearing and external payment gateway disbursements.

---

## 1. Settlement Accounting Flow
`INTENT_VENDOR_PAYOUT`: Debit `2100_VENDOR_PAYABLE`, Credit `1000_CLEARING`.
