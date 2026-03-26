-- ============================================================================
-- GUINÉE TRANSPORT — Schéma Supabase complet
-- ============================================================================
-- Ce fichier est prêt à être copié-collé dans l'éditeur SQL de Supabase.
-- Il crée toutes les tables, contraintes, index, fonctions, triggers,
-- politiques RLS et données de seed nécessaires pour le projet.
--
-- ⚠️  Exécuter ce script sur une base VIERGE (ou supprimer les objets existants).
-- ============================================================================


-- ────────────────────────────────────────────────────────────────────────────
-- 0. EXTENSIONS
-- ────────────────────────────────────────────────────────────────────────────

CREATE EXTENSION IF NOT EXISTS "pgcrypto";   -- Pour gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "moddatetime"; -- Pour updated_at automatique


-- ────────────────────────────────────────────────────────────────────────────
-- 1. TYPES ÉNUMÉRÉS (ENUM)
-- ────────────────────────────────────────────────────────────────────────────

-- Rôles utilisateur
DO $$ BEGIN
  CREATE TYPE user_role AS ENUM ('passenger', 'driver', 'syndicate', 'station_admin');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Statuts de trajet
DO $$ BEGIN
  CREATE TYPE trip_status AS ENUM ('scheduled', 'boarding', 'in_transit', 'completed', 'cancelled');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Statuts de réservation
DO $$ BEGIN
  CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'completed', 'cancelled');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Statuts de billet
DO $$ BEGIN
  CREATE TYPE ticket_status AS ENUM ('valid', 'used', 'cancelled');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Méthodes de paiement
DO $$ BEGIN
  CREATE TYPE payment_method AS ENUM ('orange_money', 'mtn_momo', 'cash');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Statuts de paiement
DO $$ BEGIN
  CREATE TYPE payment_status AS ENUM ('pending', 'completed', 'failed');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Types de véhicule
DO $$ BEGIN
  CREATE TYPE vehicle_type AS ENUM ('Bus', 'Taxi-Brousse', 'Express', 'Minibus');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;


-- ────────────────────────────────────────────────────────────────────────────
-- 2. TABLES
-- ────────────────────────────────────────────────────────────────────────────

-- ═══════════════════════════════════════════════
-- 2.1 PROFILES (lié à auth.users)
-- ═══════════════════════════════════════════════
-- Table miroir de auth.users pour stocker les données publiques.
-- Le profil est créé automatiquement via un trigger à l'inscription.

CREATE TABLE IF NOT EXISTS profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name   TEXT NOT NULL DEFAULT '',
  email       TEXT,
  phone       TEXT,
  avatar_url  TEXT,
  role        user_role NOT NULL DEFAULT 'passenger',
  metadata    JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE profiles IS 'Profils publics des utilisateurs, miroir de auth.users.';


