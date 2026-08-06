# Winger Backend V2 – Delivery Verification Engine Specification

Details verification methods for confirming parcel handovers to customers.

---

## 1. Verification Methods
- **`CUSTOMER_CONFIRMATION`**: Manual sign-off in buyer app.
- **`VENDOR_CONFIRMATION`**: Merchant handover verification.
- **`OTP`**: One-time-passcode verification between courier driver and recipient.
- **`QR_CODE`**: Digital QR scan verification at delivery destination.
- **`PHOTO_EVIDENCE`**: Parcel drop-off photo upload.
- **`AUTO_TIMEOUT`**: Automated verification past 48h protection window expiry.
