# Winger Backend V2 – Commission Engine & Rule Precedence Specification

The Commission Engine calculates affiliate compensation based on a deterministic rule precedence hierarchy.

---

## 1. Rule Precedence Hierarchy

When an `OrderPaid` event is processed, `growth.fn_evaluate_commission_rule(...)` evaluates rules in strict priority order:

```
Priority 100: Campaign Specific Rule
     ↓
Priority 80:  Product Specific Rule
     ↓
Priority 60:  Category Specific Rule
     ↓
Priority 40:  Vendor Specific Rule
     ↓
Priority 20:  Global Default Percentage (5.00%)
```

---

## 2. Rule Types
- **`PERCENTAGE`**: Calculates commission as a percentage of gross sale amount ($\text{Sale} \times \frac{\text{Rate}}{100}$).
- **`FIXED`**: Assigns a fixed monetary amount per conversion regardless of order value.
- **`TIERED`**: Adjusts commission rates dynamically based on monthly affiliate sales volume.