-- ═══════════════════════════════════════════════
-- 2.2 CITIES (Villes)
-- ═══════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS cities (
  id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name    TEXT NOT NULL UNIQUE,
  region  TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE cities IS 'Villes de Guinée desservies par le réseau de transport.';


-- ═══════════════════════════════════════════════
-- 2.3 STATIONS (Gares routières)
-- ═══════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS stations (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name      TEXT NOT NULL,
  city_id   UUID NOT NULL REFERENCES cities(id) ON DELETE CASCADE,
  address   TEXT NOT NULL DEFAULT '',
  latitude  DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE(name, city_id)  -- Pas deux gares du même nom dans la même ville
);

COMMENT ON TABLE stations IS 'Gares routières rattachées à une ville.';


-- ═══════════════════════════════════════════════
-- 2.4 ROUTES (Itinéraires)
-- ═══════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS routes (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  departure_city_id     UUID NOT NULL REFERENCES cities(id) ON DELETE RESTRICT,
  arrival_city_id       UUID NOT NULL REFERENCES cities(id) ON DELETE RESTRICT,
  departure_station_id  UUID NOT NULL REFERENCES stations(id) ON DELETE RESTRICT,
  arrival_station_id    UUID NOT NULL REFERENCES stations(id) ON DELETE RESTRICT,
  syndicate_id          UUID REFERENCES profiles(id) ON DELETE SET NULL,
  base_price            NUMERIC(10, 2) NOT NULL CHECK (base_price >= 0),
  distance              DOUBLE PRECISION,         -- en kilomètres
  estimated_duration    INTEGER,                   -- en minutes
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- Une même route ne peut pas exister en doublon
  UNIQUE(departure_station_id, arrival_station_id),
  -- On ne peut pas partir et arriver dans la même ville
  CHECK (departure_city_id <> arrival_city_id)
);

COMMENT ON TABLE routes IS 'Itinéraires entre deux gares (et donc deux villes).';


-- ═══════════════════════════════════════════════
-- 2.5 VEHICLES (Véhicules)
-- ═══════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS vehicles (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type                TEXT NOT NULL DEFAULT 'Bus',
  total_seats         INTEGER NOT NULL CHECK (total_seats > 0),
  amenities           JSONB NOT NULL DEFAULT '[]'::jsonb,
  license_plate       TEXT NOT NULL UNIQUE,
  seat_configuration  JSONB,   -- Disposition des sièges (rows, columns, etc.)
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE vehicles IS 'Véhicules du parc de transport.';


-- ═══════════════════════════════════════════════
-- 2.6 TRIPS (Trajets / Voyages)
-- ═══════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS trips (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  route_id        UUID NOT NULL REFERENCES routes(id) ON DELETE RESTRICT,
  vehicle_id      UUID REFERENCES vehicles(id) ON DELETE SET NULL,
  driver_id       UUID REFERENCES profiles(id) ON DELETE SET NULL,
  departure_time  TIMESTAMPTZ NOT NULL,
  available_seats INTEGER NOT NULL CHECK (available_seats >= 0),
  price           NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
  status          TEXT NOT NULL DEFAULT 'scheduled',
  occupied_seats  JSONB DEFAULT '[]'::jsonb,  -- Liste des sièges occupés [1,3,5,...]
  quay_number     TEXT,                       -- Quai de départ (ex: "Quai 1")
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE trips IS 'Trajets planifiés avec horaire, véhicule et prix.';


-- ═══════════════════════════════════════════════
-- 2.7 BOOKINGS (Réservations)
-- ═══════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS bookings (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id         UUID NOT NULL REFERENCES trips(id) ON DELETE RESTRICT,
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  seats           INTEGER NOT NULL CHECK (seats > 0),
  selected_seats  JSONB,                     -- [1, 5, 12] — numéros des sièges choisis
  total_price     NUMERIC(10, 2),
  status          TEXT NOT NULL DEFAULT 'pending',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE bookings IS 'Réservations des passagers sur un trajet.';


-- ═══════════════════════════════════════════════
-- 2.8 TICKETS (Billets)
-- ═══════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS tickets (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id  UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  qr_code     TEXT NOT NULL UNIQUE,
  status      TEXT NOT NULL DEFAULT 'valid',
  issued_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE tickets IS 'Billets générés après paiement, avec QR code unique.';


-- ═══════════════════════════════════════════════
-- 2.9 PAYMENTS (Paiements)
-- ═══════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS payments (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id      UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  amount          NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
  method          TEXT NOT NULL DEFAULT 'cash',
  status          TEXT NOT NULL DEFAULT 'pending',
  transaction_id  TEXT,
  phone_number    TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE payments IS 'Paiements (Orange Money, MTN MoMo, Espèces).';


-- ────────────────────────────────────────────────────────────────────────────
-- 3. INDEX DE PERFORMANCE
-- ────────────────────────────────────────────────────────────────────────────

-- Cities
CREATE INDEX IF NOT EXISTS idx_cities_name ON cities(name);

-- Stations
CREATE INDEX IF NOT EXISTS idx_stations_city_id ON stations(city_id);

-- Routes
CREATE INDEX IF NOT EXISTS idx_routes_departure_city ON routes(departure_city_id);
CREATE INDEX IF NOT EXISTS idx_routes_arrival_city ON routes(arrival_city_id);
CREATE INDEX IF NOT EXISTS idx_routes_departure_station ON routes(departure_station_id);
CREATE INDEX IF NOT EXISTS idx_routes_arrival_station ON routes(arrival_station_id);

-- Trips
CREATE INDEX IF NOT EXISTS idx_trips_route_id ON trips(route_id);
CREATE INDEX IF NOT EXISTS idx_trips_vehicle_id ON trips(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_trips_driver_id ON trips(driver_id);
CREATE INDEX IF NOT EXISTS idx_trips_departure_time ON trips(departure_time);
CREATE INDEX IF NOT EXISTS idx_trips_status ON trips(status);
CREATE INDEX IF NOT EXISTS idx_trips_available_seats ON trips(available_seats);

-- Bookings
CREATE INDEX IF NOT EXISTS idx_bookings_trip_id ON bookings(trip_id);
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_created_at ON bookings(created_at DESC);

-- Tickets
CREATE INDEX IF NOT EXISTS idx_tickets_booking_id ON tickets(booking_id);
CREATE INDEX IF NOT EXISTS idx_tickets_qr_code ON tickets(qr_code);
CREATE INDEX IF NOT EXISTS idx_tickets_status ON tickets(status);

-- Payments
CREATE INDEX IF NOT EXISTS idx_payments_booking_id ON payments(booking_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);


-- ────────────────────────────────────────────────────────────────────────────
-- 4. FONCTIONS & TRIGGERS
-- ────────────────────────────────────────────────────────────────────────────

-- ═══════════════════════════════════════════════
-- 4.1 Mise à jour automatique de updated_at
-- ═══════════════════════════════════════════════

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Appliquer le trigger sur les tables avec updated_at
CREATE OR REPLACE TRIGGER set_updated_at_profiles
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE OR REPLACE TRIGGER set_updated_at_vehicles
  BEFORE UPDATE ON vehicles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE OR REPLACE TRIGGER set_updated_at_trips
  BEFORE UPDATE ON trips
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE OR REPLACE TRIGGER set_updated_at_bookings
  BEFORE UPDATE ON bookings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ═══════════════════════════════════════════════
-- 4.2 Création automatique du profil à l'inscription
-- ═══════════════════════════════════════════════

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  _role_text TEXT;
  _role user_role;
BEGIN
  -- 1. Récupérer le texte du rôle
  _role_text := NEW.raw_user_meta_data ->> 'role_key';
  
  -- 2. Tenter la conversion avec sécurité (fallback sur passenger en cas d'erreur)
  BEGIN
    IF _role_text IS NOT NULL THEN
      _role := _role_text::user_role;
    ELSE
      _role := 'passenger'::user_role;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    _role := 'passenger'::user_role;
  END;

  -- 3. Insertion dans profiles avec gestion de conflit (UPSERT)
  INSERT INTO public.profiles (id, full_name, email, phone, role, metadata)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data ->> 'full_name', ''),
    NEW.email,
    COALESCE(NEW.raw_user_meta_data ->> 'phone', NEW.phone, ''),
    _role,
    COALESCE(NEW.raw_user_meta_data, '{}'::jsonb)
  )
  ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    email = EXCLUDED.email,
    phone = EXCLUDED.phone,
    role = EXCLUDED.role,
    metadata = EXCLUDED.metadata;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger après création d'un user dans auth.users
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();


-- ═══════════════════════════════════════════════
-- 4.3 Mise à jour des sièges disponibles après réservation
-- ═══════════════════════════════════════════════

CREATE OR REPLACE FUNCTION update_trip_seats_on_booking()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.status IN ('pending', 'confirmed') THEN
    -- Décrémenter les sièges disponibles
    UPDATE trips
    SET available_seats = available_seats - NEW.seats
    WHERE id = NEW.trip_id AND available_seats >= NEW.seats;

    -- Vérifier si la mise à jour a eu lieu
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Pas assez de sièges disponibles pour ce trajet.';
    END IF;

  ELSIF TG_OP = 'UPDATE' AND OLD.status IN ('pending', 'confirmed')
        AND NEW.status = 'cancelled' THEN
    -- Restaurer les sièges si annulation
    UPDATE trips
    SET available_seats = available_seats + OLD.seats
    WHERE id = OLD.trip_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER trg_update_seats_on_booking
  AFTER INSERT OR UPDATE ON bookings
  FOR EACH ROW EXECUTE FUNCTION update_trip_seats_on_booking();


-- ═══════════════════════════════════════════════
-- 4.4 Mise à jour des sièges occupés dans trips
-- ═══════════════════════════════════════════════

CREATE OR REPLACE FUNCTION update_occupied_seats_on_booking()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.selected_seats IS NOT NULL
     AND NEW.status IN ('pending', 'confirmed') THEN
    -- Ajouter les sièges sélectionnés à la liste des sièges occupés
    UPDATE trips
    SET occupied_seats = (
      SELECT jsonb_agg(DISTINCT seat ORDER BY seat)
      FROM (
        SELECT jsonb_array_elements(COALESCE(occupied_seats, '[]'::jsonb)) AS seat
        UNION ALL
        SELECT jsonb_array_elements(NEW.selected_seats)
      ) sub
    )
    WHERE id = NEW.trip_id;

  ELSIF TG_OP = 'UPDATE' AND OLD.status IN ('pending', 'confirmed')
        AND NEW.status = 'cancelled' AND OLD.selected_seats IS NOT NULL THEN
    -- Retirer les sièges de la liste si annulation
    UPDATE trips
    SET occupied_seats = (
      SELECT COALESCE(jsonb_agg(seat ORDER BY seat), '[]'::jsonb)
      FROM jsonb_array_elements(COALESCE(occupied_seats, '[]'::jsonb)) AS seat
      WHERE seat NOT IN (
        SELECT jsonb_array_elements(OLD.selected_seats)
      )
    )
    WHERE id = OLD.trip_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER trg_update_occupied_seats
  AFTER INSERT OR UPDATE ON bookings
  FOR EACH ROW EXECUTE FUNCTION update_occupied_seats_on_booking();


-- ────────────────────────────────────────────────────────────────────────────
-- 5. ROW LEVEL SECURITY (RLS)
-- ────────────────────────────────────────────────────────────────────────────

-- Activer RLS sur toutes les tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE cities ENABLE ROW LEVEL SECURITY;
ALTER TABLE stations ENABLE ROW LEVEL SECURITY;
ALTER TABLE routes ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;


-- ═══════════════════════════════════════════════
-- 5.1 PROFILES
-- ═══════════════════════════════════════════════

-- Tout le monde peut voir les profils (pour afficher noms de chauffeurs, etc.)
CREATE POLICY "profiles_select_all"
  ON profiles FOR SELECT
  USING (true);

-- Un utilisateur ne peut modifier que SON profil
CREATE POLICY "profiles_update_own"
  ON profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- L'insertion est gérée par le trigger SECURITY DEFINER
CREATE POLICY "profiles_insert_via_trigger"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);


-- ═══════════════════════════════════════════════
-- 5.2 CITIES (lecture publique)
-- ═══════════════════════════════════════════════

CREATE POLICY "cities_select_all"
  ON cities FOR SELECT
  USING (true);

-- Seuls les admins (via Dashboard Supabase) créent/modifient les villes,
-- donc pas de politique INSERT/UPDATE/DELETE pour les utilisateurs normaux.


-- ═══════════════════════════════════════════════
-- 5.3 STATIONS (lecture publique)
-- ═══════════════════════════════════════════════

CREATE POLICY "stations_select_all"
  ON stations FOR SELECT
  USING (true);


-- ═══════════════════════════════════════════════
-- 5.4 ROUTES (lecture publique)
-- ═══════════════════════════════════════════════

CREATE POLICY "routes_select_all"
  ON routes FOR SELECT
  USING (true);


-- ═══════════════════════════════════════════════
-- 5.5 VEHICLES (lecture publique)
-- ═══════════════════════════════════════════════

CREATE POLICY "vehicles_select_all"
  ON vehicles FOR SELECT
  USING (true);

-- Les chauffeurs et syndicats peuvent mettre à jour les véhicules
CREATE POLICY "vehicles_update_authorized"
  ON vehicles FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role IN ('driver', 'syndicate', 'station_admin')
    )
  );


-- ═══════════════════════════════════════════════
-- 5.6 TRIPS
-- ═══════════════════════════════════════════════

-- Lecture publique (tous les utilisateurs voient les trajets)
CREATE POLICY "trips_select_all"
  ON trips FOR SELECT
  USING (true);

-- Seuls les chauffeurs, syndicats et admins de gare peuvent créer des trajets
CREATE POLICY "trips_insert_authorized"
  ON trips FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role IN ('driver', 'syndicate', 'station_admin')
    )
  );

-- Mise à jour par le chauffeur assigné, les syndicats ou les admins de gare
CREATE POLICY "trips_update_authorized"
  ON trips FOR UPDATE
  USING (
    driver_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role IN ('syndicate', 'station_admin')
    )
  );


