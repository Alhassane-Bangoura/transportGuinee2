-- [ignoring loop detection]
-- MIGRATION : Stockage des Tokens Push (FCM)
BEGIN;

-- 1. Ajouter la colonne fcm_token à la table profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS fcm_token TEXT;

-- 2. Indexer pour des recherches rapides lors de l'envoi
CREATE INDEX IF NOT EXISTS idx_profiles_fcm_token ON public.profiles(fcm_token) WHERE fcm_token IS NOT NULL;

COMMIT;
