-- Winger Backend V2 - Sprint 1: Foundation
-- Migration: 20260805000005_foundation_storage_buckets.sql
-- Description: Creates storage bucket architecture and storage object RLS security policies.

-- 1. Initialize Storage Buckets
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types) VALUES
    ('avatars', 'avatars', TRUE, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']),
    ('vendor-assets', 'vendor-assets', TRUE, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/svg+xml']),
    ('product-images', 'product-images', TRUE, 15728640, ARRAY['image/jpeg', 'image/png', 'image/webp']),
    ('documents', 'documents', FALSE, 20971520, ARRAY['application/pdf', 'image/jpeg', 'image/png']),
    ('delivery-proofs', 'delivery-proofs', FALSE, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf'])
ON CONFLICT (id) DO UPDATE SET
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- 2. Storage Objects RLS Policies

-- Public Read for public buckets (avatars, vendor-assets, product-images)
CREATE POLICY storage_public_read
    ON storage.objects FOR SELECT
    TO public
    USING (bucket_id IN ('avatars', 'vendor-assets', 'product-images'));

-- Authenticated Users can upload their own avatar
CREATE POLICY storage_avatar_upload_own
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK (
        bucket_id = 'avatars' 
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

CREATE POLICY storage_avatar_update_own
    ON storage.objects FOR UPDATE
    TO authenticated
    USING (
        bucket_id = 'avatars' 
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

-- Vendor Assets upload (restricted to Vendors and Admins)
CREATE POLICY storage_vendor_assets_upload
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK (
        bucket_id = 'vendor-assets'
        AND current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('VENDOR', 'ADMIN', 'SUPER_ADMIN')
    );

-- Private Documents upload & read (KYC, contracts, business verification)
CREATE POLICY storage_documents_owner_read
    ON storage.objects FOR SELECT
    TO authenticated
    USING (
        bucket_id = 'documents'
        AND (
            (storage.foldername(name))[1] = auth.uid()::text
            OR current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('ADMIN', 'SUPER_ADMIN', 'FINANCE_MANAGER')
        )
    );

CREATE POLICY storage_documents_owner_upload
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK (
        bucket_id = 'documents'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

-- Delivery Proofs upload & access rules (Order Guardian / Logistics)
CREATE POLICY storage_delivery_proofs_read
    ON storage.objects FOR SELECT
    TO authenticated
    USING (
        bucket_id = 'delivery-proofs'
        AND current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('VENDOR', 'SUPPORT', 'ADMIN', 'SUPER_ADMIN')
    );

CREATE POLICY storage_delivery_proofs_upload
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK (
        bucket_id = 'delivery-proofs'
        AND current_setting('request.jwt.claims', true)::jsonb->'app_metadata'->>'user_role' IN ('VENDOR', 'SUPPORT', 'ADMIN', 'SUPER_ADMIN')
    );
