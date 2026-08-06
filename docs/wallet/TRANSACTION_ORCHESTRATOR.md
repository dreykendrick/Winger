# Winger Backend V2 – Transaction Orchestrator Architecture Specification

This document defines the central execution engine of Winger's Financial Core.

---

## 1. Architectural Law: ALL MONEY FLOWS THROUGH THE TRANSACTION ORCHESTRATOR

```mermaid
graph TD
    EVENT[Business Intent Submission] -->|1. Submit Intent Payload| ORCH[Transaction Orchestrator Engine]
    ORCH -->|2. Check Idempotency Key| IDEM[orchestrator_requests Log]
    ORCH -->|3. Load Accounting Rules| RULE[Accounting Rule Engine]
    ORCH -->|4. Generate Journal Header| JNL[journal_entries Header]
    ORCH -->|5. Insert Double-Entry Lines| LINES[ledger_lines: Debits & Credits]
    ORCH -->|6. Verify Balance| BAL{Debits == Credits?}
    BAL -- No --> ROLLBACK[Atomic Rollback Transaction]
    BAL -- Yes --> UPDATE[Update Account Balances]
    UPDATE --> OUTBOX[Publish Financial Event to Outbox]
```

### Mandatory Execution Guarantees
1. **Zero Direct Financial Mutations**: No service, API, background worker, or domain may update wallet balances, create ledger lines, or disburse funds directly. Every operation MUST submit a financial intent to `wallet_ledger.fn_execute_transaction_orchestrator(...)`.
2. **Atomic All-or-Nothing Execution**: Executed inside a single `SERIALIZABLE` database transaction. Partial financial updates are strictly impossible.
3. **Double-Entry Balancing Enforcement**: Enforces $\sum \text{Debits} - \sum \text{Credits} = 0$ for every committed transaction header.
