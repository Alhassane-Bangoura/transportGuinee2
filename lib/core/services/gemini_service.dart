import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  late GenerativeModel _model;
  bool _initialized = false;

  void init() {
    if (_initialized) return;
    
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('[GeminiService] CRITICAL: GEMINI_API_KEY is missing in .env');
      return;
    }

    try {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );
      _initialized = true;
      debugPrint('[GeminiService] Initialized successfully');
    } catch (e) {
      debugPrint('[GeminiService] Initialization error: $e');
    }
  }

  Future<String> getResponse(String prompt, {String? context, List<Content>? history}) async {
    if (!_initialized) init();

    if (!_initialized) {
      return "L'assistant n'est pas initialisé car la clé API GEMINI_API_KEY est manquante dans le fichier .env.";
    }

    try {
      if (prompt.isEmpty) return "Le message est vide.";
      
      final fullPrompt = context != null ? "CONTEXTE : $context\n\nMESSAGE : $prompt" : prompt;
      
      debugPrint('[GeminiService] Calling API with prompt length: ${fullPrompt.length}');
      
      final chat = _model.startChat(history: history ?? []);
      final response = await chat.sendMessage(Content.text(fullPrompt));
      
      if (response.text == null) {
        debugPrint('[GeminiService] API returned null text');
        return "Désolé, je n'ai pas pu générer de réponse.";
      }
      
      return response.text!;
    } catch (e, stack) {
      debugPrint('[GeminiService] EXCEPTION: $e');
      debugPrint('[GeminiService] STACKTRACE: $stack');
      return "Une erreur est survenue lors de la communication avec l'assistant. Erreur: $e";
    }
  }
}
