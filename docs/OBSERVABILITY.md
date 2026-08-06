# Winger Backend V2 – Observability Specification

Structured JSON logging, metrics, performance tracking, and correlation ID propagation.

---

## 1. Structured Log Format
```json
{
  "timestamp": "2026-08-06T03:20:00Z",
  "level": "INFO",
  "correlation_id": "corr_12345",
  "workspace_id": "018f2d5e-...",
  "event": "orders.order.paid",
  "duration_ms": 42
}
```