-- ═══════════════════════════════════════════════
-- 5.7 BOOKINGS
-- ═══════════════════════════════════════════════

-- Un utilisateur ne voit que SES réservations
CREATE POLICY "bookings_select_own"
  ON bookings FOR SELECT
  USING (auth.uid() = user_id);

-- Les chauffeurs/syndicats/admins voient les réservations de leurs trajets
CREATE POLICY "bookings_select_staff"
  ON bookings FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM trips t
      JOIN profiles p ON p.id = auth.uid()
      WHERE t.id = bookings.trip_id
      AND (
        t.driver_id = auth.uid()
        OR p.role IN ('syndicate', 'station_admin')
      )
    )
  );

-- Un passager authentifié peut créer une réservation
CREATE POLICY "bookings_insert_authenticated"
  ON bookings FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Un passager peut modifier sa réservation (ex: annuler)
CREATE POLICY "bookings_update_own"
  ON bookings FOR UPDATE
  USING (auth.uid() = user_id);

-- Le staff peut aussi mettre à jour les réservations
CREATE POLICY "bookings_update_staff"
  ON bookings FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM trips t
      JOIN profiles p ON p.id = auth.uid()
      WHERE t.id = bookings.trip_id
      AND (
        t.driver_id = auth.uid()
        OR p.role IN ('syndicate', 'station_admin')
      )
    )
  );


