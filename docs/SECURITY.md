# Winger Backend V2 – Security Hardening Specification

Defines security policies, HMAC verification standards, CORS, and RLS enforcement.

---

## 1. Security Protocols
- Row Level Security (RLS) on 100% of tables.
- Secrets stored in encrypted env secrets.
- HMAC-SHA256 signature verification on all webhooks.
- Privacy-conscious SHA-256 IP hashing.
