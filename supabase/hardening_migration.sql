-- [ignoring loop detection]
-- AUDIT DE DURCISSEMENT (HARDENING) PRODUCTION - GUINEETRANSPORT
BEGIN;

-- ==========================================
-- 1. RLS COMPLET (SÉCURITÉ STRICTE)
-- ==========================================

-- Table: profiles (Seul l'utilisateur peut modifier son propre profil)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view their own profile" ON public.profiles;
CREATE POLICY "Users can view their own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
CREATE POLICY "Users can update their own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Table: notifications (Isolation totale par utilisateur)
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view their own notifications" ON public.notifications;
CREATE POLICY "Users can view their own notifications" ON public.notifications FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can update their own notification status" ON public.notifications;
CREATE POLICY "Users can update their own notification status" ON public.notifications FOR UPDATE USING (auth.uid() = user_id);

-- Table: routes (Lecture publique, Modification ADMIN uniquement)
ALTER TABLE public.routes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Routes are viewable by everyone" ON public.routes;
CREATE POLICY "Routes are viewable by everyone" ON public.routes FOR SELECT USING (true);

-- ==========================================
-- 2. SOFT DELETE (INTÉGRITÉ HISTORIQUE)
-- ==========================================
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

-- ==========================================
-- 3. NOTIFICATIONS ROBUSTES (DELIVERY TRACKING)
-- ==========================================
ALTER TABLE public.notifications 
ADD COLUMN IF NOT EXISTS delivery_status TEXT DEFAULT 'pending' CHECK (delivery_status IN ('pending', 'sent', 'failed')),
ADD COLUMN IF NOT EXISTS retry_count INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_error TEXT;

-- ==========================================
-- 4. LIMITES MÉTIER (ANTI-ABUS)
-- ==========================================
-- Empêcher un chauffeur de créer plus de 5 trajets actifs par jour
CREATE OR REPLACE FUNCTION public.check_trip_limit()
RETURNS TRIGGER AS $$
BEGIN
  IF (SELECT count(*) FROM public.trips WHERE driver_id = NEW.driver_id AND created_at > now() - interval '24 hours') >= 5 THEN
    RAISE EXCEPTION 'Limite de création de trajets atteinte (5 par 24h)';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_limit_trips ON public.trips;
CREATE TRIGGER trg_limit_trips
BEFORE INSERT ON public.trips
FOR EACH ROW EXECUTE FUNCTION public.check_trip_limit();

-- ==========================================
-- 5. LOGGING SYSTÈME (AUDIT TRAIL)
-- ==========================================
CREATE TABLE IF NOT EXISTS public.system_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    level TEXT NOT NULL, -- INFO, WARNING, ERROR
    source TEXT NOT NULL, -- 'auth', 'booking', 'payment'
    message TEXT NOT NULL,
    user_id UUID REFERENCES auth.users(id),
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- RLS sur logs (ADMIN uniquement)
ALTER TABLE public.system_logs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins can view logs" ON public.system_logs;
CREATE POLICY "Admins can view logs" ON public.system_logs FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);

COMMIT;