-- ═══════════════════════════════════════════════
-- 5.8 TICKETS
-- ═══════════════════════════════════════════════

-- Un utilisateur ne voit que SES billets (via la relation booking)
CREATE POLICY "tickets_select_own"
  ON tickets FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM bookings b
      WHERE b.id = tickets.booking_id
      AND b.user_id = auth.uid()
    )
  );

-- Le staff peut voir les billets pour validation
CREATE POLICY "tickets_select_staff"
  ON tickets FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role IN ('driver', 'syndicate', 'station_admin')
    )
  );

-- Un passager peut créer un billet (après paiement)
CREATE POLICY "tickets_insert_authenticated"
  ON tickets FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM bookings b
      WHERE b.id = booking_id
      AND b.user_id = auth.uid()
    )
  );

-- Le staff peut mettre à jour les billets (valider, marquer comme utilisé)
CREATE POLICY "tickets_update_staff"
  ON tickets FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role IN ('driver', 'syndicate', 'station_admin')
    )
  );

-- Le propriétaire du billet peut aussi le mettre à jour (annuler)
CREATE POLICY "tickets_update_own"
  ON tickets FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM bookings b
      WHERE b.id = tickets.booking_id
      AND b.user_id = auth.uid()
    )
  );


-- ═══════════════════════════════════════════════
-- 5.9 PAYMENTS
-- ═══════════════════════════════════════════════

