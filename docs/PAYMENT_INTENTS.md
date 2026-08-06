# Winger Backend V2 – Payment Intents Specification

A Payment Intent (`checkout.payment_intents`) represents a request to collect payment via an external gateway.

---

## 1. Payment Intent Lifecycle
States: `PENDING` $\rightarrow$ `PROCESSING` $\rightarrow$ `SUCCEEDED` / `FAILED` / `CANCELLED` / `EXPIRED`.
