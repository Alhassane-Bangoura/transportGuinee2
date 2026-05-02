-- ============================================================================
-- AUTORISATION DE SUPPRESSION DES TRAJETS POUR LES CHAUFFEURS
-- ============================================================================
-- Ce script ajoute la politique RLS manquante permettant de supprimer un trajet.
-- La vérification pour empêcher la suppression si une réservation existe déjà 
-- est nativement gérée par la base de données (Foreign Key ON DELETE RESTRICT) 
-- et pré-vérifiée par l'application Flutter dans TripService.deleteTrip.

-- 1. On s'assure qu'aucune politique contradictoire n'existe déjà
DROP POLICY IF EXISTS "trips_delete_authorized" ON public.trips;

-- 2. Création de la politique autorisant le chauffeur (et les administrateurs) à supprimer
CREATE POLICY "trips_delete_authorized"
  ON public.trips FOR DELETE
  USING (
    -- Le chauffeur assigné au trajet
    driver_id = auth.uid()
    OR 
    -- OU les syndicats et admins de gare concernés
    EXISTS (
      SELECT 1 FROM profiles p
      JOIN routes r ON r.id = trips.route_id
      WHERE p.id = auth.uid()
      AND p.role IN ('syndicate', 'station_admin')
      AND (
        p.role != 'station_admin'
        OR r.departure_station_id = p.station_id
      )
    )
  );