-- Un utilisateur ne voit que SES paiements (via la relation booking)
CREATE POLICY "payments_select_own"
  ON payments FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM bookings b
      WHERE b.id = payments.booking_id
      AND b.user_id = auth.uid()
    )
  );

-- Le staff peut voir tous les paiements
CREATE POLICY "payments_select_staff"
  ON payments FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role IN ('syndicate', 'station_admin')
    )
  );

-- Un passager peut créer un paiement pour sa réservation
CREATE POLICY "payments_insert_authenticated"
  ON payments FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM bookings b
      WHERE b.id = booking_id
      AND b.user_id = auth.uid()
    )
  );


-- ────────────────────────────────────────────────────────────────────────────
-- 6. VUES UTILITAIRES (optionnelles)
-- ────────────────────────────────────────────────────────────────────────────

-- Vue pour les recherches de trajets avec noms de villes et gares
CREATE OR REPLACE VIEW trips_with_details AS
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
FROM trips t
  JOIN routes r ON t.route_id = r.id
  JOIN cities dc ON r.departure_city_id = dc.id
  JOIN cities ac ON r.arrival_city_id = ac.id
  JOIN stations ds ON r.departure_station_id = ds.id
  JOIN stations asc2 ON r.arrival_station_id = asc2.id
  LEFT JOIN vehicles v ON t.vehicle_id = v.id;


-- ────────────────────────────────────────────────────────────────────────────
-- 7. DONNÉES DE SEED — Villes de Guinée
-- ────────────────────────────────────────────────────────────────────────────

INSERT INTO cities (name, region) VALUES
  ('Conakry',     'Conakry'),
  ('Kindia',      'Kindia'),
  ('Mamou',       'Mamou'),
  ('Dalaba',      'Mamou'),
  ('Pita',        'Mamou'),
  ('Labé',        'Labé'),
  ('Boké',        'Boké'),
  ('Kamsar',      'Boké'),
  ('Faranah',     'Faranah'),
  ('Kissidougou', 'Faranah'),
  ('Kankan',      'Kankan'),
  ('Siguiri',     'Kankan'),
  ('Kouroussa',   'Kankan'),
  ('Nzérékoré',   'Nzérékoré'),
  ('Guéckédou',   'Nzérékoré'),
  ('Macenta',     'Nzérékoré'),
  ('Fria',        'Boké'),
  ('Dubréka',     'Kindia'),
  ('Coyah',       'Kindia'),
  ('Télimélé',    'Kindia')
