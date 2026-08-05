-- Winger Backend V2 - Sprint 2: Marketplace Catalog, Vendor Store Onboarding & Affiliate Attribution Engine
-- Migration: 20260806000001_sprint2_marketplace_and_affiliate.sql
-- Description: Creates organizations, workspaces, memberships, categories, vendors, products, variants, media, carts, cart_items, affiliates, affiliate_links, and 30-day attributions.

-- 1. Enums for Sprint 2
CREATE TYPE public.enum_product_status AS ENUM (
    'DRAFT',
    'ACTIVE',
    'OUT_OF_STOCK',
    'ARCHIVED'
);

CREATE TYPE public.enum_workspace_type AS ENUM (
    'PERSONAL',
    'STORE_VENDOR',
    'AFFILIATE_NETWORK',
    'ENTERPRISE'
);

-- 2. Organizations Table (`public.organizations`)
CREATE TABLE public.organizations (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    name TEXT NOT NULL,
    tax_id TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    deleted_at TIMESTAMPTZ NULL
);

-- 3. Workspaces Table (`public.workspaces`)
CREATE TABLE public.workspaces (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    organization_id UUID NULL REFERENCES public.organizations(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    type public.enum_workspace_type NOT NULL DEFAULT 'STORE_VENDOR',
    settings JSONB NOT NULL DEFAULT '{}'::jsonb,
    version INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    deleted_at TIMESTAMPTZ NULL
);

CREATE UNIQUE INDEX idx_workspaces_slug_active ON public.workspaces(slug) WHERE deleted_at IS NULL;

-- 4. Memberships Table (`public.memberships`)
CREATE TABLE public.memberships (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    workspace_id UUID NOT NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
    status public.enum_account_status NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    CONSTRAINT uq_profile_workspace UNIQUE (profile_id, workspace_id)
);

CREATE INDEX idx_memberships_profile ON public.memberships(profile_id);
CREATE INDEX idx_memberships_workspace ON public.memberships(workspace_id);

-- 5. Product Categories Table (`public.categories`)
CREATE TABLE public.categories (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    workspace_id UUID NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
    parent_id UUID NULL REFERENCES public.categories(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    slug TEXT NOT NULL,
    icon_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    deleted_at TIMESTAMPTZ NULL,
    CONSTRAINT uq_category_slug UNIQUE (slug)
);

CREATE INDEX idx_categories_parent ON public.categories(parent_id);

-- 6. Vendors Table (`public.vendors`)
CREATE TABLE public.vendors (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    workspace_id UUID NOT NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
    profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    store_name TEXT NOT NULL,
    store_slug TEXT UNIQUE NOT NULL,
    bio TEXT,
    logo_url TEXT,
    banner_url TEXT,
    verification_status public.enum_verification_status NOT NULL DEFAULT 'UNSUBMITTED',
    version INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    deleted_at TIMESTAMPTZ NULL
);

CREATE UNIQUE INDEX idx_vendors_slug_active ON public.vendors(store_slug) WHERE deleted_at IS NULL;
CREATE INDEX idx_vendors_workspace ON public.vendors(workspace_id);
CREATE INDEX idx_vendors_profile ON public.vendors(profile_id);

-- 7. Products Table (`public.products`)
CREATE TABLE public.products (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    workspace_id UUID NOT NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
    vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    slug TEXT NOT NULL,
    description TEXT,
    base_price NUMERIC(15, 2) NOT NULL CHECK (base_price >= 0),
    currency public.enum_currency NOT NULL DEFAULT 'TZS',
    status public.enum_product_status NOT NULL DEFAULT 'DRAFT',
    version INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    deleted_at TIMESTAMPTZ NULL,
    CONSTRAINT uq_vendor_product_slug UNIQUE (vendor_id, slug)
);

CREATE INDEX idx_products_workspace ON public.products(workspace_id);
CREATE INDEX idx_products_vendor ON public.products(vendor_id);
CREATE INDEX idx_products_category ON public.products(category_id);
CREATE INDEX idx_products_status ON public.products(status);

-- 8. Product Variants Table (`public.product_variants`)
CREATE TABLE public.product_variants (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    sku TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    price NUMERIC(15, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    version INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    deleted_at TIMESTAMPTZ NULL
);

CREATE INDEX idx_variants_product ON public.product_variants(product_id);
CREATE INDEX idx_variants_sku ON public.product_variants(sku);

-- 9. Product Media Table (`public.product_media`)
CREATE TABLE public.product_media (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    display_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_media_product ON public.product_media(product_id);

-- 10. Shopping Carts Table (`public.carts`)
CREATE TABLE public.carts (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    workspace_id UUID NOT NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
    profile_id UUID NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    session_id TEXT NULL,
    currency public.enum_currency NOT NULL DEFAULT 'TZS',
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_carts_profile ON public.carts(profile_id);
CREATE INDEX idx_carts_session ON public.carts(session_id);

-- 11. Cart Items Table (`public.cart_items`)
CREATE TABLE public.cart_items (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    cart_id UUID NOT NULL REFERENCES public.carts(id) ON DELETE CASCADE,
    product_variant_id UUID NOT NULL REFERENCES public.product_variants(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    unit_price NUMERIC(15, 2) NOT NULL CHECK (unit_price >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    CONSTRAINT uq_cart_variant UNIQUE (cart_id, product_variant_id)
);

CREATE INDEX idx_cart_items_cart ON public.cart_items(cart_id);

-- 12. Affiliates Table (`public.affiliates`)
CREATE TABLE public.affiliates (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    profile_id UUID UNIQUE NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    affiliate_code TEXT UNIQUE NOT NULL,
    commission_rate_override NUMERIC(5, 2) NULL CHECK (commission_rate_override BETWEEN 0 AND 100),
    verification_status public.enum_verification_status NOT NULL DEFAULT 'APPROVED',
    version INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_affiliates_profile ON public.affiliates(profile_id);
CREATE INDEX idx_affiliates_code ON public.affiliates(affiliate_code);

-- 13. Affiliate Referral Links Table (`public.affiliate_links`)
CREATE TABLE public.affiliate_links (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    affiliate_id UUID NOT NULL REFERENCES public.affiliates(id) ON DELETE CASCADE,
    product_id UUID NULL REFERENCES public.products(id) ON DELETE SET NULL,
    unique_code TEXT UNIQUE NOT NULL,
    target_url TEXT NOT NULL,
    clicks_count BIGINT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_affiliate_links_affiliate ON public.affiliate_links(affiliate_id);
CREATE INDEX idx_affiliate_links_code ON public.affiliate_links(unique_code);

-- 14. 30-Day Attributions Table (`public.attributions`)
CREATE TABLE public.attributions (
    id UUID PRIMARY KEY DEFAULT public.gen_random_uuid_v7(),
    affiliate_link_id UUID NOT NULL REFERENCES public.affiliate_links(id) ON DELETE CASCADE,
    affiliate_id UUID NOT NULL REFERENCES public.affiliates(id) ON DELETE CASCADE,
    visitor_ip INET NULL,
    user_agent TEXT NULL,
    cookie_token TEXT UNIQUE NOT NULL,
    converted_at TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    expires_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW() + INTERVAL '30 days')
);

CREATE INDEX idx_attributions_token ON public.attributions(cookie_token);
CREATE INDEX idx_attributions_affiliate ON public.attributions(affiliate_id);
CREATE INDEX idx_attributions_expires ON public.attributions(expires_at);

-- Triggers for updated_at
CREATE TRIGGER trg_workspaces_updated_at BEFORE UPDATE ON public.workspaces FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();
CREATE TRIGGER trg_vendors_updated_at BEFORE UPDATE ON public.vendors FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();
CREATE TRIGGER trg_products_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();
CREATE TRIGGER trg_variants_updated_at BEFORE UPDATE ON public.product_variants FOR EACH ROW EXECUTE FUNCTION public.fn_touch_updated_at();

-- 15. ROW LEVEL SECURITY (RLS) POLICIES FOR SPRINT 2

ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workspaces ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_media ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.carts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.affiliates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.affiliate_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attributions ENABLE ROW LEVEL SECURITY;

-- Public Read Catalog Policies
CREATE POLICY categories_public_read ON public.categories FOR SELECT TO public USING (deleted_at IS NULL);
CREATE POLICY vendors_public_read ON public.vendors FOR SELECT TO public USING (deleted_at IS NULL);
CREATE POLICY products_public_read ON public.products FOR SELECT TO public USING (status = 'ACTIVE' AND deleted_at IS NULL);
CREATE POLICY variants_public_read ON public.product_variants FOR SELECT TO public USING (deleted_at IS NULL);
CREATE POLICY media_public_read ON public.product_media FOR SELECT TO public USING (TRUE);

-- Vendor Owner Update Policies
CREATE POLICY products_vendor_manage ON public.products FOR ALL TO authenticated
    USING (
        vendor_id IN (SELECT id FROM public.vendors WHERE profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()))
        OR current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('ADMIN', 'SUPER_ADMIN')
    );

CREATE POLICY variants_vendor_manage ON public.product_variants FOR ALL TO authenticated
    USING (
        product_id IN (SELECT id FROM public.products WHERE vendor_id IN (SELECT id FROM public.vendors WHERE profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid())))
        OR current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('ADMIN', 'SUPER_ADMIN')
    );

-- Cart Policies
CREATE POLICY carts_own_access ON public.carts FOR ALL TO authenticated
    USING (profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()));

CREATE POLICY cart_items_own_access ON public.cart_items FOR ALL TO authenticated
    USING (cart_id IN (SELECT id FROM public.carts WHERE profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid())));

-- Affiliate Policies
CREATE POLICY affiliates_read_public ON public.affiliates FOR SELECT TO authenticated USING (TRUE);
CREATE POLICY affiliate_links_own ON public.affiliate_links FOR ALL TO authenticated
    USING (affiliate_id IN (SELECT id FROM public.affiliates WHERE profile_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid())));
