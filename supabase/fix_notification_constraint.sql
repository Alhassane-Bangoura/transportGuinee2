-- ============================================================================
-- FIX CRITIQUE : Contrainte unique_notification_spam
-- ============================================================================
-- Ce script corrige les triggers de notification pour ignorer les doublons
-- au lieu de bloquer toute la transaction (publication de trajet ou réservation).
--
-- ✅ À EXÉCUTER dans l'éditeur SQL de votre console Supabase (SQL Editor).
-- ============================================================================

-- ── 1. Correction du trigger : Notification aux passagers lors d'un nouveau trajet ──

CREATE OR REPLACE FUNCTION public.handle_new_trip_notifications()
RETURNS TRIGGER AS $$
DECLARE
    city_departure TEXT;
    city_arrival   TEXT;
    passenger_row  RECORD;
BEGIN
    SELECT dc.name, ac.name INTO city_departure, city_arrival
    FROM routes r
    JOIN cities dc ON r.departure_city_id = dc.id
    JOIN cities ac ON r.arrival_city_id = ac.id
    WHERE r.id = NEW.route_id;

    FOR passenger_row IN
        SELECT id FROM profiles WHERE role = 'passenger'
    LOOP
        INSERT INTO public.notifications (user_id, title, message, type, metadata)
        VALUES (
            passenger_row.id,
            'Nouveau trajet disponible ! 🚀',
            'Un nouveau départ de ' || COALESCE(city_departure, 'votre ville') ||
            ' vers ' || COALESCE(city_arrival, 'votre destination') || ' vient d''être publié.',
            'new_trip',
            jsonb_build_object('trip_id', NEW.id, 'route_id', NEW.route_id)
        )
        ON CONFLICT ON CONSTRAINT unique_notification_spam DO NOTHING;
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ── 2. Correction du trigger : Notification au chauffeur lors d'une réservation ──

CREATE OR REPLACE FUNCTION public.handle_new_booking_notifications()
RETURNS TRIGGER AS $$
DECLARE
    driver_uid     UUID;
    passenger_name TEXT;
    city_departure TEXT;
    city_arrival   TEXT;
BEGIN
    SELECT t.driver_id, dc.name, ac.name INTO driver_uid, city_departure, city_arrival
    FROM trips t
    JOIN routes r ON t.route_id = r.id
    JOIN cities dc ON r.departure_city_id = dc.id
    JOIN cities ac ON r.arrival_city_id = ac.id
    WHERE t.id = NEW.trip_id;

    SELECT full_name INTO passenger_name FROM profiles WHERE id = NEW.user_id;

    IF driver_uid IS NOT NULL THEN
        INSERT INTO public.notifications (user_id, title, message, type, metadata)
        VALUES (
            driver_uid,
            'Nouvelle réservation ! 🎟️',
            COALESCE(passenger_name, 'Un passager') ||
            ' a réservé une place pour votre trajet ' ||
            COALESCE(city_departure, '') || ' ➔ ' || COALESCE(city_arrival, '') || '.',
            'new_booking',
            jsonb_build_object('booking_id', NEW.id, 'trip_id', NEW.trip_id)
        )
        ON CONFLICT ON CONSTRAINT unique_notification_spam DO NOTHING;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ── 3. Correction du second trigger de trajet (database_fix.sql) ──

CREATE OR REPLACE FUNCTION public.notify_passengers_on_new_trip()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.notifications (user_id, title, message, body, type)
    SELECT
        id,
        'Nouveau trajet disponible !',
        'Un chauffeur vient de publier un trajet sur l''itinéraire ' ||
            (SELECT name FROM routes WHERE id = NEW.route_id),
        'Un chauffeur vient de publier un trajet sur l''itinéraire ' ||
            (SELECT name FROM routes WHERE id = NEW.route_id),
        'trip_published'
    FROM public.profiles
    WHERE role = 'passenger'
    ON CONFLICT DO NOTHING;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ── 4. Vérification : Recréer les triggers proprement ──

DROP TRIGGER IF EXISTS trg_notify_on_new_trip ON public.trips;
CREATE TRIGGER trg_notify_on_new_trip
    AFTER INSERT ON public.trips
    FOR EACH ROW
    WHEN (NEW.status = 'scheduled')
    EXECUTE FUNCTION public.handle_new_trip_notifications();

DROP TRIGGER IF EXISTS trg_notify_on_new_booking ON public.bookings;
CREATE TRIGGER trg_notify_on_new_booking
    AFTER INSERT ON public.bookings
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_booking_notifications();

-- ============================================================================
-- ✅ FIN DU SCRIPT — Résumé :
-- Les triggers insèrent désormais ON CONFLICT DO NOTHING.
-- La publication de trajet et la réservation ne seront plus bloquées.
-- ============================================================================
