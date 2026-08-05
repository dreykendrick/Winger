# Winger Backend V2 – Escrow Holding & Release Rules Specification

This document details the escrow locking mechanism, dispute hold rules, and automated release sweeper policies enforced by **Order Guardian**.

---

## 1. Escrow Holding & Release Workflow

```mermaid
sequenceDiagram
    autonumber
    participant Checkout as Checkout Gateway
    participant OG as Order Guardian RPC
    participant Escrow as order_guardian.escrows
    participant Sweeper as pg_cron Sweeper Worker
    participant Ledger as Wallet Ledger Domain

    Checkout->>OG: Payment Verified (checkout.payment.verified)
    OG->>Escrow: INSERT INTO escrows (status='LOCKED', auto_release_at = NOW() + 7 Days)
    Note over Escrow: Order SHIPPED and DELIVERED
    alt Option A: Customer Confirms Delivery
        OG->>OG: fn_release_escrow(escrow_id)
    else Option B: 7-Day Timer Expiration
        Sweeper->>OG: fn_process_auto_release_sweeper()
        OG->>OG: fn_release_escrow(escrow_id)
    end
    OG->>Escrow: UPDATE status = 'RELEASED'
    OG->>Ledger: Publish order_guardian.escrow.released Event (Triggers Double-Entry Journaling)
```

---

## 2. Escrow Lockup Breakdown
When funds enter escrow, the total amount is locked into 3 distinct allocation components:
$$\text{Total Escrow Amount} = \text{Vendor Amount} + \text{Affiliate Amount} + \text{Platform Fee}$$

- **Vendor Amount**: Held for merchant payout upon delivery.
- **Affiliate Amount**: Held for promoting affiliate commission payout.
- **Platform Fee**: Retained by Winger marketplace platform.

---

## 3. Dispute Hold Policy
Opening a dispute (`order_guardian.disputes`) freezes the escrow record (`status = 'DISPUTED'`), completely suspending the 7-day auto-release timer until administrative resolution.
