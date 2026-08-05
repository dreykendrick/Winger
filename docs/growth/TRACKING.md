# Winger Backend V2 – High-Volume Click Tracking Specification

The click tracking subsystem handles referral link resolution and session recording under high traffic volume.

---

## 1. Privacy-Conscious IP Hashing
To comply with global data privacy standards (GDPR / CCPA), visitor IP addresses are **NEVER** stored in plain text.

$$\text{IP\_Hash} = \text{SHA-256}(\text{Client\_IP})$$

---

## 2. Session Data Captured
- `session_token` (Unique string `cls_xxx`)
- `ip_hash` (SHA-256 digest)
- `user_agent`, `device`, `browser`, `country`, `referrer`
- `utm_params` (`utm_source`, `utm_medium`, `utm_campaign`)
