-- ============================================================================
-- FIX #2 : null value in column "message" (23502)
-- ============================================================================
-- La colonne 'name' de la table 'routes' est nullable.
-- Quand elle est NULL, la concaténation donne NULL, ce qui viole la contrainte
-- NOT NULL de la colonne 'message' dans la table 'notifications'.
-- Ce script corrige les deux fonctions responsables de l'erreur.
--
-- ✅ À EXÉCUTER dans l'éditeur SQL de votre console Supabase (SQL Editor).
-- ============================================================================


-- ── 1. Correction de handle_new_trip_notifications ───────────────────────────
-- (Notifie TOUS les passagers quand un trajet est publié en 'scheduled')

CREATE OR REPLACE FUNCTION public.handle_new_trip_notifications()
RETURNS TRIGGER AS $$
DECLARE
    city_departure TEXT;
    city_arrival   TEXT;
    passenger_row  RECORD;
BEGIN
    -- Récupérer les noms des villes
    SELECT dc.name, ac.name INTO city_departure, city_arrival
    FROM routes r
    JOIN cities dc ON r.departure_city_id = dc.id
    JOIN cities ac ON r.arrival_city_id = ac.id
    WHERE r.id = NEW.route_id;

    -- Notifier chaque passager (ON CONFLICT DO NOTHING = pas de doublon bloquant)
    FOR passenger_row IN
        SELECT id FROM profiles WHERE role = 'passenger'
    LOOP
        INSERT INTO public.notifications (user_id, title, message, type, metadata)
        VALUES (
            passenger_row.id,
            'Nouveau trajet disponible ! 🚀',
            'Un nouveau départ de ' || COALESCE(city_departure, 'votre ville') ||
            ' vers ' || COALESCE(city_arrival, 'votre destination') ||
            ' vient d''être publié.',
            'new_trip',
            jsonb_build_object('trip_id', NEW.id, 'route_id', NEW.route_id)
        )
        ON CONFLICT ON CONSTRAINT unique_notification_spam DO NOTHING;
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ── 2. Correction de notify_passengers_on_new_trip ───────────────────────────
-- (Second trigger qui peut aussi être présent dans certaines versions du schéma)
-- Suppression de la colonne 'body' qui n'existe pas + COALESCE sur le name

CREATE OR REPLACE FUNCTION public.notify_passengers_on_new_trip()
RETURNS TRIGGER AS $$
DECLARE
    route_name TEXT;
BEGIN
    -- Récupérer le nom de la route (nullable !)
    SELECT COALESCE(r.name,
        dc.name || ' → ' || ac.name,
        'votre itinéraire')
    INTO route_name
    FROM routes r
    JOIN cities dc ON r.departure_city_id = dc.id
    JOIN cities ac ON r.arrival_city_id = ac.id
    WHERE r.id = NEW.route_id;

    INSERT INTO public.notifications (user_id, title, message, type, metadata)
    SELECT
        id,
        'Nouveau trajet disponible ! 🚀',
        'Un chauffeur vient de publier un trajet sur l''itinéraire ' ||
            COALESCE(route_name, 'votre itinéraire') || '.',
        'new_trip',
        jsonb_build_object('trip_id', NEW.id)
    FROM public.profiles
    WHERE role = 'passenger'
    ON CONFLICT DO NOTHING;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ── 3. Correction de handle_new_booking_notifications ───────────────────────
-- (Notifie le chauffeur quand un passager réserve)

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
        ON CONFLICT DO NOTHING;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ── 4. Recréation propre des triggers ────────────────────────────────────────

-- Trigger trajet (seulement quand statut = 'scheduled')
DROP TRIGGER IF EXISTS trg_notify_on_new_trip ON public.trips;
CREATE TRIGGER trg_notify_on_new_trip
    AFTER INSERT OR UPDATE OF status ON public.trips
    FOR EACH ROW
    WHEN (NEW.status = 'scheduled')
    EXECUTE FUNCTION public.handle_new_trip_notifications();

-- Trigger réservation
DROP TRIGGER IF EXISTS trg_notify_on_new_booking ON public.bookings;
CREATE TRIGGER trg_notify_on_new_booking
    AFTER INSERT ON public.bookings
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_booking_notifications();

-- ============================================================================
-- ✅ FIN — Résumé des corrections :
-- 1. COALESCE sur city_departure / city_arrival → plus jamais de message NULL
-- 2. Suppression de la colonne 'body' inexistante dans notify_passengers_on_new_trip
-- 3. Trigger écoute INSERT OR UPDATE OF status (fonctionne même sans deux étapes)
-- ============================================================================
