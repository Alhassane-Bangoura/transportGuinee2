import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
    
    const supabaseClient = createClient(
      supabaseUrl,
      supabaseAnonKey,
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    const { data: { user }, error: userError } = await supabaseClient.auth.getUser()
    if (userError || !user) throw new Error('Unauthorized')

    // Role identification from user metadata
    const userRole = user.user_metadata?.role?.toUpperCase() || 'PASSAGER'
    const body = await req.json().catch(() => ({}));
    const query = body.query ?? '';
    const history = body.history ?? [];

    if (!query) {
      return new Response(JSON.stringify({ text: "Veuillez poser une question." }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      })
    }

    let context = ""

    // --- Role-Based Data Pre-filtering (The AI Intermediary Logic) ---
    
    if (userRole === 'PASSAGER' || userRole === 'PASSENGER') {
      const { data: trips } = await supabaseClient
        .from('trips')
        .select('*, routes(*, departure_city_id(name), arrival_city_id(name))')
        .eq('status', 'scheduled')
        .limit(5)
      
      const { data: bookings } = await supabaseClient
        .from('bookings')
        .select('*, trips(*, routes(*))')
        .eq('passenger_id', user.id)
        .limit(3)

      context = `[PASSAGER] Trajets disponibles: ${JSON.stringify(trips)}. Tes réservations récentes: ${JSON.stringify(bookings)}.`
    } 
    else if (userRole === 'CHAUFFEUR' || userRole === 'DRIVER') {
      const { data: vehicle } = await supabaseClient
        .from('vehicles')
        .select('id')
        .eq('driver_id', user.id)
        .single()
        
      if (vehicle) {
        const { data: myTrips } = await supabaseClient
          .from('trips')
          .select('*, routes(*)')
          .eq('vehicle_id', vehicle.id)
          .limit(5)
        context = `[CHAUFFEUR] Tes trajets assignés: ${JSON.stringify(myTrips)}.`
      } else {
        context = `[CHAUFFEUR] Aucun véhicule assigné.`
      }
    }
    else if (userRole === 'SYNDICAT' || userRole === 'SYNDICATE') {
      const { data: syndicateVehicles } = await supabaseClient
        .from('vehicles')
        .select('*, drivers:driver_id(full_name)')
        .eq('syndicate_id', user.id)
      
      context = `[SYNDICAT] Tes véhicules et chauffeurs: ${JSON.stringify(syndicateVehicles)}.`
    }
    else if (userRole === 'ADMIN_GARE' || userRole === 'STATION_ADMIN') {
      const stationId = user.user_metadata?.station_id
      if (stationId) {
        // Query trips starting from this station (mocked logic for station filter)
        const { data: stationTrips } = await supabaseClient
          .from('trips')
          .select('*, routes!inner(*)')
          .eq('status', 'scheduled')
          .limit(10)
        context = `[ADMIN_GARE] Données temps réel de ta gare: ${JSON.stringify(stationTrips)}.`
      } else {
        context = `[ADMIN_GARE] Station non identifiée.`
      }
    }

    // --- AI Orchestration ---

    const systemPrompt = `Tu es l'assistant intelligent de GuineeTransport pour le rôle ${userRole}. 
    CONTEXTE RÉEL (DONNÉES SÉCURISÉES): ${context}.
    INSTRUCTIONS:
    1. Utilise les données du contexte pour répondre de manière précise.
    2. Ne mentionne JAIMAS les IDs techniques (ex: UUID, ID numérique).
    3. Si l'utilisateur demande quelque chose hors de son contexte ou de son rôle, refuse poliment.
    4. Réponds en Français de manière chaleureuse et professionnelle.
    5. Pour les passagers, aide à la réservation. Pour les chauffeurs, aide au suivi des trajets. Pour les admins, analyse la performance.`

    const googleApiKey = Deno.env.get('GEMINI_API_KEY')
    const genAiResponse = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${googleApiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [
            { role: 'user', parts: [{ text: systemPrompt }] },
            ...history.map((h: any) => ({
              role: h.role === 'user' ? 'user' : 'model',
              parts: [{ text: h.content }]
            })),
            { role: 'user', parts: [{ text: query }] }
          ],
          generationConfig: {
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 1024,
          }
        })
      }
    )

    const genAiData = await genAiResponse.json()
    const aiText = genAiData.candidates?.[0]?.content?.parts?.[0]?.text || "Désolé, je rencontre une difficulté pour traiter votre demande."

    return new Response(JSON.stringify({ text: aiText }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : String(error);
    return new Response(JSON.stringify({ error: errorMessage }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
