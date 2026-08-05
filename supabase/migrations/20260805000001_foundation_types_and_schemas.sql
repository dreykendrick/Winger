-- Winger Backend V2 - Sprint 1: Foundation
-- Migration: 20260805000001_foundation_types_and_schemas.sql
-- Description: Creates isolated schemas, UUIDv7 generator, and global domain enums.

-- 1. Create Isolated System Schemas
CREATE SCHEMA IF NOT EXISTS order_guardian;
CREATE SCHEMA IF NOT EXISTS wallet_ledger;
CREATE SCHEMA IF NOT EXISTS audit_system;

-- Grant schema usage
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT USAGE ON SCHEMA order_guardian TO service_role;
GRANT USAGE ON SCHEMA wallet_ledger TO service_role;
GRANT USAGE ON SCHEMA audit_system TO service_role;

-- 2. PostgreSQL UUIDv7 Generator Function
-- Generates time-ordered 128-bit UUIDv7 for index locality and B-tree optimization.
CREATE OR REPLACE FUNCTION public.gen_random_uuid_v7()
RETURNS UUID AS $$
DECLARE
    v_time DOUBLE PRECISION;
    v_epoch_ms BIGINT;
    v_time_hex TEXT;
    v_bytes BYTEA;
    v_guid TEXT;
BEGIN
    v_time := extract(epoch FROM clock_timestamp());
    v_epoch_ms := floor(v_time * 1000)::BIGINT;
    v_time_hex := lpad(to_hex(v_epoch_ms), 12, '0');
    v_bytes := gen_random_bytes(10);
    
    -- Construct UUIDv7 hex string
    v_guid := substr(v_time_hex, 1, 8) || '-' ||
              substr(v_time_hex, 9, 4) || '-' ||
              '7' || substr(to_hex((get_byte(v_bytes, 0) & 15) | 0), 1, 1) || substr(to_hex(get_byte(v_bytes, 1)), 1, 2) || '-' ||
              to_hex((get_byte(v_bytes, 2) & 63) | 128) || to_hex(get_byte(v_bytes, 3)) || '-' ||
              to_hex(get_byte(v_bytes, 4)) || to_hex(get_byte(v_bytes, 5)) ||
              to_hex(get_byte(v_bytes, 6)) || to_hex(get_byte(v_bytes, 7)) ||
              to_hex(get_byte(v_bytes, 8)) || to_hex(get_byte(v_bytes, 9));
              
    RETURN v_guid::UUID;
END;
$$ LANGUAGE plpgsql VOLATILE;

COMMENT ON FUNCTION public.gen_random_uuid_v7() IS 'Generates time-sortable UUIDv7 primary keys to prevent B-tree index fragmentation.';

-- 3. Global Domain Enums

-- User Roles
CREATE TYPE public.enum_user_role AS ENUM (
    'CUSTOMER',
    'VENDOR',
    'AFFILIATE',
    'SUPPORT',
    'FINANCE_MANAGER',
    'ADMIN',
    'SUPER_ADMIN'
);

-- Account Statuses
CREATE TYPE public.enum_account_status AS ENUM (
    'PENDING_VERIFICATION',
    'ACTIVE',
    'SUSPENDED',
    'DEACTIVATED'
);

-- Verification Statuses (Vendor/Affiliate onboarding)
CREATE TYPE public.enum_verification_status AS ENUM (
    'UNSUBMITTED',
    'PENDING_REVIEW',
    'APPROVED',
    'REJECTED',
    'REQUIRES_REVISION'
);

-- Notification Channels
CREATE TYPE public.enum_notification_channel AS ENUM (
    'IN_APP',
    'PUSH',
    'EMAIL',
    'SMS'
);

-- Languages
CREATE TYPE public.enum_language AS ENUM (
    'en',
    'sw',
    'fr'
);

-- Currencies
CREATE TYPE public.enum_currency AS ENUM (
    'TZS',
    'KES',
    'UGX',
    'USD'
);

COMMENT ON TYPE public.enum_user_role IS 'Global RBAC user roles.';
COMMENT ON TYPE public.enum_account_status IS 'Global user account state.';
COMMENT ON TYPE public.enum_verification_status IS 'KYC & vendor onboarding verification states.';
