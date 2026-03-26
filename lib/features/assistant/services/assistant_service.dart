import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/assistant_message.dart';
import '../models/assistant_message.dart';

class AssistantService {
  final String role;
  final _supabase = Supabase.instance.client;

  AssistantService({required this.role});

  String _getSystemInstruction(String role) {
    switch (role.toUpperCase()) {
      case 'PASSAGER':
        return "Tu es l'assistant de GuineeTransport pour les PASSAGERS. Aide-les pour les trajets, réservations et tarifs. Sois chaleureux.";
      case 'CHAUFFEUR':
        return "Tu es l'assistant pour les CHAUFFEURS. Aide-les pour leurs trajets, passagers et revenus. Sois précis et technique.";
      case 'SYNDICAT':
        return "Tu es l'assistant pour les SYNDICATS. Aide à la gestion des chauffeurs et départs. Sois organisationnel.";
      case 'ADMIN_GARE':
        return "Tu es l'assistant pour les ADMINS DE GARE. Supervise l'activité de la gare. Sois analytique.";
      default:
        return "Assistant GuineeTransport.";
    }
  }

  Future<List<AssistantMessage>> getHistory() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('assistant_messages')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: true);

    return (response as List).map((m) => AssistantMessage.fromJson(m)).toList();
  }

  Future<AssistantMessage> sendMessage(String text, List<AssistantMessage> history) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // 1. Persist User Message
    final userMsgMap = {
      'user_id': userId,
      'role': role,
      'content': text,
      'sender_type': 'user',
    };
    
    await _supabase
        .from('assistant_messages')
        .insert(userMsgMap)
        .select()
        .single();

    // 2. Call Supabase Edge Function
    final response = await _supabase.functions.invoke(
      'ai-assistant',
      body: {
        'query': text,
        'history': history.map((m) => {
          'role': m.senderType == 'user' ? 'user' : 'model',
          'content': m.content,
        }).toList(),
        'role': role,
      },
    );

    if (response.status != 200) {
      throw Exception('Failed to get AI response: ${response.data}');
    }

    final aiText = response.data['text'] ?? "Désolé, je rencontre une difficulté technique.";

    // 3. Persist AI Message
    final aiMsgMap = {
      'user_id': userId,
      'role': role,
      'content': aiText,
      'sender_type': 'ai',
    };

    final savedAiMsg = await _supabase
        .from('assistant_messages')
        .insert(aiMsgMap)
        .select()
        .single();

    return AssistantMessage.fromJson(savedAiMsg);
  }
}
