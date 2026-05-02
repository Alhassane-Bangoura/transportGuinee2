-- ============================================================================
-- MIGRATION : Sécurité et Traçabilité Module Syndicat
-- ============================================================================

-- 1. Ajout des champs de traçabilité sur la table trips
ALTER TABLE public.trips 
ADD COLUMN IF NOT EXISTS validated_by_syndicate_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS validated_at TIMESTAMPTZ;

-- 2. Fonction RPC sécurisée pour valider le départ
CREATE OR REPLACE FUNCTION public.validate_trip_departure(p_trip_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    v_syndicate_id UUID;
    v_route_id UUID;
    v_station_id UUID;
    v_admin_id UUID;
    v_is_authorized BOOLEAN;
BEGIN
    -- Récupérer l'ID de l'utilisateur connecté (le syndicat)
    v_syndicate_id := auth.uid();

    IF v_syndicate_id IS NULL THEN
        RAISE EXCEPTION 'Non authentifié';
    END IF;

    -- Récupérer les infos du trajet
    SELECT route_id INTO v_route_id
    FROM public.trips
    WHERE id = p_trip_id AND status != 'in_progress';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Trajet introuvable ou déjà validé';
    END IF;

    -- Vérifier l'autorisation : Le syndicat gère-t-il cette route ?
    SELECT EXISTS (
        SELECT 1 FROM public.syndicate_routes 
        WHERE syndicate_id = v_syndicate_id AND route_id = v_route_id
    ) INTO v_is_authorized;

    IF NOT v_is_authorized THEN
        RAISE EXCEPTION 'Accès refusé : Ce trajet n''appartient pas à votre syndicat';
    END IF;

    -- Mise à jour sécurisée avec traçabilité
    UPDATE public.trips
    SET status = 'in_progress',
        validated_by_syndicate_id = v_syndicate_id,
        validated_at = NOW()
    WHERE id = p_trip_id;

    -- Trouver la gare de départ pour notifier l'admin
    SELECT departure_station_id INTO v_station_id
    FROM public.routes
    WHERE id = v_route_id;

    -- Trouver l'admin de cette gare (celui qui a le rôle 'station_admin' et qui est assigné à cette station)
    -- Si vous avez plusieurs admins pour une gare, on prendra le premier ou on bouclera.
    -- Supposons qu'il y a un seul admin assigné dans `profiles.station_id` (si c'est ainsi que c'est modélisé)
    SELECT id INTO v_admin_id
    FROM public.profiles
    WHERE role = 'station_admin' AND station_id = v_station_id
    LIMIT 1;

    -- Insérer la notification (source unique, côté backend)
    IF v_admin_id IS NOT NULL THEN
        INSERT INTO public.notifications (user_id, title, message, type, metadata)
        VALUES (
            v_admin_id,
            'Départ Validé 🚌',
            'Le syndicat a validé le départ pour le trajet ' || p_trip_id || '.',
            'departure_validated',
            jsonb_build_object('trip_id', p_trip_id, 'syndicate_id', v_syndicate_id)
        );
    END IF;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
