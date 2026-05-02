-- FIX PROBLEM 1: Bookings RLS
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "bookings_insert_authenticated" ON public.bookings;
CREATE POLICY "bookings_insert_authenticated"
  ON public.bookings FOR INSERT
  WITH CHECK (auth.role() = 'authenticated' AND auth.uid() = user_id);

-- FIX PROBLEM 2: Escalade Role (Profiles RLS & Trigger)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- S'assurer que la politique d'update existe et est sécurisée (seul l'utilisateur peut modifier SON profil)
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
DROP POLICY IF EXISTS "profiles_update_authorized" ON public.profiles;

CREATE POLICY "profiles_update_authorized"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- Empêcher la modification de la colonne 'role' par l'utilisateur lui-même via un trigger
CREATE OR REPLACE FUNCTION public.prevent_role_escalation()
RETURNS TRIGGER AS $$
BEGIN
  -- Si la modification vient de l'utilisateur (via le SDK client), auth.uid() n'est pas nul
  -- Si le rôle a changé
  IF auth.uid() IS NOT NULL AND NEW.role IS DISTINCT FROM OLD.role THEN
    RAISE EXCEPTION 'Opération interdite : Escalade de privilège détectée. Vous ne pouvez pas modifier votre propre rôle.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_prevent_role_escalation ON public.profiles;
CREATE TRIGGER trg_prevent_role_escalation
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.prevent_role_escalation();

-- Optionnel: Empêcher également un chauffeur de modifier certains champs sensibles de la table 'trips'
CREATE OR REPLACE FUNCTION public.prevent_trip_falsification()
RETURNS TRIGGER AS $$
BEGIN
  IF auth.uid() = NEW.driver_id THEN
    -- Un chauffeur ne doit pas pouvoir changer le prix, la date de départ, ou l'itinéraire
    IF NEW.price IS DISTINCT FROM OLD.price OR
       NEW.route_id IS DISTINCT FROM OLD.route_id THEN
      RAISE EXCEPTION 'Opération interdite : Le chauffeur ne peut pas modifier le prix ou le trajet.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_prevent_trip_falsification ON public.trips;
CREATE TRIGGER trg_prevent_trip_falsification
  BEFORE UPDATE ON public.trips
  FOR EACH ROW EXECUTE FUNCTION public.prevent_trip_falsification();
