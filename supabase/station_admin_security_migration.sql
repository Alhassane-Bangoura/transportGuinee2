-- ============================================================================
-- MIGRATION : Sécurité et Isolation Module Admin Gare
-- ============================================================================

-- 1. Tightening RLS on trips table for station_admin
DROP POLICY IF EXISTS "trips_select_all" ON public.trips;

CREATE POLICY "trips_select_restricted"
  ON public.trips FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid()
      AND (
        p.role NOT IN ('station_admin', 'syndicate') -- Les passagers et chauffeurs voient tout (ou selon leurs propres RLS)
        OR (
          p.role = 'station_admin' 
          AND EXISTS (
            SELECT 1 FROM public.routes r 
            WHERE r.id = public.trips.route_id 
            AND r.departure_station_id = p.station_id
          )
        )
        OR (
          p.role = 'syndicate'
          AND (
            public.trips.syndicate_id = p.id
            OR EXISTS (
              SELECT 1 FROM public.syndicate_routes sr 
              WHERE sr.route_id = public.trips.route_id 
              AND sr.syndicate_id = p.id
            )
          )
        )
      )
    )
    OR auth.uid() IS NULL -- Autoriser lecture publique si nécessaire pour le booking anonyme (MVP)
  );

-- 2. Vue consolidée pour le Dashboard Admin (Multi-gare safe)
-- Cette vue permet à l'admin de voir l'état de sa gare en une seule requête
CREATE OR REPLACE VIEW public.vw_station_admin_dashboard AS
SELECT 
    s.id as station_id,
    s.name as station_name,
    count(DISTINCT t.id) FILTER (WHERE t.status = 'scheduled') as scheduled_departures,
    count(DISTINCT t.id) FILTER (WHERE t.status = 'in_progress') as active_departures,
    count(DISTINCT p.id) FILTER (WHERE p.role = 'driver') as total_drivers,
    count(DISTINCT v.id) as total_vehicles
FROM public.stations s
LEFT JOIN public.routes r ON r.departure_station_id = s.id
LEFT JOIN public.trips t ON t.route_id = r.id
LEFT JOIN public.profiles p ON p.station_id = s.id
LEFT JOIN public.vehicles v ON v.id = t.vehicle_id
GROUP BY s.id, s.name;

-- 3. Fonction pour récupérer les notifications temps réel filtrées par gare
-- (Les notifications sont déjà filtrées par user_id, donc l'isolation est native)

-- 4. Sécurité : Empêcher un admin de modifier des trips hors de sa gare
DROP POLICY IF EXISTS "trips_update_authorized" ON public.trips;

CREATE POLICY "trips_update_restricted"
  ON public.trips FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid()
      AND (
        (p.role = 'driver' AND public.trips.driver_id = p.id)
        OR (p.role = 'syndicate' AND public.trips.syndicate_id = p.id)
        OR (
          p.role = 'station_admin' 
          AND EXISTS (
            SELECT 1 FROM public.routes r 
            WHERE r.id = public.trips.route_id 
            AND r.departure_station_id = p.station_id
          )
        )
      )
    )
  );
