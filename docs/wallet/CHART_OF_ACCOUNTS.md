# Winger Backend V2 – Chart of Accounts & Rule Engine Specification

The Chart of Accounts defines standardized system accounts and intent mappings evaluated by the Accounting Rule Engine.

---

## 1. System Account Code Registry

| Account Code | Account Name | Type | Purpose |
| :--- | :--- | :--- | :--- |
| `1000_CLEARING` | Payment Gateway Clearing Account | `ASSET` | Inbound payment gateway funds clearing |
| `2000_ESCROW_HOLDING` | Order Escrow Holding Account | `LIABILITY` | Locked order funds awaiting delivery |
| `2100_VENDOR_PAYABLE` | Vendor Payable Balance Pool | `LIABILITY` | Earnings available for vendor payout |
| `2200_AFFILIATE_PAYABLE` | Affiliate Payable Commission Pool | `LIABILITY` | Earned commissions awaiting payout |
| `4000_PLATFORM_REVENUE` | Winger Marketplace Revenue Account | `REVENUE` | Platform commission fees retained |

---

## 2. Intent to Journal Mapping Rules

```
INTENT_ESCROW_FUND:      Debit 1000_CLEARING,        Credit 2000_ESCROW_HOLDING
INTENT_ESCROW_RELEASE:   Debit 2000_ESCROW_HOLDING,  Credit 2100_VENDOR_PAYABLE
INTENT_COMMISSION_CREDIT:Debit 2000_ESCROW_HOLDING,  Credit 2200_AFFILIATE_PAYABLE
INTENT_PLATFORM_FEE:     Debit 2000_ESCROW_HOLDING,  Credit 4000_PLATFORM_REVENUE
INTENT_VENDOR_PAYOUT:    Debit 2100_VENDOR_PAYABLE,  Credit 1000_CLEARING
INTENT_CUSTOMER_REFUND:  Debit 2000_ESCROW_HOLDING,  Credit 1000_CLEARING
```
