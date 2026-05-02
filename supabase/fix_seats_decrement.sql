-- ============================================================================
-- 💺 FIX SEATS : DÉCRÉMENTATION DES PLACES EN TEMPS RÉEL
-- ============================================================================
-- Ce script s'assure que le nombre de places disponibles diminue 
-- AUTOMATIQUEMENT dès qu'une réservation est faite (même en attente).
-- ============================================================================

-- 1. Recréation de la fonction de calcul des sièges
CREATE OR REPLACE FUNCTION public.update_trip_seats_on_booking()
RETURNS TRIGGER AS $$
BEGIN
    -- On ne s'occupe que des insertions pour la décrémentation
    IF (TG_OP = 'INSERT') THEN
        -- Si le statut est 'pending' (attente) ou 'confirmed', on décrémente
        IF NEW.status IN ('pending', 'confirmed') THEN
            UPDATE public.trips
            SET available_seats = available_seats - NEW.seats
            WHERE id = NEW.trip_id;
            
            -- Debug : Log de l'opération
            RAISE NOTICE 'Décrémentation de % places pour le trajet %', NEW.seats, NEW.trip_id;
        END IF;
        
    -- Si on annule une réservation, on rend les places
    ELSIF (TG_OP = 'UPDATE') THEN
        IF OLD.status IN ('pending', 'confirmed') AND NEW.status = 'cancelled' THEN
            UPDATE public.trips
            SET available_seats = available_seats + OLD.seats
            WHERE id = OLD.trip_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Réinstallation du trigger
DROP TRIGGER IF EXISTS trg_update_seats_on_booking ON public.bookings;
CREATE TRIGGER trg_update_seats_on_booking
    AFTER INSERT OR UPDATE ON public.bookings
    FOR EACH ROW
    EXECUTE FUNCTION public.update_trip_seats_on_booking();

-- 3. Mise à jour de la vue trips_with_details (si nécessaire)
-- On s'assure que available_seats est bien la colonne de la table trips
-- La vue trips_with_details utilise t.* donc elle sera à jour.

-- ============================================================================
-- ✅ RÉSULTAT : 
-- Chaque nouvelle réservation (Orange Money, MoMo ou Gare) 
-- diminue instantanément le nombre de places sur le tableau de bord du chauffeur.
-- ============================================================================
