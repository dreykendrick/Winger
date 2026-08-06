# Winger Backend V2 – Merchant Fulfillment Specification

The fulfillment subsystem manages vendor store preparation, item picking, packing, and dispatch staging independently from courier delivery.

---

## 1. Fulfillment Lifecycle

```mermaid
stateDiagram-v2
    [*] --> PENDING: Order Confirmed
    PENDING --> PREPARING: Item Picking Started
    PREPARING --> PACKED: Items Packed in Box
    PACKED --> READY: Staged for Courier Collection
    READY --> COLLECTED: Handed to Courier Driver
```

---

## 2. Fulfillment Statuses
- **`PENDING`**: Order received, awaiting merchant preparation.
- **`PREPARING`**: Merchant picking items from inventory.
- **`PACKED`**: Parcel sealed and labeled.
- **`READY`**: Parcel staged at store pickup area.
- **`COLLECTED`**: Parcel handed to courier driver.
