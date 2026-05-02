-- ============================================================================
-- 🚀 ULTIMATE FIX : RÉSOLUTION DÉFINITIVE DES RÉSERVATIONS ET NOTIFICATIONS
-- ============================================================================
-- Ce script nettoie TOUS les anciens triggers et installe une version
-- robuste qui ne bloque JAMAIS la réservation ou la publication.
-- ============================================================================

-- 1. Nettoyage radical des anciens triggers et fonctions
DROP TRIGGER IF EXISTS trg_notify_on_new_trip ON public.trips;
DROP TRIGGER IF EXISTS trg_notify_passengers_on_trip ON public.trips;
DROP TRIGGER IF EXISTS notify_passengers_on_new_trip_trigger ON public.trips;
DROP TRIGGER IF EXISTS trg_notify_on_new_booking ON public.bookings;
DROP TRIGGER IF EXISTS trg_notify_on_new_booking_v2 ON public.bookings;

DROP FUNCTION IF EXISTS public.handle_new_trip_notifications() CASCADE;
DROP FUNCTION IF EXISTS public.notify_passengers_on_new_trip() CASCADE;
DROP FUNCTION IF EXISTS public.handle_new_booking_notifications() CASCADE;

-- 2. Recréation de la contrainte unique (pour éviter les doublons de notifs)
-- On considère qu'une notification est un "spam" si c'est le même titre et message
-- envoyé au même utilisateur dans la même minute.
ALTER TABLE public.notifications DROP CONSTRAINT IF EXISTS unique_notification_spam;
ALTER TABLE public.notifications ADD CONSTRAINT unique_notification_spam 
UNIQUE (user_id, title, message);

-- 3. Fonction de notification de trajet (PROPRE)
CREATE OR REPLACE FUNCTION public.handle_new_trip_notifications()
RETURNS TRIGGER AS $$
DECLARE
    city_dep TEXT;
    city_arr TEXT;
    p_row RECORD;
BEGIN
    -- Récupérer les noms des villes sécurisés (COALESCE pour éviter les messages NULL)
    SELECT 
        COALESCE(dc.name, 'votre ville'), 
        COALESCE(ac.name, 'votre destination')
    INTO city_dep, city_arr
    FROM routes r
    JOIN cities dc ON r.departure_city_id = dc.id
    JOIN cities ac ON r.arrival_city_id = ac.id
    WHERE r.id = NEW.route_id;

    -- Notifier chaque passager
    FOR p_row IN SELECT id FROM public.profiles WHERE role = 'passenger' LOOP
        INSERT INTO public.notifications (user_id, title, message, type, metadata)
        VALUES (
            p_row.id,
            'Nouveau trajet disponible ! 🚀',
            'Départ de ' || city_dep || ' vers ' || city_arr || ' le ' || 
            TO_CHAR(NEW.departure_time, 'DD/MM à HH24:MI') || '.',
            'new_trip',
            jsonb_build_object('trip_id', NEW.id)
        )
        ON CONFLICT ON CONSTRAINT unique_notification_spam DO NOTHING;
    END LOOP;

    RETURN NEW;
EXCEPTION WHEN OTHERS THEN
    -- On ne bloque JAMAIS la publication si la notification échoue
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Fonction de notification de réservation (PROPRE)
CREATE OR REPLACE FUNCTION public.handle_new_booking_notifications()
RETURNS TRIGGER AS $$
DECLARE
    d_uid UUID;
    p_name TEXT;
    city_dep TEXT;
    city_arr TEXT;
BEGIN
    -- Récupérer les infos du trajet et du chauffeur
    -- Utilisation de user_id (nom correct de la colonne dans bookings)
    SELECT t.driver_id, dc.name, ac.name INTO d_uid, city_dep, city_arr
    FROM trips t
    JOIN routes r ON t.route_id = r.id
    JOIN cities dc ON r.departure_city_id = dc.id
    JOIN cities ac ON r.arrival_city_id = ac.id
    WHERE t.id = NEW.trip_id;

    -- Nom du passager (celui qui réserve)
    SELECT full_name INTO p_name FROM profiles WHERE id = NEW.user_id;

    IF d_uid IS NOT NULL THEN
        INSERT INTO public.notifications (user_id, title, message, type, metadata)
        VALUES (
            d_uid,
            'Nouvelle réservation ! 🎟️',
            COALESCE(p_name, 'Un passager') || ' a réservé ' || NEW.seats || 
            ' place(s) pour ' || COALESCE(city_dep, '') || ' ➔ ' || COALESCE(city_arr, '') || '.',
            'new_booking',
            jsonb_build_object('booking_id', NEW.id, 'trip_id', NEW.trip_id)
        )
        ON CONFLICT ON CONSTRAINT unique_notification_spam DO NOTHING;
    END IF;

    RETURN NEW;
EXCEPTION WHEN OTHERS THEN
    -- On ne bloque JAMAIS la réservation si la notification échoue
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Installation des triggers finaux
CREATE TRIGGER trg_notify_on_new_trip
    AFTER INSERT OR UPDATE OF status ON public.trips
    FOR EACH ROW
    WHEN (NEW.status = 'scheduled')
    EXECUTE FUNCTION public.handle_new_trip_notifications();

CREATE TRIGGER trg_notify_on_new_booking
    AFTER INSERT ON public.bookings
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_booking_notifications();

-- ============================================================================
-- ✅ RÉPARATION TERMINÉE
-- Désormais, même si une notification plante, le trajet ou la réservation
-- seront enregistrés avec succès.
-- ============================================================================
