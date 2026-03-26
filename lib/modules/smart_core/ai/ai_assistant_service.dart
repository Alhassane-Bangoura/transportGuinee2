import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiAssistantService {
  late final GenerativeModel _model;
  final String role;

  AiAssistantService({required this.role}) {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception('GEMINI_API_KEY non trouvé dans le fichier .env');
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(_getSystemInstruction(role)),
    );
  }

  String _getSystemInstruction(String role) {
    switch (role.toUpperCase()) {
      case 'PASSAGER':
        return """Tu es l'assistant intelligent de GuineeTransport pour les PASSAGERS.
Ton but est d'aider à la réservation de trajets interurbains en Guinée (Conakry, Labé, Mamou, etc.).
Donne des informations sur les tarifs, les bagages et les horaires. 
Sois poli, serviable et utilise un ton chaleureux.""";
      case 'CHAUFFEUR':
        return """Tu es l'assistant intelligent de GuineeTransport pour les CHAUFFEURS.
Aide le chauffeur à gérer le remplissage de son véhicule et à calculer ses recettes prévisionnelles.
Donne des conseils sur la sécurité routière en Guinée et la gestion des temps de repos.""";
      case 'SYNDICAT':
        return """Tu es l'assistant intelligent de GuineeTransport pour les SYNDICATS.
Ton rôle est d'aider à la gestion des files d'attente en gare et de fournir des alertes trafic en temps réel.
Supporte les décisions organisationnelles pour fluidifier le départ des véhicules.""";
      case 'ADMIN_GARE':
        return """Tu es l'assistant intelligent de GuineeTransport pour les ADMINISTRATEURS DE GARE.
Aide à l'analyse des revenus de la gare (AB Business), à la gestion des quais et aux rapports d'incidents.
Fournis des résumés clairs sur l'activité globale de la gare.""";
      default:
        return "Tu es l'assistant intelligent de GuineeTransport. Aide l'utilisateur selon son rôle.";
    }
  }

  Future<String> sendMessage(String message) async {
    final content = [Content.text(message)];
    final response = await _model.generateContent(content);
    return response.text ?? "Désolé, je n'ai pas pu générer de réponse.";
  }

  Future<String> analyzeStationData({
    required int vehiclesInStation,
    required int departuresToday,
    required int readyVehicles,
    required String recentActivity,
  }) async {
    final prompt = """Analyse ces données de gare pour l'administrateur et fais un résumé court (2 phrases max) :
    - Véhicules en gare : \$vehiclesInStation
    - Départs aujourd'hui : \$departuresToday
    - Prêts à partir : \$readyVehicles
    - Activité récente : \$recentActivity""";
    
    return sendMessage(prompt);
  }
}
