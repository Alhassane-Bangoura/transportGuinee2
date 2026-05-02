-- ============================================================================
-- GUINÉE TRANSPORT — MISE À JOUR MVP (PHASE 1)
-- ============================================================================
-- Ce script ajoute de manière non-destructrice les éléments manquants pour le MVP :
-- 1. Notifications (Pour le temps réel)
-- 2. Wallets & Transactions (Pour supprimer le stockage local)
-- 3. Trip Status History (Historique)
-- 4. Multiplicateur de prix dynamique
--
-- 👉 À copier/coller et exécuter dans l'éditeur SQL de Supabase
-- ============================================================================

-- ────────────────────────────────────────────────────────────────────────────
-- 1. NOTIFICATIONS
-- ────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    metadata JSONB DEFAULT '{}'::jsonb,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Index pour récupérer rapidement les non-lues
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON notifications(user_id) WHERE is_read = false;

-- RLS Notifications
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own notifications" ON public.notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update their own notifications" ON public.notifications FOR UPDATE USING (auth.uid() = user_id);
-- Remarque : L'insertion se fait généralement côté Service Flutter (authentifié) ou via Triggers.
CREATE POLICY "Users can insert notifications" ON public.notifications FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);


-- ────────────────────────────────────────────────────────────────────────────
-- 2. WALLETS (Portefeuilles virtuels)
-- ────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    balance NUMERIC(10, 2) NOT NULL DEFAULT 0.0 CHECK (balance >= 0),
    currency TEXT NOT NULL DEFAULT 'GNF',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- RLS Wallets
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own wallet" ON public.wallets FOR SELECT USING (auth.uid() = user_id);
-- Pas de policy UPDATE utilisateur. Les montants doivent être modifiés via des fonctions sécurisées RPC.

-- Trigger pour initialiser le Wallet avec 50.000 GNF pour vos beta-testeurs !
CREATE OR REPLACE FUNCTION create_wallet_for_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.wallets (user_id, balance, currency)
  VALUES (NEW.id, 50000.00, 'GNF')
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- S'assurer que le trigger tourne à chaque inscription
DROP TRIGGER IF EXISTS on_user_created_wallet ON auth.users;
CREATE TRIGGER on_user_created_wallet
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION create_wallet_for_new_user();


-- Script rapide : Pour les testeurs actuels qui sont déjà inscrits, on leur crée un wallet
INSERT INTO public.wallets (user_id, balance, currency)
SELECT id, 50000.00, 'GNF' FROM auth.users
ON CONFLICT (user_id) DO NOTHING;


-- ────────────────────────────────────────────────────────────────────────────
-- 3. WALLET TRANSACTIONS
-- ────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id UUID NOT NULL REFERENCES public.wallets(id) ON DELETE CASCADE,
    amount NUMERIC(10, 2) NOT NULL, -- Positif ou négatif en UI, mais on garde la valeur d'impact pour le log
    type TEXT NOT NULL,             -- 'topup', 'payment'
    method TEXT,                    -- 'Orange Money', 'Paiement Trajet'
    description TEXT,
    from_city TEXT,
    to_city TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- RLS Wallet Transactions
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their wallet transactions" ON public.wallet_transactions FOR SELECT USING (
    wallet_id IN (SELECT id FROM public.wallets WHERE user_id = auth.uid())
);
CREATE POLICY "Users can insert transactions" ON public.wallet_transactions FOR INSERT WITH CHECK (
    wallet_id IN (SELECT id FROM public.wallets WHERE user_id = auth.uid())
);


-- ────────────────────────────────────────────────────────────────────────────
-- 4. HISTORIQUE DES TRAJETS
-- ────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.trip_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
    previous_status TEXT,
    new_status TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.trip_status_history ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public can view trip history" ON public.trip_status_history FOR SELECT USING (true);


-- ────────────────────────────────────────────────────────────────────────────
-- 5. MULTIPLICATEUR DE PRIX (ROUTES)
-- ────────────────────────────────────────────────────────────────────────────

-- Ajout du multiplier dynamique sans casser l'existant
ALTER TABLE public.routes ADD COLUMN IF NOT EXISTS pricing_multiplier NUMERIC(4,2) DEFAULT 1.0;


-- IMPORTANT: Pour que Flutter puisse écouter la table 'notifications',
-- vous DEVEZ aller dans votre Dashboard Supabase > Database > Replication > Source "supabase_realtime"
-- et cocher le bouton-poussoir ON pour la table "notifications" !