ON CONFLICT (name) DO NOTHING;


-- ────────────────────────────────────────────────────────────────────────────
-- 7.1 DONNÉES DE SEED — Gares routières
-- ────────────────────────────────────────────────────────────────────────────

INSERT INTO stations (name, city_id, address) VALUES
  -- Conakry
  ('Gare Routière de Madina',
    (SELECT id FROM cities WHERE name = 'Conakry'),
    'Madina, Commune de Matam, Conakry'),
  ('Gare Routière de Bambéto',
    (SELECT id FROM cities WHERE name = 'Conakry'),
    'Bambéto, Commune de Ratoma, Conakry'),
  ('Gare Routière du KM36',
    (SELECT id FROM cities WHERE name = 'Conakry'),
    'Km36, Coyah, Conakry'),

  -- Kindia
  ('Gare Routière de Kindia',
    (SELECT id FROM cities WHERE name = 'Kindia'),
    'Centre-ville, Kindia'),

  -- Mamou
  ('Gare Routière de Mamou',
    (SELECT id FROM cities WHERE name = 'Mamou'),
    'Centre-ville, Mamou'),

  -- Labé
  ('Gare Routière de Labé',
    (SELECT id FROM cities WHERE name = 'Labé'),
    'Centre-ville, Labé'),

  -- Kankan
  ('Gare Routière de Kankan',
    (SELECT id FROM cities WHERE name = 'Kankan'),
    'Centre-ville, Kankan'),

  -- Nzérékoré
  ('Gare Routière de Nzérékoré',
    (SELECT id FROM cities WHERE name = 'Nzérékoré'),
    'Centre-ville, Nzérékoré'),

  -- Boké
  ('Gare Routière de Boké',
    (SELECT id FROM cities WHERE name = 'Boké'),
    'Centre-ville, Boké'),

  -- Faranah
  ('Gare Routière de Faranah',
    (SELECT id FROM cities WHERE name = 'Faranah'),
    'Centre-ville, Faranah'),

  -- Siguiri
  ('Gare Routière de Siguiri',
    (SELECT id FROM cities WHERE name = 'Siguiri'),
    'Centre-ville, Siguiri')
ON CONFLICT (name, city_id) DO NOTHING;


-- ────────────────────────────────────────────────────────────────────────────
-- 7.2 DONNÉES DE SEED — Routes principales
-- ────────────────────────────────────────────────────────────────────────────

