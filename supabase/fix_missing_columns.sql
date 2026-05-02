-- ============================================================================
-- 🛠 MIGRATION : AJOUT DES COLONNES MANQUANTES (IDEMPOTENCE & PAIEMENT)
-- ============================================================================
-- Ce script ajoute les colonnes nécessaires au bon fonctionnement
-- de la réservation et évite l'erreur "column not found".
-- ============================================================================

-- 1. Ajouter la colonne idempotency_key (Pour éviter les doublons de réservation)
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS idempotency_key TEXT;
CREATE UNIQUE INDEX IF NOT EXISTS idx_bookings_idempotency_key ON public.bookings (idempotency_key);

-- 2. Ajouter la colonne payment_method (Pour savoir si c'est Orange, MoMo ou Gare)
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS payment_method TEXT DEFAULT 'at_station';

-- 3. Rafraîchir le cache PostgREST (Optionnel mais recommandé)
NOTIFY pgrst, 'reload schema';

-- ============================================================================
-- ✅ RÉSULTAT : 
-- L'erreur "Could not find the idempotency_key column" va disparaître.
-- Les réservations seront protégées contre les doublons.
-- ============================================================================
