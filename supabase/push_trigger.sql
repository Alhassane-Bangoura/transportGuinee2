-- [ignoring loop detection]
-- DÉCLENCHEUR : Envoi de Push Notification via Edge Function
-- Ce trigger appelle la fonction Deno 'push-notifier' à chaque nouvelle notification.

-- 1. Extension http si pas activée
CREATE EXTENSION IF NOT EXISTS http WITH SCHEMA extensions;

-- 2. Fonction de rappel
CREATE OR REPLACE FUNCTION public.handle_new_notification_push()
RETURNS TRIGGER AS $$
BEGIN
  -- Appel asynchrone de l'Edge Function Supabase
  PERFORM
    net.http_post(
      url := 'https://' || current_setting('request.headers')::json->>'host' || '/functions/v1/push-notifier',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || current_setting('request.headers')::json->>'auth_token'
      ),
      body := jsonb_build_object('record', row_to_json(NEW))
    );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Trigger
DROP TRIGGER IF EXISTS trg_push_on_notification ON public.notifications;
CREATE TRIGGER trg_push_on_notification
AFTER INSERT ON public.notifications
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_notification_push();
