-- ============================================================================
-- GUINÉE TRANSPORT — CONFIGURATION DU STOCKAGE (STORAGE)
-- ============================================================================
-- Ce script configure le bucket de stockage pour les photos de profil.
-- À copier et exécuter dans l'éditeur SQL de Supabase (Dashboard > SQL Editor).
-- ============================================================================

-- 1. Création du bucket 'profiles' s'il n'existe pas
INSERT INTO storage.buckets (id, name, public)
VALUES ('profiles', 'profiles', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Suppression des anciennes politiques pour éviter les doublons
DROP POLICY IF EXISTS "Avatar public access" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload their own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own avatar" ON storage.objects;

-- 3. Politique d'accès public en lecture
-- Tout le monde peut voir les photos de profil
CREATE POLICY "Avatar public access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'profiles' );

-- 4. Politique d'insertion (Upload)
-- Un utilisateur authentifié peut uploader dans son propre dossier (nommé par son ID)
CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'profiles' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- 5. Politique de mise à jour (Update)
CREATE POLICY "Users can update their own avatar"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'profiles' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- 6. Politique de suppression (Delete)
CREATE POLICY "Users can delete their own avatar"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'profiles' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);
