-- Winger Backend V2 - Sprint 4: Growth Engine (Affiliate Platform)
-- Migration: 20260806000004_sprint4_growth_engine.sql
-- Description: Creates isolated growth schema, campaigns, affiliate_profiles, affiliate_links, click_sessions, attributions, conversions, commission_rules, commissions, analytics_daily, fraud_flags, and rule precedence RPCs.

-- 1. Create Isolated Growth Schema
CREATE SCHEMA IF NOT EXISTS growth;
GRANT USAGE ON SCHEMA growth TO anon, authenticated, service_role;

-- 2. Domain Enums
CREATE TYPE growth.enum_campaign_status AS ENUM (
    'DRAFT',
    'ACTIVE',
    'PAUSED',
    'COMPLETED',
    'ARCHIVED'
);

CREATE TYPE growth.enum_attribution_model AS ENUM (
    'LAST_CLICK',
    'FIRST_CLICK',
    'TIME_DECAY'
);

CREATE TYPE growth.enum_conversion_status AS ENUM (
    'PENDING',
    'CONFIRMED',
    'CANCELLED',
    'REFUNDED',
    'EXPIRED'
);

CREATE TYPE growth.enum_commission_rule_type AS ENUM (
    'PERCENTAGE',
    'FIXED',
    'TIERED'
);

CREATE TYPE growth.enum_commission_status AS ENUM (
    'CALCULATED',
    'APPROVED',
    'DISPUTED',
    'CANCELLED'
);

CREATE TYPE growth.enum_fraud_flag_type AS ENUM (
    'SELF_REFERRAL',
    'DUPLICATE_CLICK',
    'CLICK_SPAM',
    'VELOCITY_SPIKE',
    'REPEAT_IP'
);

-- 3. Campaigns Table (`growth.campaigns`)
CREATE TABLE growth.campaigns (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT NULL,
    status growth.enum_campaign_status NOT NULL DEFAULT 'DRAFT',
    start_date TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    end_date TIMESTAMPTZ NULL,
    budget NUMERIC(15, 2) NULL CHECK (budget IS NULL OR budget >= 0),
    target_product_ids UUID[] DEFAULT '{}',
    target_category_ids UUID[] DEFAULT '{}',
    default_commission_rate NUMERIC(5, 2) NOT NULL DEFAULT 5.00 CHECK (default_commission_rate BETWEEN 0 AND 100),
    visibility TEXT NOT NULL DEFAULT 'PUBLIC',
    tracking_settings JSONB NOT NULL DEFAULT '{"attribution_window_days": 30}'::jsonb,
    version INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    deleted_at TIMESTAMPTZ NULL
);

CREATE INDEX idx_campaigns_org ON growth.campaigns(organization_id);
CREATE INDEX idx_campaigns_status ON growth.campaigns(status);

-- 4. Affiliate Profiles Table (`growth.affiliate_profiles`)
CREATE TABLE growth.affiliate_profiles (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    workspace_id UUID NOT NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
    profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    affiliate_code TEXT UNIQUE NOT NULL,
    tier TEXT NOT NULL DEFAULT 'STANDARD',
    status public.enum_account_status NOT NULL DEFAULT 'ACTIVE',
    version INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    CONSTRAINT uq_growth_affiliate_code UNIQUE (affiliate_code)
);

CREATE INDEX idx_growth_affiliates_workspace ON growth.affiliate_profiles(workspace_id);
CREATE INDEX idx_growth_affiliates_profile ON growth.affiliate_profiles(profile_id);

