// supabase/functions/ai-assistant/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  try {
    const { query, context } = await req.json()
    const apiKey = Deno.env.get("GEMINI_API_KEY") || "AIzaSyBTegL7xCLmp7XLB_nsCf-U5Jt58_CokM0";
    
    // Suite de modèles ultra-compatibles sur l'API v1 stable
    const models = ["gemini-1.5-flash", "gemini-pro", "gemini-1.0-pro"];
    let finalAiText = "";
    let lastError = "";

    for (const model of models) {
      try {
        // Forçage de la version v1 stable
        const url = `https://generativelanguage.googleapis.com/v1/models/${model}:generateContent?key=${apiKey}`;
        const systemInstruction = `Tu es l'IA GuineeTransport. Infos : ${context || "Aucune"}`;
        
        const response = await fetch(url, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            contents: [{ parts: [{ text: `${systemInstruction}\n\nQuestion: ${query}` }] }],
          })
        });

        const data = await response.json();
        
        if (data.error) {
           lastError = `${model}: ${data.error.message}`;
           continue; 
        }

        finalAiText = data.candidates?.[0]?.content?.parts?.[0]?.text;
        if (finalAiText) break; 
      } catch (e) {
        lastError = e.message;
      }
    }

    if (!finalAiText) throw new Error(lastError || "Modèle non trouvé sur votre compte Google AI.");

    return new Response(JSON.stringify({ text: finalAiText }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });

  } catch (error) {
    return new Response(JSON.stringify({ 
      text: `Désolé, problème technique (v1) : ${error.message}`,
    }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
