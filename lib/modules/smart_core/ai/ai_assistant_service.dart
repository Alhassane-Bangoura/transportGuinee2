import 'package:supabase_flutter/supabase_flutter.dart';

class AiAssistantService {
  final _supabase = Supabase.instance.client;
  final String role;

  AiAssistantService({required this.role});

  Future<String> sendMessage(String message, {List<Map<String, String>> history = const []}) async {
    try {
      final response = await _supabase.functions.invoke(
        'ai-assistant',
        body: {
          'query': message,
          'history': history,
        },
      );

      if (response.status != 200) {
        return "Désolé, je rencontre une difficulté technique (${response.status}).";
      }

      return response.data['text'] ?? "Désolé, je n'ai pas pu générer de réponse.";
    } catch (e) {
      return "Une erreur est survenue lors de la connexion à l'assistant. $e";
    }
  }

  Future<String> analyzeStationData({
    required int vehiclesInStation,
    required int departuresToday,
    required int readyVehicles,
    required String recentActivity,
  }) async {
    final prompt = """Analyse ces données de gare pour l'administrateur et fais un résumé court (2 phrases max) :
    - Véhicules en gare : $vehiclesInStation
    - Départs aujourd'hui : $departuresToday
    - Prêts à partir : $readyVehicles
    - Activité récente : $recentActivity""";
    
    return sendMessage(prompt);
  }
}
