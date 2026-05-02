-- ────────────────────────────────────────────────────────────────────────────
-- GUINÉE TRANSPORT — FIX ASSISTANT IA (CONVERSATIONS)
-- ────────────────────────────────────────────────────────────────────────────
-- Ce script crée la table des conversations et met à jour la table des messages.
-- ────────────────────────────────────────────────────────────────────────────

-- 1. Table des conversations
CREATE TABLE IF NOT EXISTS public.assistant_conversations (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title       TEXT NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Mise à jour de assistant_messages (si elle existe déjà)
DO $$ 
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'assistant_messages') THEN
    -- Ajouter conversation_id si manquant
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'assistant_messages' AND column_name = 'conversation_id') THEN
      ALTER TABLE public.assistant_messages ADD COLUMN conversation_id UUID REFERENCES public.assistant_conversations(id) ON DELETE CASCADE;
    END IF;
  ELSE
    -- Créer la table si elle n'existe pas du tout
    CREATE TABLE public.assistant_messages (
      id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      conversation_id UUID REFERENCES public.assistant_conversations(id) ON DELETE CASCADE,
      user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
      role            TEXT NOT NULL,
      content         TEXT NOT NULL,
      sender_type     TEXT NOT NULL DEFAULT 'user',
      created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
    );
  END IF;
END $$;

-- 3. Sécurité (RLS)
ALTER TABLE public.assistant_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assistant_messages ENABLE ROW LEVEL SECURITY;

-- Politiques pour Conversations
DROP POLICY IF EXISTS "Users can only see their own assistant conversations" ON public.assistant_conversations;
CREATE POLICY "Users can only see their own assistant conversations"
  ON public.assistant_conversations FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own assistant conversations" ON public.assistant_conversations;
CREATE POLICY "Users can insert their own assistant conversations"
  ON public.assistant_conversations FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Politiques pour Messages (mise à jour)
DROP POLICY IF EXISTS "Users can only see their own assistant messages" ON public.assistant_messages;
CREATE POLICY "Users can only see their own assistant messages"
  ON public.assistant_messages FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own assistant messages" ON public.assistant_messages;
CREATE POLICY "Users can insert their own assistant messages"
  ON public.assistant_messages FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 4. Index pour la performance
CREATE INDEX IF NOT EXISTS idx_assistant_conv_user ON assistant_conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_assistant_msg_conv ON assistant_messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_assistant_msg_user ON assistant_messages(user_id);
