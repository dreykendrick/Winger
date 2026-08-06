# Winger Backend V2 – Release Engine Specification

Evaluates whether escrow release conditions have been satisfied.

---

## 1. Release Evaluation Conditions
1. Delivery verified via supported verification method.
2. Protection window (48h) expired OR manually confirmed by buyer.
3. Zero active disputes in progress (`status IN ('OPEN', 'UNDER_REVIEW')`).

When conditions pass, `order_guardian.fn_evaluate_escrow_release(...)` updates case status to `RELEASE_REQUESTED` and publishes `order_guardian.escrow.release_requested` to the Platform Event Bus.
