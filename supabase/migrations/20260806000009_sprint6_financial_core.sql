-- Winger Backend V2 - Sprint 6: Financial Core Infrastructure
-- Migration: 20260806000009_sprint6_financial_core.sql
-- Description: Extends wallet_ledger schema with wallet_projections, escrow_records, refund_records, reconciliation_logs, fn_compute_wallet_projection, fn_create_refund_transaction, and fn_reconcile_ledger.

-- 1. Domain Enums
CREATE TYPE wallet_ledger.enum_transaction_type AS ENUM (
    'PAYMENT',
    'ESCROW_FUNDING',
    'ESCROW_RELEASE',
    'COMMISSION_CREDIT',
    'VENDOR_PAYOUT',
    'REFUND',
    'ADJUSTMENT'
);

CREATE TYPE wallet_ledger.enum_refund_status AS ENUM (
    'PENDING',
    'COMPLETED',
    'FAILED'
);

-- 2. Wallet Projections Table (`wallet_ledger.wallet_projections`) - Derived from Ledger Data
CREATE TABLE wallet_ledger.wallet_projections (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    account_id UUID UNIQUE NOT NULL REFERENCES wallet_ledger.accounts(id) ON DELETE CASCADE,
    workspace_id UUID NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
    profile_id UUID NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    available_balance NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    pending_balance NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    reserved_balance NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    lifetime_earnings NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    lifetime_payouts NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    currency public.enum_currency NOT NULL DEFAULT 'TZS',
    version INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_projections_account ON wallet_ledger.wallet_projections(account_id);
CREATE INDEX idx_projections_workspace ON wallet_ledger.wallet_projections(workspace_id);

-- 3. Escrow Records Table (`wallet_ledger.escrow_records`)
CREATE TABLE wallet_ledger.escrow_records (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    workspace_id UUID NOT NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
    order_id UUID UNIQUE NOT NULL,
    journal_id UUID NOT NULL REFERENCES wallet_ledger.journal_entries(id) ON DELETE CASCADE,
    amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
    currency public.enum_currency NOT NULL DEFAULT 'TZS',
    status TEXT NOT NULL DEFAULT 'LOCKED', -- 'LOCKED', 'RELEASED', 'REFUNDED'
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_escrow_records_order ON wallet_ledger.escrow_records(order_id);

-- 4. Refund Records Table (`wallet_ledger.refund_records`)
CREATE TABLE wallet_ledger.refund_records (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    workspace_id UUID NOT NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
    order_id UUID NOT NULL,
    journal_id UUID NOT NULL REFERENCES wallet_ledger.journal_entries(id) ON DELETE CASCADE,
    amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
    currency public.enum_currency NOT NULL DEFAULT 'TZS',
    reason TEXT NOT NULL,
    status wallet_ledger.enum_refund_status NOT NULL DEFAULT 'COMPLETED',
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_refund_records_order ON wallet_ledger.refund_records(order_id);

-- 5. Reconciliation Logs Table (`wallet_ledger.reconciliation_logs`)
CREATE TABLE wallet_ledger.reconciliation_logs (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    total_journals BIGINT NOT NULL,
    total_debits NUMERIC(15, 2) NOT NULL,
    total_credits NUMERIC(15, 2) NOT NULL,
    discrepancy_amount NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    is_balanced BOOLEAN NOT NULL DEFAULT TRUE,
    audited_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

-- Triggers for updated_at
CREATE TRIGGER trg_projections_updated_at BEFORE UPDATE ON wallet_ledger.wallet_projections FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();
CREATE TRIGGER trg_escrow_records_updated_at BEFORE UPDATE ON wallet_ledger.escrow_records FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();

-- 6. BALANCE ENGINE & RECONCILIATION PROCEDURES

-- 6.1 Compute Wallet Projection Procedure
CREATE OR REPLACE FUNCTION wallet_ledger.fn_compute_wallet_projection(p_account_id UUID)
RETURNS NUMERIC AS $$
DECLARE
    v_total_debits NUMERIC(15, 2) := 0;
    v_total_credits NUMERIC(15, 2) := 0;
    v_net_balance NUMERIC(15, 2) := 0;
    v_acc RECORD;
BEGIN
    SELECT * INTO v_acc FROM wallet_ledger.accounts WHERE id = p_account_id;
    IF v_acc.id IS NULL THEN
        RAISE EXCEPTION 'Account % not found', p_account_id USING ERRCODE = 'P0002';
    END IF;

    SELECT COALESCE(SUM(debit_amount), 0), COALESCE(SUM(credit_amount), 0)
    INTO v_total_debits, v_total_credits
    FROM wallet_ledger.ledger_lines
    WHERE account_id = p_account_id;

    -- Calculate net balance depending on account classification (Liability/Revenue = Credits - Debits, Asset/Expense = Debits - Credits)
    IF v_acc.type IN ('LIABILITY', 'REVENUE', 'EQUITY') THEN
        v_net_balance := v_total_credits - v_total_debits;
    ELSE
        v_net_balance := v_total_debits - v_total_credits;
    END IF;

    -- Update or insert projection record
    INSERT INTO wallet_ledger.wallet_projections (
        account_id, workspace_id, profile_id, available_balance, currency
    ) VALUES (
        p_account_id, v_acc.workspace_id, v_acc.profile_id, v_net_balance, v_acc.currency
    ) ON CONFLICT (account_id) DO UPDATE
    SET available_balance = v_net_balance,
        updated_at = TIMEZONE('utc', NOW());

    RETURN v_net_balance;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6.2 Create Refund Transaction Procedure
CREATE OR REPLACE FUNCTION wallet_ledger.fn_create_refund_transaction(
    p_workspace_id UUID,
    p_order_id UUID,
    p_amount NUMERIC,
    p_reason TEXT,
    p_idempotency_key TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_orch_result JSONB;
    v_journal_id UUID;
    v_refund_id UUID;
BEGIN
    -- Submit INTENT_CUSTOMER_REFUND intent to Transaction Orchestrator
    v_orch_result := wallet_ledger.fn_execute_transaction_orchestrator(
        p_idempotency_key,
        'INTENT_CUSTOMER_REFUND',
        jsonb_build_object('amount', p_amount, 'currency', 'TZS', 'order_id', p_order_id),
        p_workspace_id
    );

    v_journal_id := (v_orch_result->>'journal_id')::UUID;

    -- Insert Refund Record
    INSERT INTO wallet_ledger.refund_records (
        workspace_id, order_id, journal_id, amount, reason, status
    ) VALUES (
        p_workspace_id, p_order_id, v_journal_id, p_amount, p_reason, 'COMPLETED'
    ) RETURNING id INTO v_refund_id;

    -- Publish RefundCompleted domain event
    PERFORM public.fn_publish_domain_event(
        'wallet.refund.completed',
        'refund',
        v_refund_id,
        jsonb_build_object(
            'refund_id', v_refund_id,
            'order_id', p_order_id,
            'amount', p_amount,
            'journal_id', v_journal_id
        ),
        p_workspace_id
    );

    RETURN jsonb_build_object(
        'status', 'COMPLETED',
        'refund_id', v_refund_id,
        'journal_id', v_journal_id,
        'amount', p_amount
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6.3 Reconcile Ledger Audit Procedure
CREATE OR REPLACE FUNCTION wallet_ledger.fn_reconcile_ledger()
RETURNS JSONB AS $$
DECLARE
    v_total_journals BIGINT;
    v_total_debits NUMERIC(15, 2);
    v_total_credits NUMERIC(15, 2);
    v_discrepancy NUMERIC(15, 2);
    v_is_balanced BOOLEAN;
    v_log_id UUID;
BEGIN
    SELECT COUNT(*) INTO v_total_journals FROM wallet_ledger.journal_entries;
    
    SELECT COALESCE(SUM(debit_amount), 0), COALESCE(SUM(credit_amount), 0)
    INTO v_total_debits, v_total_credits
    FROM wallet_ledger.ledger_lines;

    v_discrepancy := ABS(v_total_debits - v_total_credits);
    v_is_balanced := (v_discrepancy = 0);

    INSERT INTO wallet_ledger.reconciliation_logs (
        total_journals, total_debits, total_credits, discrepancy_amount, is_balanced
    ) VALUES (
        v_total_journals, v_total_debits, v_total_credits, v_discrepancy, v_is_balanced
    ) RETURNING id INTO v_log_id;

    -- Publish LedgerBalanced event
    PERFORM public.fn_publish_domain_event(
        'wallet.ledger.balanced',
        'reconciliation',
        v_log_id,
        jsonb_build_object(
            'log_id', v_log_id,
            'total_debits', v_total_debits,
            'total_credits', v_total_credits,
            'is_balanced', v_is_balanced
        )
    );

    RETURN jsonb_build_object(
        'reconciliation_id', v_log_id,
        'total_journals', v_total_journals,
        'total_debits', v_total_debits,
        'total_credits', v_total_credits,
        'is_balanced', v_is_balanced
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. ROW LEVEL SECURITY (RLS) POLICIES FOR EXTENDED TABLES

ALTER TABLE wallet_ledger.wallet_projections ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_ledger.escrow_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_ledger.refund_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_ledger.reconciliation_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY projections_own_read ON wallet_ledger.wallet_projections FOR SELECT TO authenticated
    USING (profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()));

CREATE POLICY refunds_own_read ON wallet_ledger.refund_records FOR SELECT TO authenticated
    USING (workspace_id IN (SELECT workspace_id FROM public.memberships WHERE profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid())));
