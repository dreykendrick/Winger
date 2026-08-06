-- Winger Backend V2 - Transaction Orchestrator & Wallet Ledger Domain
-- Migration: 20260806000007_sprint6_transaction_orchestrator.sql
-- Description: Creates wallet_ledger schema, accounts, accounting_rules, orchestrator_requests, journal_entries, ledger_lines, settlements, and fn_execute_transaction_orchestrator RPC.

-- 1. Create Isolated Wallet Ledger Schema
CREATE SCHEMA IF NOT EXISTS wallet_ledger;
GRANT USAGE ON SCHEMA wallet_ledger TO anon, authenticated, service_role;

-- 2. Domain Enums
CREATE TYPE wallet_ledger.enum_account_type AS ENUM (
    'ASSET',
    'LIABILITY',
    'EQUITY',
    'REVENUE',
    'EXPENSE'
);

CREATE TYPE wallet_ledger.enum_journal_status AS ENUM (
    'DRAFT',
    'POSTED',
    'REJECTED',
    'REVERSED'
);

CREATE TYPE wallet_ledger.enum_intent_type AS ENUM (
    'INTENT_ESCROW_FUND',
    'INTENT_ESCROW_RELEASE',
    'INTENT_COMMISSION_CREDIT',
    'INTENT_VENDOR_PAYOUT',
    'INTENT_CUSTOMER_REFUND',
    'INTENT_PLATFORM_FEE'
);

-- 3. Chart of Accounts Table (`wallet_ledger.accounts`)
CREATE TABLE wallet_ledger.accounts (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    workspace_id UUID NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
    profile_id UUID NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    account_number TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    type wallet_ledger.enum_account_type NOT NULL,
    currency public.enum_currency NOT NULL DEFAULT 'TZS',
    balance NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    pending_escrow_balance NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    version INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    deleted_at TIMESTAMPTZ NULL
);

CREATE INDEX idx_accounts_workspace ON wallet_ledger.accounts(workspace_id);
CREATE INDEX idx_accounts_profile ON wallet_ledger.accounts(profile_id);
CREATE INDEX idx_accounts_number ON wallet_ledger.accounts(account_number);

