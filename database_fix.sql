-- ────────────────────────────────────────────────────────────────────────────
-- GUINÉE TRANSPORT — SCRIPT DE RÉPARATION BASE DE DONNÉES
-- ────────────────────────────────────────────────────────────────────────────
-- Instructions: Copiez ce script dans l'éditeur SQL de Supabase et exécutez-le.
-- ────────────────────────────────────────────────────────────────────────────

-- 1. Table pour l'historique de l'Assistant IA
CREATE TABLE IF NOT EXISTS public.assistant_messages (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role        TEXT NOT NULL, -- Rôle de l'utilisateur (passenger, driver, etc.)
  content     TEXT NOT NULL,
  sender_type TEXT NOT NULL DEFAULT 'user', -- 'user' ou 'ai'
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Table pour les Notifications en temps réel
CREATE TABLE IF NOT EXISTS public.notifications (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title       TEXT NOT NULL,
  message     TEXT NOT NULL,
  body        TEXT, -- Support de la colonne 'body' pour compatibilité
  type        TEXT NOT NULL DEFAULT 'info',
  is_read     BOOLEAN NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
 );

-- 3. Sécurité (RLS)
ALTER TABLE public.assistant_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Politiques pour Assistant Messages
DROP POLICY IF EXISTS "Users can only see their own assistant messages" ON assistant_messages;
CREATE POLICY "Users can only see their own assistant messages"
  ON assistant_messages FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own assistant messages" ON assistant_messages;
CREATE POLICY "Users can insert their own assistant messages"
  ON assistant_messages FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Politiques pour Notifications
DROP POLICY IF EXISTS "Users can only see their own notifications" ON notifications;
CREATE POLICY "Users can only see their own notifications"
  ON notifications FOR SELECT
  USING (auth.uid() = user_id);

-- 4. FIX URGENT : Assignation d'un itinéraire valide au profil chauffeur de test
-- On cherche l'ID de la route "Conakry -> Boké" et on l'assigne à l'utilisateur actuel
UPDATE public.profiles
SET route_id = (
  SELECT id FROM routes 
  WHERE name = 'Conakry → Boké' 
  LIMIT 1
)
WHERE id = auth.uid() 
AND role = 'driver'
AND (route_id IS NULL OR NOT EXISTS (SELECT 1 FROM routes WHERE id = profiles.route_id));

-- 5. TRIGGER : Notification automatique des passagers lors d'un nouveau trajet
CREATE OR REPLACE FUNCTION public.notify_passengers_on_new_trip()
RETURNS TRIGGER AS $$
BEGIN
  -- On insère une notification pour TOUS les profils ayant le rôle 'passenger'
  INSERT INTO public.notifications (user_id, title, message, body, type)
  SELECT 
    id, 
    'Nouveau trajet disponible !',
    'Un chauffeur vient de publier un trajet sur l''itinéraire ' || (SELECT name FROM routes WHERE id = NEW.route_id),
    'Un chauffeur vient de publier un trajet sur l''itinéraire ' || (SELECT name FROM routes WHERE id = NEW.route_id),
    'trip_published'
  FROM public.profiles
  WHERE role = 'passenger';
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER trg_notify_passengers_on_trip
  AFTER INSERT ON public.trips
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_passengers_on_new_trip();

-- Note: Ce fix permet au chauffeur de publier son trajet instantanément et de notifier les passagers.
