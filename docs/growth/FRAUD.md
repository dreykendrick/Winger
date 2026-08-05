# Winger Backend V2 – Anti-Fraud Detection Specification

The Anti-Fraud subsystem evaluates click sessions, attribution tokens, and conversions to identify suspicious activities without blocking legitimate user traffic automatically.

---

## 1. Non-Blocking Risk Signal Architecture
Fraud checks produce non-blocking `risk_score` entries (1 to 100) logged in `growth.fraud_flags`. Suspicious events trigger administrative alerts for manual support review while allowing clean conversions to complete.

---

## 2. Fraud Detection Heuristics

| Flag Type | Triggering Condition | Risk Score | Action |
| :--- | :--- | :--- | :--- |
| `SELF_REFERRAL` | Affiliate profile ID matches purchasing customer profile ID | 90 | Log flag & notify risk dashboard |
| `CLICK_SPAM` | Single IP hash exceeds 30 clicks / minute | 75 | Log flag & flag link for velocity review |
| `DUPLICATE_CLICK` | Identical session token submitted twice | 50 | Deduplicate click record |
| `REPEAT_IP` | Multi-account conversions sharing identical IP hash | 65 | Require manual finance review prior to payout |