INSERT INTO routes (departure_city_id, arrival_city_id, departure_station_id, arrival_station_id, base_price, distance, estimated_duration) VALUES
  -- Conakry → Kindia
  (
    (SELECT id FROM cities WHERE name = 'Conakry'),
    (SELECT id FROM cities WHERE name = 'Kindia'),
    (SELECT id FROM stations WHERE name = 'Gare Routière de Madina'),
    (SELECT id FROM stations WHERE name = 'Gare Routière de Kindia'),
    50000, 135, 180
  ),
  -- Conakry → Mamou
  (
    (SELECT id FROM cities WHERE name = 'Conakry'),
    (SELECT id FROM cities WHERE name = 'Mamou'),
    (SELECT id FROM stations WHERE name = 'Gare Routière de Madina'),
    (SELECT id FROM stations WHERE name = 'Gare Routière de Mamou'),
    100000, 300, 360
  ),
  -- Conakry → Labé
  (
    (SELECT id FROM cities WHERE name = 'Conakry'),
    (SELECT id FROM cities WHERE name = 'Labé'),
    (SELECT id FROM stations WHERE name = 'Gare Routière de Madina'),
    (SELECT id FROM stations WHERE name = 'Gare Routière de Labé'),
    150000, 450, 540
  ),
  -- Conakry → Kankan
  (
    (SELECT id FROM cities WHERE name = 'Conakry'),
    (SELECT id FROM cities WHERE name = 'Kankan'),
    (SELECT id FROM stations WHERE name = 'Gare Routière de Madina'),
    (SELECT id FROM stations WHERE name = 'Gare Routière de Kankan'),
    200000, 660, 720
  ),
  -- Conakry → Nzérékoré
  (
    (SELECT id FROM cities WHERE name = 'Conakry'),
    (SELECT id FROM cities WHERE name = 'Nzérékoré'),
    (SELECT id FROM stations WHERE name = 'Gare Routière de Madina'),
    (SELECT id FROM stations WHERE name = 'Gare Routière de Nzérékoré'),
    250000, 940, 900
  ),
  -- Conakry → Boké
  (
    (SELECT id FROM cities WHERE name = 'Conakry'),
    (SELECT id FROM cities WHERE name = 'Boké'),
    (SELECT id FROM stations WHERE name = 'Gare Routière de Bambéto'),
    (SELECT id FROM stations WHERE name = 'Gare Routière de Boké'),
    120000, 300, 360
  ),
  -- Kindia → Mamou
  (
    (SELECT id FROM cities WHERE name = 'Kindia'),
    (SELECT id FROM cities WHERE name = 'Mamou'),
    (SELECT id FROM stations WHERE name = 'Gare Routière de Kindia'),
    (SELECT id FROM stations WHERE name = 'Gare Routière de Mamou'),
    60000, 165, 180
  ),
  -- Mamou → Labé
  (
    (SELECT id FROM cities WHERE name = 'Mamou'),
    (SELECT id FROM cities WHERE name = 'Labé'),
    (SELECT id FROM stations WHERE name = 'Gare Routière de Mamou'),
    (SELECT id FROM stations WHERE name = 'Gare Routière de Labé'),
    60000, 150, 180
  ),
  -- Kankan → Siguiri
  (
    (SELECT id FROM cities WHERE name = 'Kankan'),
    (SELECT id FROM cities WHERE name = 'Siguiri'),
    (SELECT id FROM stations WHERE name = 'Gare Routière de Kankan'),
    (SELECT id FROM stations WHERE name = 'Gare Routière de Siguiri'),
    80000, 180, 240
  ),
  -- Conakry → Faranah
  (
    (SELECT id FROM cities WHERE name = 'Conakry'),
    (SELECT id FROM cities WHERE name = 'Faranah'),
    (SELECT id FROM stations WHERE name = 'Gare Routière de Madina'),
    (SELECT id FROM stations WHERE name = 'Gare Routière de Faranah'),
    180000, 430, 540
  )
ON CONFLICT (departure_station_id, arrival_station_id) DO NOTHING;


-- ────────────────────────────────────────────────────────────────────────────
-- 7.3 DONNÉES DE SEED — Véhicules exemples
-- ────────────────────────────────────────────────────────────────────────────

INSERT INTO vehicles (type, total_seats, amenities, license_plate, seat_configuration) VALUES
  ('Bus',          50, '["Climatisation", "TV", "WiFi"]'::jsonb,
   'RC-1234-A', '{"rows": 13, "columns": 4, "layout": "2-2"}'::jsonb),

  ('Bus',          45, '["Climatisation", "TV"]'::jsonb,
   'RC-5678-B', '{"rows": 12, "columns": 4, "layout": "2-2"}'::jsonb),

  ('Express',      30, '["Climatisation", "WiFi", "USB", "Inclinaison"]'::jsonb,
   'RC-9012-C', '{"rows": 10, "columns": 3, "layout": "2-1"}'::jsonb),

  ('Taxi-Brousse', 9,  '["Ventilation"]'::jsonb,
   'RC-3456-D', '{"rows": 3, "columns": 3, "layout": "3-3"}'::jsonb),

  ('Minibus',      18, '["Climatisation"]'::jsonb,
   'RC-7890-E', '{"rows": 5, "columns": 4, "layout": "2-2"}'::jsonb)
ON CONFLICT (license_plate) DO NOTHING;


-- ────────────────────────────────────────────────────────────────────────────
-- 7.4 DONNÉES DE SEED — Trajets exemples
-- ────────────────────────────────────────────────────────────────────────────

