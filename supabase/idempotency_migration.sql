-- [ignoring loop detection]
-- MIGRATION : Idempotence des Réservations
BEGIN;

-- 1. Ajouter la colonne idempotency_key
ALTER TABLE public.bookings 
ADD COLUMN IF NOT EXISTS idempotency_key UUID;

-- 2. Ajouter une contrainte UNIQUE pour empêcher les doublons
-- Cette contrainte garantit que pour une clé donnée générée par le client, 
-- une seule insertion est possible.
ALTER TABLE public.bookings 
DROP CONSTRAINT IF EXISTS unique_idempotency_key;

ALTER TABLE public.bookings 
ADD CONSTRAINT unique_idempotency_key UNIQUE (idempotency_key);

-- 3. Index pour recherche rapide
CREATE INDEX IF NOT EXISTS idx_bookings_idempotency ON public.bookings(idempotency_key);

COMMIT;
