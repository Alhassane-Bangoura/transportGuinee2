import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/assistant_message.dart';

class AssistantService {
  final String fallbackRole;
  final _supabase = Supabase.instance.client;

  AssistantService({required this.fallbackRole});

  String _getUserRole() {
    final user = _supabase.auth.currentUser;
    // Prefer metadata role, fallback to constructor role
    return user?.userMetadata?['role']?.toString().toUpperCase() ?? fallbackRole.toUpperCase();
  }

  Future<List<AssistantMessage>> getHistory() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from('assistant_messages')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true);

      return (response as List).map((m) => AssistantMessage.fromJson(m)).toList();
    } catch (e) {
      print('Error fetching AI history: $e');
      return [];
    }
  }

  Future<AssistantMessage> sendMessage(String text, List<AssistantMessage> history) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    final currentRole = _getUserRole();

    // 1. Persist User Message
    final userMsgMap = {
      'user_id': user.id,
      'role': currentRole,
      'content': text,
      'sender_type': 'user',
    };
    
    await _supabase.from('assistant_messages').insert(userMsgMap);

    // 2. Call Supabase Edge Function
    try {
      final response = await _supabase.functions.invoke(
        'ai-assistant',
        body: {
          'query': text,
          'history': history.map((m) => {
            'role': m.senderType == 'user' ? 'user' : 'model',
            'content': m.content,
          }).toList(),
          'role': currentRole,
        },
      );

      if (response.status != 200) {
        throw Exception('Erreur de l\'assistant IA: ${response.data}');
      }

      final aiText = response.data['text'] ?? "Désolé, je rencontre une difficulté technique.";

      // 3. Persist AI Message
      final aiMsgMap = {
        'user_id': user.id,
        'role': currentRole,
        'content': aiText,
        'sender_type': 'ai',
      };

      final savedAiMsg = await _supabase
          .from('assistant_messages')
          .insert(aiMsgMap)
          .select()
          .single();

      return AssistantMessage.fromJson(savedAiMsg);
    } catch (e) {
      print('AI Service Error: $e');
      rethrow;
    }
  }
}
