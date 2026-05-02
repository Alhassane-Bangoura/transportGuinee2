-- ============================================================================
-- MIGRATION : Système transactionnel AVANCÉ de gestion des places
-- ============================================================================

-- Fonction pour gérer la déduction et restauration des places selon le statut
CREATE OR REPLACE FUNCTION public.handle_booking_seats_status()
RETURNS TRIGGER AS $$
BEGIN
  -- 1. Cas INSERT directement en 'confirmed' (optionnel mais robuste)
  -- ou UPDATE passant de 'pending' (ou autre) à 'confirmed'
  IF (TG_OP = 'INSERT' AND NEW.status = 'confirmed') OR 
     (TG_OP = 'UPDATE' AND OLD.status != 'confirmed' AND NEW.status = 'confirmed') THEN
    
    -- Tente de déduire les places si disponibles
    UPDATE public.trips
    SET available_seats = available_seats - NEW.seats
    WHERE id = NEW.trip_id
    AND available_seats >= NEW.seats;

    -- Si l'update échoue (0 ligne affectée), c'est qu'il n'y a plus de places
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Not enough seats';
    END IF;

  -- 2. Cas UPDATE passant de 'confirmed' à 'cancelled'
  ELSIF TG_OP = 'UPDATE' AND OLD.status = 'confirmed' AND NEW.status = 'cancelled' THEN
    
    -- Restitue les places au trajet
    UPDATE public.trips
    SET available_seats = available_seats + NEW.seats
    WHERE id = NEW.trip_id;

  -- 3. (Sécurité) Cas DELETE d'un booking qui était confirmé
  ELSIF TG_OP = 'DELETE' AND OLD.status = 'confirmed' THEN
    
    UPDATE public.trips
    SET available_seats = available_seats + OLD.seats
    WHERE id = OLD.trip_id;
    
    RETURN OLD;

  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Nettoyage de l'ancien trigger éventuel
DROP TRIGGER IF EXISTS trg_update_seats ON public.bookings;
DROP TRIGGER IF EXISTS trg_booking_seats_status ON public.bookings;

-- Création du Trigger global (INSERT, UPDATE, DELETE)
CREATE TRIGGER trg_booking_seats_status
BEFORE INSERT OR UPDATE OR DELETE ON public.bookings
FOR EACH ROW
EXECUTE FUNCTION public.handle_booking_seats_status();