-- 5. Affiliate Tracking Links Table (`growth.affiliate_links`)
CREATE TABLE growth.affiliate_links (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    campaign_id UUID NULL REFERENCES growth.campaigns(id) ON DELETE SET NULL,
    affiliate_id UUID NOT NULL REFERENCES growth.affiliate_profiles(id) ON DELETE CASCADE,
    product_id UUID NULL REFERENCES public.products(id) ON DELETE SET NULL,
    short_code TEXT UNIQUE NOT NULL,
    target_url TEXT NOT NULL,
    expires_at TIMESTAMPTZ NULL,
    click_count BIGINT NOT NULL DEFAULT 0,
    conversion_count BIGINT NOT NULL DEFAULT 0,
    metadata JSONB NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_growth_links_code ON growth.affiliate_links(short_code);
CREATE INDEX idx_growth_links_campaign ON growth.affiliate_links(campaign_id);
CREATE INDEX idx_growth_links_affiliate ON growth.affiliate_links(affiliate_id);

-- 6. High-Volume Click Sessions Table (`growth.click_sessions`)
CREATE TABLE growth.click_sessions (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    link_id UUID NOT NULL REFERENCES growth.affiliate_links(id) ON DELETE CASCADE,
    affiliate_id UUID NOT NULL REFERENCES growth.affiliate_profiles(id) ON DELETE CASCADE,
    campaign_id UUID NULL REFERENCES growth.campaigns(id) ON DELETE SET NULL,
    product_id UUID NULL REFERENCES public.products(id) ON DELETE SET NULL,
    session_token TEXT UNIQUE NOT NULL,
    ip_hash TEXT NOT NULL,
    user_agent TEXT NULL,
    country TEXT NULL,
    device TEXT NULL,
    browser TEXT NULL,
    referrer TEXT NULL,
    utm_params JSONB NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_click_sessions_token ON growth.click_sessions(session_token);
CREATE INDEX idx_click_sessions_affiliate ON growth.click_sessions(affiliate_id);
CREATE INDEX idx_click_sessions_created ON growth.click_sessions(created_at DESC);

-- 7. Attributions Table (`growth.attributions`)
CREATE TABLE growth.attributions (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    click_session_id UUID NOT NULL REFERENCES growth.click_sessions(id) ON DELETE CASCADE,
    affiliate_id UUID NOT NULL REFERENCES growth.affiliate_profiles(id) ON DELETE CASCADE,
    campaign_id UUID NULL REFERENCES growth.campaigns(id) ON DELETE SET NULL,
    visitor_token TEXT UNIQUE NOT NULL,
    model growth.enum_attribution_model NOT NULL DEFAULT 'LAST_CLICK',
    status growth.enum_conversion_status NOT NULL DEFAULT 'PENDING',
    expires_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW() + INTERVAL '30 days'),
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_growth_attributions_token ON growth.attributions(visitor_token);
CREATE INDEX idx_growth_attributions_affiliate ON growth.attributions(affiliate_id);

-- 8. Conversions Table (`growth.conversions`) - Generated from Domain Events
CREATE TABLE growth.conversions (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    order_id UUID NOT NULL,
    attribution_id UUID NOT NULL REFERENCES growth.attributions(id) ON DELETE CASCADE,
    affiliate_id UUID NOT NULL REFERENCES growth.affiliate_profiles(id) ON DELETE CASCADE,
    campaign_id UUID NULL REFERENCES growth.campaigns(id) ON DELETE SET NULL,
    sale_amount NUMERIC(15, 2) NOT NULL CHECK (sale_amount >= 0),
    currency public.enum_currency NOT NULL DEFAULT 'TZS',
    status growth.enum_conversion_status NOT NULL DEFAULT 'PENDING',
    version INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_conversions_order ON growth.conversions(order_id);
CREATE INDEX idx_conversions_affiliate ON growth.conversions(affiliate_id);

-- 9. Commission Rules Table (`growth.commission_rules`)
CREATE TABLE growth.commission_rules (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    campaign_id UUID NULL REFERENCES growth.campaigns(id) ON DELETE CASCADE,
    product_id UUID NULL REFERENCES public.products(id) ON DELETE CASCADE,
    category_id UUID NULL REFERENCES public.categories(id) ON DELETE CASCADE,
    vendor_id UUID NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    rule_type growth.enum_commission_rule_type NOT NULL DEFAULT 'PERCENTAGE',
    rate NUMERIC(5, 2) NULL CHECK (rate IS NULL OR rate BETWEEN 0 AND 100),
    fixed_amount NUMERIC(15, 2) NULL CHECK (fixed_amount IS NULL OR fixed_amount >= 0),
    tier_conditions JSONB NULL,
    priority INTEGER NOT NULL DEFAULT 20, -- 100=Campaign, 80=Product, 60=Category, 40=Vendor, 20=Default
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_rules_priority ON growth.commission_rules(priority DESC);

-- 10. Commissions Table (`growth.commissions`) - Immutable Records
CREATE TABLE growth.commissions (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    conversion_id UUID UNIQUE NOT NULL REFERENCES growth.conversions(id) ON DELETE CASCADE,
    affiliate_id UUID NOT NULL REFERENCES growth.affiliate_profiles(id) ON DELETE CASCADE,
    campaign_id UUID NULL REFERENCES growth.campaigns(id) ON DELETE SET NULL,
    rule_id UUID NULL REFERENCES growth.commission_rules(id) ON DELETE SET NULL,
    gross_sale_amount NUMERIC(15, 2) NOT NULL CHECK (gross_sale_amount >= 0),
    commission_amount NUMERIC(15, 2) NOT NULL CHECK (commission_amount >= 0),
    currency public.enum_currency NOT NULL DEFAULT 'TZS',
    status growth.enum_commission_status NOT NULL DEFAULT 'CALCULATED',
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_commissions_affiliate ON growth.commissions(affiliate_id);
CREATE INDEX idx_commissions_conversion ON growth.commissions(conversion_id);

-- 11. Daily Analytics Aggregation (`growth.analytics_daily`)
CREATE TABLE growth.analytics_daily (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    campaign_id UUID NULL REFERENCES growth.campaigns(id) ON DELETE CASCADE,
    affiliate_id UUID NULL REFERENCES growth.affiliate_profiles(id) ON DELETE CASCADE,
    clicks BIGINT NOT NULL DEFAULT 0,
    unique_visitors BIGINT NOT NULL DEFAULT 0,
    conversions BIGINT NOT NULL DEFAULT 0,
    gross_revenue NUMERIC(15, 2) NOT NULL DEFAULT 0,
    commission_total NUMERIC(15, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    CONSTRAINT uq_analytics_date_campaign_affiliate UNIQUE (date, campaign_id, affiliate_id)
);

CREATE INDEX idx_analytics_date ON growth.analytics_daily(date DESC);

-- 12. Fraud Flags Table (`growth.fraud_flags`) - Non-Blocking Signals
CREATE TABLE growth.fraud_flags (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    entity_type TEXT NOT NULL, -- 'CLICK', 'ATTRIBUTION', 'CONVERSION'
    entity_id UUID NOT NULL,
    affiliate_id UUID NOT NULL REFERENCES growth.affiliate_profiles(id) ON DELETE CASCADE,
    flag_type growth.enum_fraud_flag_type NOT NULL,
    risk_score INTEGER NOT NULL CHECK (risk_score BETWEEN 1 AND 100),
    details JSONB NOT NULL DEFAULT '{}'::jsonb,
    status TEXT NOT NULL DEFAULT 'FLAGGED', -- 'FLAGGED', 'REVIEWED', 'DISMISSED'
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_fraud_affiliate ON growth.fraud_flags(affiliate_id);
CREATE INDEX idx_fraud_score ON growth.fraud_flags(risk_score DESC);

-- Triggers for updated_at
CREATE TRIGGER trg_growth_campaigns_updated_at BEFORE UPDATE ON growth.campaigns FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();
CREATE TRIGGER trg_growth_affiliates_updated_at BEFORE UPDATE ON growth.affiliate_profiles FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();
CREATE TRIGGER trg_growth_conversions_updated_at BEFORE UPDATE ON growth.conversions FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();

-- 13. COMMISSION RULE EVALUATION RPC PROCEDURE
CREATE OR REPLACE FUNCTION growth.fn_evaluate_commission_rule(
    p_campaign_id UUID DEFAULT NULL,
    p_product_id UUID DEFAULT NULL,
    p_category_id UUID DEFAULT NULL,
    p_vendor_id UUID DEFAULT NULL,
    p_sale_amount NUMERIC DEFAULT 0
)
RETURNS JSONB AS $$
DECLARE
    v_rule RECORD;
    v_commission_amount NUMERIC(15, 2) := 0;
    v_default_rate NUMERIC(5, 2) := 5.00;
BEGIN
    -- Rule Precedence Evaluation (Campaign > Product > Category > Vendor > Default)
    SELECT * INTO v_rule
    FROM growth.commission_rules
    WHERE (campaign_id = p_campaign_id OR (campaign_id IS NULL AND p_campaign_id IS NULL))
       OR (product_id = p_product_id OR (product_id IS NULL AND p_product_id IS NULL))
       OR (category_id = p_category_id OR (category_id IS NULL AND p_category_id IS NULL))
       OR (vendor_id = p_vendor_id OR (vendor_id IS NULL AND p_vendor_id IS NULL))
    ORDER BY priority DESC
    LIMIT 1;

    IF v_rule.id IS NOT NULL THEN
        IF v_rule.rule_type = 'PERCENTAGE' THEN
            v_commission_amount := ROUND((p_sale_amount * (v_rule.rate / 100.0)), 2);
        ELSIF v_rule.rule_type = 'FIXED' THEN
            v_commission_amount := v_rule.fixed_amount;
        END IF;

        RETURN jsonb_build_object(
            'rule_id', v_rule.id,
            'rule_type', v_rule.rule_type,
            'priority', v_rule.priority,
            'commission_amount', v_commission_amount
        );
    END IF;

    -- Fallback to global default rate (5%)
    v_commission_amount := ROUND((p_sale_amount * (v_default_rate / 100.0)), 2);
    RETURN jsonb_build_object(
        'rule_id', NULL,
        'rule_type', 'DEFAULT_PERCENTAGE',
        'priority', 0,
        'commission_amount', v_commission_amount
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 14. ROW LEVEL SECURITY (RLS) POLICIES FOR GROWTH SCHEMA

ALTER TABLE growth.campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE growth.affiliate_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE growth.affiliate_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE growth.click_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE growth.attributions ENABLE ROW LEVEL SECURITY;
ALTER TABLE growth.conversions ENABLE ROW LEVEL SECURITY;
ALTER TABLE growth.commission_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE growth.commissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE growth.analytics_daily ENABLE ROW LEVEL SECURITY;
ALTER TABLE growth.fraud_flags ENABLE ROW LEVEL SECURITY;

-- Campaigns Policies (Public read for active campaigns, Org owner manage)
CREATE POLICY campaigns_public_read ON growth.campaigns FOR SELECT TO public USING (status = 'ACTIVE' AND deleted_at IS NULL);
CREATE POLICY campaigns_org_manage ON growth.campaigns FOR ALL TO authenticated
    USING (organization_id IN (SELECT organization_id FROM public.workspaces WHERE id IN (SELECT workspace_id FROM public.memberships WHERE profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()))));

-- Affiliate Links Policies
CREATE POLICY growth_links_own_read ON growth.affiliate_links FOR SELECT TO authenticated
    USING (affiliate_id IN (SELECT id FROM growth.affiliate_profiles WHERE profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid())));

CREATE POLICY growth_links_own_insert ON growth.affiliate_links FOR INSERT TO authenticated
    WITH CHECK (affiliate_id IN (SELECT id FROM growth.affiliate_profiles WHERE profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid())));

-- Commissions Policies (Read own commissions)
CREATE POLICY commissions_own_read ON growth.commissions FOR SELECT TO authenticated
    USING (
        affiliate_id IN (SELECT id FROM growth.affiliate_profiles WHERE profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()))
        OR current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('ADMIN', 'SUPER_ADMIN', 'FINANCE_MANAGER')
    );

-- Fraud Flags Policies (Admin & Support read-only)
CREATE POLICY fraud_flags_admin_read ON growth.fraud_flags FOR SELECT TO authenticated
    USING (current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('ADMIN', 'SUPER_ADMIN', 'SUPPORT'));
