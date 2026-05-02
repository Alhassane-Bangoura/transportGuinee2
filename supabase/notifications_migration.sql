-- ============================================================================
-- MIGRATION : Système de Notifications & Trigger Nouveau Trajet
-- ============================================================================

-- 1. Création de la table notifications si elle n'existe pas
CREATE TABLE IF NOT EXISTS public.notifications (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title       TEXT NOT NULL,
    message     TEXT NOT NULL,
    type        TEXT NOT NULL DEFAULT 'general',
    metadata    JSONB NOT NULL DEFAULT '{}'::jsonb,
    is_read     BOOLEAN NOT NULL DEFAULT false,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Index pour les performances
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(is_read);

-- Activer RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Politiques RLS
CREATE POLICY "Les utilisateurs voient leurs propres notifications"
    ON public.notifications FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Les utilisateurs peuvent marquer leurs notifications comme lues"
    ON public.notifications FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- 2. Fonction pour notifier les passagers d'un nouveau trajet
CREATE OR REPLACE FUNCTION public.handle_new_trip_notifications()
RETURNS TRIGGER AS $$
DECLARE
    city_departure TEXT;
    city_arrival TEXT;
    passenger_row RECORD;
BEGIN
    -- Récupérer les noms des villes pour le message
    SELECT dc.name, ac.name INTO city_departure, city_arrival
    FROM routes r
    JOIN cities dc ON r.departure_city_id = dc.id
    JOIN cities ac ON r.arrival_city_id = ac.id
    WHERE r.id = NEW.route_id;

    -- Notifier TOUS les passagers (pour cet exemple, on peut filtrer plus tard)
    -- Dans un cas réel, on filtrerait par ville de préférence ou historique
    FOR passenger_row IN 
        SELECT id FROM profiles WHERE role = 'passenger'
    LOOP
        INSERT INTO public.notifications (user_id, title, message, type, metadata)
        VALUES (
            passenger_row.id,
            'Nouveau trajet disponible ! 🚀',
            'Un nouveau départ de ' || city_departure || ' vers ' || city_arrival || ' vient d''être publié.',
            'new_trip',
            jsonb_build_object('trip_id', NEW.id, 'route_id', NEW.route_id)
        );
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Trigger sur la table trips
DROP TRIGGER IF EXISTS trg_notify_on_new_trip ON public.trips;
CREATE TRIGGER trg_notify_on_new_trip
    AFTER INSERT ON public.trips
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_trip_notifications();

-- 4. Fonction pour notifier le chauffeur d'une nouvelle réservation
CREATE OR REPLACE FUNCTION public.handle_new_booking_notifications()
RETURNS TRIGGER AS $$
DECLARE
    driver_uid UUID;
    passenger_name TEXT;
    city_departure TEXT;
    city_arrival TEXT;
BEGIN
    -- Récupérer le ID du chauffeur du trajet concerné
    SELECT driver_id, dc.name, ac.name INTO driver_uid, city_departure, city_arrival
    FROM trips t
    JOIN routes r ON t.route_id = r.id
    JOIN cities dc ON r.departure_city_id = dc.id
    JOIN cities ac ON r.arrival_city_id = ac.id
    WHERE t.id = NEW.trip_id;

    -- Récupérer le nom du passager
    SELECT full_name INTO passenger_name
    FROM profiles
    WHERE id = NEW.passenger_id;

    -- Notifier le chauffeur
    IF driver_uid IS NOT NULL THEN
        INSERT INTO public.notifications (user_id, title, message, type, metadata)
        VALUES (
            driver_uid,
            'Nouvelle réservation ! 🎟️',
            COALESCE(passenger_name, 'Un passager') || ' a réservé une place pour votre trajet ' || COALESCE(city_departure, '') || ' ➔ ' || COALESCE(city_arrival, '') || '.',
            'new_booking',
            jsonb_build_object('booking_id', NEW.id, 'trip_id', NEW.trip_id)
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger sur la table bookings
DROP TRIGGER IF EXISTS trg_notify_on_new_booking ON public.bookings;
CREATE TRIGGER trg_notify_on_new_booking
    AFTER INSERT ON public.bookings
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_booking_notifications();
