-- ============================================================================
-- FIX 1: VISIBILITÉ DES TRAJETS POUR LES CHAUFFEURS (LEFT JOIN + RLS)
-- ============================================================================
-- Cela corrige le bug où un trajet disparaît si l'itinéraire n'a pas 
-- de gare définie ou si le véhicule n'est pas rattaché.
-- On ajoute "WITH (security_invoker = true)" pour que les règles RLS de
-- Supabase s'appliquent correctement lors de la requête du chauffeur.

-- Suppression préalable de la vue pour éviter l'erreur de modification des colonnes (ERROR: 42P16)
DROP VIEW IF EXISTS public.trips_with_details;

CREATE OR REPLACE VIEW public.trips_with_details WITH (security_invoker = true) AS
SELECT
  t.*,
  r.departure_city_id,
  r.arrival_city_id,
  r.departure_station_id,
  r.arrival_station_id,
  r.base_price,
  r.distance,
  r.estimated_duration,
  dc.name AS departure_city_name,
  ac.name AS arrival_city_name,
  ds.name AS departure_station_name,
  asc2.name AS arrival_station_name,
  v.type AS vehicle_type,
  v.amenities,
  v.total_seats,
  v.license_plate
FROM public.trips t
  LEFT JOIN public.routes r ON t.route_id = r.id
  LEFT JOIN public.cities dc ON r.departure_city_id = dc.id
  LEFT JOIN public.cities ac ON r.arrival_city_id = ac.id
  LEFT JOIN public.stations ds ON r.departure_station_id = ds.id
  LEFT JOIN public.stations asc2 ON r.arrival_station_id = asc2.id
  LEFT JOIN public.vehicles v ON t.vehicle_id = v.id;

-- ============================================================================
-- FIX 2: NOTIFIER LES PASSAGERS À LA PUBLICATION D'UN TRAJET
-- ============================================================================
-- Ce trigger Postgres crée automatiquement une notification pour chaque passager
-- lorsqu'un trajet est inséré dans la base de données.

CREATE OR REPLACE FUNCTION public.handle_new_trip_notifications()
RETURNS TRIGGER AS $$
DECLARE
    city_departure TEXT;
    city_arrival TEXT;
    passenger_row RECORD;
BEGIN
    -- Récupérer les noms des villes pour la notification
    SELECT dc.name, ac.name INTO city_departure, city_arrival
    FROM routes r
    JOIN cities dc ON r.departure_city_id = dc.id
    JOIN cities ac ON r.arrival_city_id = ac.id
    WHERE r.id = NEW.route_id;

    -- Créer une notification pour chaque utilisateur avec le rôle 'passenger'
    FOR passenger_row IN 
        SELECT id FROM profiles WHERE role = 'passenger'
    LOOP
        INSERT INTO public.notifications (user_id, title, message, type, metadata)
        VALUES (
            passenger_row.id,
            'Nouveau trajet disponible ! 🚀',
            'Un nouveau départ de ' || COALESCE(city_departure, 'votre ville') || ' vers ' || COALESCE(city_arrival, 'votre destination') || ' vient d''être publié.',
            'new_trip',
            jsonb_build_object('trip_id', NEW.id, 'route_id', NEW.route_id)
        );
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Supprimer un éventuel ancien trigger pour éviter les doublons
DROP TRIGGER IF EXISTS trg_notify_on_new_trip ON public.trips;

-- Créer le trigger qui s'exécute après chaque nouveau trajet
CREATE TRIGGER trg_notify_on_new_trip
    AFTER INSERT ON public.trips
    FOR EACH ROW
    WHEN (NEW.status = 'scheduled')
    EXECUTE FUNCTION public.handle_new_trip_notifications();
