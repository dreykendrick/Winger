# Winger Backend V2 – Attribution Engine Specification

The Attribution Engine resolves customer referral touchpoints to assign sales conversions to promoting affiliates.

---

## 1. Supported Attribution Models

1. **`LAST_CLICK`** (Default): Assigns 100% of conversion credit to the most recent affiliate tracking link clicked prior to purchase.
2. **`FIRST_CLICK`**: Assigns credit to the initial affiliate link that introduced the customer to the platform.
3. **`TIME_DECAY`**: Gives exponentially higher credit to touchpoints closer in time to the conversion event.

---

## 2. Attribution Window & Expiration
- Default attribution window: **30 days** (`expires_at = NOW() + INTERVAL '30 days'`).
- Attribution records are generated automatically during click session processing via `growth-click-resolver`.