-- Créer quelques trajets pour les prochains jours
INSERT INTO trips (route_id, vehicle_id, departure_time, available_seats, price, status) VALUES
  -- Conakry → Kindia (demain 7h)
  (
    (SELECT r.id FROM routes r
     JOIN cities dc ON r.departure_city_id = dc.id
     JOIN cities ac ON r.arrival_city_id = ac.id
     WHERE dc.name = 'Conakry' AND ac.name = 'Kindia'
     LIMIT 1),
    (SELECT id FROM vehicles WHERE license_plate = 'RC-1234-A'),
    (CURRENT_DATE + INTERVAL '1 day' + INTERVAL '7 hours'),
    50, 50000, 'scheduled'
  ),
  -- Conakry → Kindia (demain 14h)
  (
    (SELECT r.id FROM routes r
     JOIN cities dc ON r.departure_city_id = dc.id
     JOIN cities ac ON r.arrival_city_id = ac.id
     WHERE dc.name = 'Conakry' AND ac.name = 'Kindia'
     LIMIT 1),
    (SELECT id FROM vehicles WHERE license_plate = 'RC-5678-B'),
    (CURRENT_DATE + INTERVAL '1 day' + INTERVAL '14 hours'),
    45, 55000, 'scheduled'
  ),
  -- Conakry → Labé (demain 6h)
  (
    (SELECT r.id FROM routes r
     JOIN cities dc ON r.departure_city_id = dc.id
     JOIN cities ac ON r.arrival_city_id = ac.id
     WHERE dc.name = 'Conakry' AND ac.name = 'Labé'
     LIMIT 1),
    (SELECT id FROM vehicles WHERE license_plate = 'RC-9012-C'),
    (CURRENT_DATE + INTERVAL '1 day' + INTERVAL '6 hours'),
    30, 150000, 'scheduled'
  ),
  -- Conakry → Kankan (après-demain 5h)
  (
    (SELECT r.id FROM routes r
     JOIN cities dc ON r.departure_city_id = dc.id
     JOIN cities ac ON r.arrival_city_id = ac.id
     WHERE dc.name = 'Conakry' AND ac.name = 'Kankan'
     LIMIT 1),
    (SELECT id FROM vehicles WHERE license_plate = 'RC-1234-A'),
    (CURRENT_DATE + INTERVAL '2 days' + INTERVAL '5 hours'),
    50, 200000, 'scheduled'
  ),
  -- Conakry → Mamou (demain 8h)
  (
    (SELECT r.id FROM routes r
     JOIN cities dc ON r.departure_city_id = dc.id
     JOIN cities ac ON r.arrival_city_id = ac.id
     WHERE dc.name = 'Conakry' AND ac.name = 'Mamou'
     LIMIT 1),
    (SELECT id FROM vehicles WHERE license_plate = 'RC-3456-D'),
    (CURRENT_DATE + INTERVAL '1 day' + INTERVAL '8 hours'),
    9, 100000, 'scheduled'
  ),
  -- Conakry → Boké (demain 9h)
  (
    (SELECT r.id FROM routes r
     JOIN cities dc ON r.departure_city_id = dc.id
     JOIN cities ac ON r.arrival_city_id = ac.id
     WHERE dc.name = 'Conakry' AND ac.name = 'Boké'
     LIMIT 1),
    (SELECT id FROM vehicles WHERE license_plate = 'RC-7890-E'),
    (CURRENT_DATE + INTERVAL '1 day' + INTERVAL '9 hours'),
    18, 120000, 'scheduled'
  );


-- ────────────────────────────────────────────────────────────────────────────
-- 8. GRANTS (permissions pour le rôle anon et authenticated)
-- ────────────────────────────────────────────────────────────────────────────

-- Les politiques RLS contrôlent l'accès, mais il faut aussi les permissions SQL
GRANT USAGE ON SCHEMA public TO anon, authenticated;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT INSERT, UPDATE ON bookings TO authenticated;
GRANT INSERT ON payments TO authenticated;
GRANT INSERT, UPDATE ON tickets TO authenticated;
GRANT UPDATE ON profiles TO authenticated;
GRANT INSERT, UPDATE ON trips TO authenticated;
GRANT UPDATE ON vehicles TO authenticated;

-- Accès aux séquences (pour les inserts avec gen_random_uuid)
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;


-- ────────────────────────────────────────────────────────────────────────────
-- ✅ FIN DU SCRIPT
-- ────────────────────────────────────────────────────────────────────────────
-- Le schéma est maintenant prêt. Résumé :
--
--   📋 9 tables   : profiles, cities, stations, routes, vehicles, trips,
--                    bookings, tickets, payments
--   🔒 RLS        : activé sur TOUTES les tables avec politiques granulaires
--   ⚡ Index       : 20 index de performance
--   🔄 Triggers   : updated_at auto, profil auto à l'inscription,
--                    mise à jour des sièges à la réservation
--   🏙️  Seed       : 20 villes, 11 gares, 10 routes, 5 véhicules, 6 trajets
-- ────────────────────────────────────────────────────────────────────────────
