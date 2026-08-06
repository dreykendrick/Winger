# Winger Backend V2 – Asynchronous Background Job System Specification

Details queued background job processing, retry policies, and Dead-Letter Queue (DLQ) mechanics.

---

## 1. Job States
`QUEUED` $\rightarrow$ `PROCESSING` $\rightarrow$ `COMPLETED` / `FAILED` $\rightarrow$ `DEAD_LETTER` (after max retry attempts).
