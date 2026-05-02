-- ============================================================================
-- 💳 ADD PAYMENT METHOD TO BOOKINGS
-- ============================================================================
-- Ajoute la colonne payment_method à la table bookings pour assurer la traçabilité.
-- ============================================================================

-- 1. Ajouter la colonne si elle n'existe pas
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS payment_method TEXT DEFAULT 'at_station';

-- 2. Mettre à jour les politiques (si nécessaire, mais RLS devrait déjà l'inclure via *)
-- 3. Mettre à jour la vue trips_with_details si besoin (si elle ne fait pas t.*)
-- La vue trips_with_details fait déjà t.* donc elle inclura automatiquement la colonne.

-- ============================================================================
-- ✅ RÉSULTAT : 
-- Les nouvelles réservations enregistreront le mode de paiement (Orange, MoMo, Gare).
-- ============================================================================
