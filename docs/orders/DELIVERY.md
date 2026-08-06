# Winger Backend V2 – Delivery Lifecycle Specification

The delivery subsystem manages courier assignment, transit status updates, and recipient delivery confirmations.

---

## 1. Delivery Lifecycle States

```mermaid
stateDiagram-v2
    [*] --> PENDING: Delivery Record Created
    PENDING --> ASSIGNED: Courier Assigned
    ASSIGNED --> PICKED_UP: Parcel Collected from Store
    PICKED_UP --> IN_TRANSIT: Driver En Route
    IN_TRANSIT --> DELIVERED: Recipient Handover Completed
    IN_TRANSIT --> FAILED: Delivery Attempt Failed
    FAILED --> IN_TRANSIT: Re-delivery Attempt
    FAILED --> RETURNED: Returned to Merchant
```

---

## 2. Delivery Status Definitions
- **`PENDING`**: Delivery record initialized.
- **`ASSIGNED`**: Driver/courier assigned.
- **`PICKED_UP`**: Driver collected parcel from vendor store.
- **`IN_TRANSIT`**: Driver en route to customer destination.
- **`DELIVERED`**: Parcel handed to customer.
- **`FAILED`**: Recipient unreachable or address invalid.
- **`RETURNED`**: Parcel returned to merchant inventory.