-- 4. Accounting Rule Engine Table (`wallet_ledger.accounting_rules`)
CREATE TABLE wallet_ledger.accounting_rules (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    intent_type wallet_ledger.enum_intent_type UNIQUE NOT NULL,
    debit_account_code TEXT NOT NULL,
    credit_account_code TEXT NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

-- 5. Orchestrator Requests Table (`wallet_ledger.orchestrator_requests`) - Idempotency Log
CREATE TABLE wallet_ledger.orchestrator_requests (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    idempotency_key TEXT UNIQUE NOT NULL,
    intent_type wallet_ledger.enum_intent_type NOT NULL,
    workspace_id UUID NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
    actor_profile_id UUID NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    payload JSONB NOT NULL,
    status TEXT NOT NULL DEFAULT 'PROCESSING', -- 'PROCESSING', 'COMPLETED', 'FAILED'
    journal_id UUID NULL,
    result_envelope JSONB NULL,
    error_message TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_orchestrator_key ON wallet_ledger.orchestrator_requests(idempotency_key);
CREATE INDEX idx_orchestrator_status ON wallet_ledger.orchestrator_requests(status);

-- 6. Journal Entries Table (`wallet_ledger.journal_entries`) - Transaction Header
CREATE TABLE wallet_ledger.journal_entries (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    workspace_id UUID NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
    request_id UUID UNIQUE NOT NULL REFERENCES wallet_ledger.orchestrator_requests(id) ON DELETE CASCADE,
    intent_type wallet_ledger.enum_intent_type NOT NULL,
    narration TEXT NOT NULL,
    total_amount NUMERIC(15, 2) NOT NULL CHECK (total_amount >= 0),
    currency public.enum_currency NOT NULL DEFAULT 'TZS',
    status wallet_ledger.enum_journal_status NOT NULL DEFAULT 'POSTED',
    version INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_journals_workspace ON wallet_ledger.journal_entries(workspace_id);
CREATE INDEX idx_journals_request ON wallet_ledger.journal_entries(request_id);

-- 7. Ledger Lines Table (`wallet_ledger.ledger_lines`) - IMMUTABLE INSERT-ONLY
CREATE TABLE wallet_ledger.ledger_lines (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    journal_id UUID NOT NULL REFERENCES wallet_ledger.journal_entries(id) ON DELETE CASCADE,
    account_id UUID NOT NULL REFERENCES wallet_ledger.accounts(id) ON DELETE RESTRICT,
    debit_amount NUMERIC(15, 2) NOT NULL DEFAULT 0.00 CHECK (debit_amount >= 0),
    credit_amount NUMERIC(15, 2) NOT NULL DEFAULT 0.00 CHECK (credit_amount >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    CONSTRAINT chk_debit_credit_xor CHECK (
        (debit_amount > 0 AND credit_amount = 0) OR 
        (credit_amount > 0 AND debit_amount = 0)
    )
);

CREATE INDEX idx_lines_journal ON wallet_ledger.ledger_lines(journal_id);
CREATE INDEX idx_lines_account ON wallet_ledger.ledger_lines(account_id);

-- 8. Settlements Table (`wallet_ledger.settlements`) - Payout Execution Store
CREATE TABLE wallet_ledger.settlements (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    workspace_id UUID NOT NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
    vendor_profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    journal_id UUID NOT NULL REFERENCES wallet_ledger.journal_entries(id) ON DELETE CASCADE,
    amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
    currency public.enum_currency NOT NULL DEFAULT 'TZS',
    status TEXT NOT NULL DEFAULT 'PENDING', -- 'PENDING', 'PROCESSING', 'PAID', 'FAILED'
    reference TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_settlements_vendor ON wallet_ledger.settlements(vendor_profile_id);

-- Triggers for updated_at
CREATE TRIGGER trg_accounts_updated_at BEFORE UPDATE ON wallet_ledger.accounts FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();
CREATE TRIGGER trg_orchestrator_req_updated_at BEFORE UPDATE ON wallet_ledger.orchestrator_requests FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();
CREATE TRIGGER trg_settlements_updated_at BEFORE UPDATE ON wallet_ledger.settlements FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();

-- Populate Default Chart of Accounts & Rules
INSERT INTO wallet_ledger.accounting_rules (intent_type, debit_account_code, credit_account_code, description) VALUES
    ('INTENT_ESCROW_FUND', '1000_CLEARING', '2000_ESCROW_HOLDING', 'Lock customer payment into platform escrow account'),
    ('INTENT_ESCROW_RELEASE', '2000_ESCROW_HOLDING', '2100_VENDOR_PAYABLE', 'Release escrow funds to vendor balance'),
    ('INTENT_COMMISSION_CREDIT', '2000_ESCROW_HOLDING', '2200_AFFILIATE_PAYABLE', 'Credit affiliate commission balance'),
    ('INTENT_PLATFORM_FEE', '2000_ESCROW_HOLDING', '4000_PLATFORM_REVENUE', 'Credit Winger platform fee revenue'),
    ('INTENT_VENDOR_PAYOUT', '2100_VENDOR_PAYABLE', '1000_CLEARING', 'Process vendor bank/mobile payout settlement'),
    ('INTENT_CUSTOMER_REFUND', '2000_ESCROW_HOLDING', '1000_CLEARING', 'Refund escrow funds to customer clearing')
ON CONFLICT (intent_type) DO NOTHING;

-- Seed System Default Accounts
INSERT INTO wallet_ledger.accounts (account_number, name, type, currency) VALUES
    ('1000_CLEARING', 'Platform Payment Gateway Clearing Account', 'ASSET', 'TZS'),
    ('2000_ESCROW_HOLDING', 'Platform Order Escrow Holding Account', 'LIABILITY', 'TZS'),
    ('2100_VENDOR_PAYABLE', 'Vendor Payable Balance Pool', 'LIABILITY', 'TZS'),
    ('2200_AFFILIATE_PAYABLE', 'Affiliate Payable Commission Pool', 'LIABILITY', 'TZS'),
    ('4000_PLATFORM_REVENUE', 'Winger Marketplace Revenue Account', 'REVENUE', 'TZS')
ON CONFLICT (account_number) DO NOTHING;

-- 9. MASTER TRANSACTION ORCHESTRATOR STORED PROCEDURE

CREATE OR REPLACE FUNCTION wallet_ledger.fn_execute_transaction_orchestrator(
    p_idempotency_key TEXT,
    p_intent_type wallet_ledger.enum_intent_type,
    p_payload JSONB,
    p_workspace_id UUID DEFAULT NULL,
    p_actor_profile_id UUID DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_existing_req RECORD;
    v_req_id UUID;
    v_rule RECORD;
    v_debit_acc RECORD;
    v_credit_acc RECORD;
    v_amount NUMERIC(15, 2);
    v_currency public.enum_currency;
    v_journal_id UUID;
    v_outbox_id UUID;
    v_result JSONB;
BEGIN
    -- 1. Validate Idempotency (Check if request has already been processed)
    SELECT * INTO v_existing_req 
    FROM wallet_ledger.orchestrator_requests 
    WHERE idempotency_key = p_idempotency_key FOR UPDATE;

    IF v_existing_req.id IS NOT NULL THEN
        IF v_existing_req.status = 'COMPLETED' THEN
            RETURN v_existing_req.result_envelope;
        ELSIF v_existing_req.status = 'PROCESSING' THEN
            RAISE EXCEPTION 'Concurrent transaction request in progress for key %', p_idempotency_key USING ERRCODE = '55P03';
        END IF;
    END IF;

    -- 2. Extract transaction parameters
    v_amount := (p_payload->>'amount')::NUMERIC;
    v_currency := COALESCE((p_payload->>'currency')::public.enum_currency, 'TZS');

    IF v_amount IS NULL OR v_amount <= 0 THEN
        RAISE EXCEPTION 'Transaction amount must be strictly greater than 0' USING ERRCODE = '22000';
    END IF;

    -- Create Orchestrator Request Record
    INSERT INTO wallet_ledger.orchestrator_requests (
        idempotency_key, intent_type, workspace_id, actor_profile_id, payload, status
    ) VALUES (
        p_idempotency_key, p_intent_type, p_workspace_id, p_actor_profile_id, p_payload, 'PROCESSING'
    ) RETURNING id INTO v_req_id;

    -- 3. Load Accounting Rules from Accounting Rule Engine
    SELECT * INTO v_rule FROM wallet_ledger.accounting_rules WHERE intent_type = p_intent_type;
    IF v_rule.id IS NULL THEN
        RAISE EXCEPTION 'No accounting rule configured for intent %', p_intent_type USING ERRCODE = 'P0002';
    END IF;

    -- Fetch Debit and Credit Accounts
    SELECT * INTO v_debit_acc FROM wallet_ledger.accounts WHERE account_number = v_rule.debit_account_code FOR UPDATE;
    SELECT * INTO v_credit_acc FROM wallet_ledger.accounts WHERE account_number = v_rule.credit_account_code FOR UPDATE;

    IF v_debit_acc.id IS NULL OR v_credit_acc.id IS NULL THEN
        RAISE EXCEPTION 'Debit or Credit account missing for rule %', v_rule.description USING ERRCODE = 'P0002';
    END IF;

    -- 4. Generate Balanced Journal Entry Header
    INSERT INTO wallet_ledger.journal_entries (
        workspace_id, request_id, intent_type, narration, total_amount, currency, status
    ) VALUES (
        p_workspace_id, v_req_id, p_intent_type, v_rule.description, v_amount, v_currency, 'POSTED'
    ) RETURNING id INTO v_journal_id;

    -- 5. Insert Double-Entry Ledger Lines (Debit & Credit)
    -- Debit Line
    INSERT INTO wallet_ledger.ledger_lines (journal_id, account_id, debit_amount, credit_amount)
    VALUES (v_journal_id, v_debit_acc.id, v_amount, 0.00);

    -- Credit Line
    INSERT INTO wallet_ledger.ledger_lines (journal_id, account_id, debit_amount, credit_amount)
    VALUES (v_journal_id, v_credit_acc.id, 0.00, v_amount);

    -- 6. Verify Double-Entry Balance (Debits = Credits)
    IF (SELECT SUM(debit_amount) - SUM(credit_amount) FROM wallet_ledger.ledger_lines WHERE journal_id = v_journal_id) != 0 THEN
        RAISE EXCEPTION 'Double-entry balance check failed for journal %', v_journal_id USING ERRCODE = '22000';
    END IF;

    -- 7. Update Account Balance Projections
    UPDATE wallet_ledger.accounts SET balance = balance + v_amount WHERE id = v_credit_acc.id;
    UPDATE wallet_ledger.accounts SET balance = balance - v_amount WHERE id = v_debit_acc.id;

    -- 8. Publish Financial Events to Outbox
    v_outbox_id := public.fn_publish_domain_event(
        'wallet.ledger_transaction.created',
        'journal_entry',
        v_journal_id,
        jsonb_build_object(
            'journal_id', v_journal_id,
            'intent_type', p_intent_type,
            'amount', v_amount,
            'currency', v_currency,
            'debit_account', v_rule.debit_account_code,
            'credit_account', v_rule.credit_account_code,
            'workspace_id', p_workspace_id
        ),
        p_workspace_id
    );

    -- Build Standardized Result Envelope
    v_result := jsonb_build_object(
        'success', true,
        'code', 'TRANSACTION_COMMITTED',
        'journal_id', v_journal_id,
        'request_id', v_req_id,
        'intent_type', p_intent_type,
        'amount', v_amount,
        'currency', v_currency,
        'debit_account', v_rule.debit_account_code,
        'credit_account', v_rule.credit_account_code,
        'outbox_id', v_outbox_id,
        'timestamp', TIMEZONE('utc', NOW())
    );

    -- Mark Request Completed
    UPDATE wallet_ledger.orchestrator_requests
    SET status = 'COMPLETED',
        journal_id = v_journal_id,
        result_envelope = v_result,
        updated_at = TIMEZONE('utc', NOW())
    WHERE id = v_req_id;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. ROW LEVEL SECURITY (RLS) POLICIES FOR WALLET LEDGER SCHEMA

ALTER TABLE wallet_ledger.accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_ledger.accounting_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_ledger.orchestrator_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_ledger.journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_ledger.ledger_lines ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_ledger.settlements ENABLE ROW LEVEL SECURITY;

-- Accounts RLS (Users can view their own profile/workspace accounts)
CREATE POLICY accounts_own_read ON wallet_ledger.accounts FOR SELECT TO authenticated
    USING (
        profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid())
        OR workspace_id IN (SELECT workspace_id FROM public.memberships WHERE profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()))
        OR current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('ADMIN', 'SUPER_ADMIN', 'FINANCE_MANAGER')
    );

-- Journal Entries RLS (Read-only for workspace members & Finance Managers)
CREATE POLICY journals_own_read ON wallet_ledger.journal_entries FOR SELECT TO authenticated
    USING (
        workspace_id IN (SELECT workspace_id FROM public.memberships WHERE profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()))
        OR current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('ADMIN', 'SUPER_ADMIN', 'FINANCE_MANAGER')
    );

-- Ledger Lines RLS (Insert-only via SECURITY DEFINER, read-only for Finance Managers & Admins)
CREATE POLICY lines_admin_read ON wallet_ledger.ledger_lines FOR SELECT TO authenticated
    USING (current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('ADMIN', 'SUPER_ADMIN', 'FINANCE_MANAGER'));
