import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/assistant_message.dart';

class AssistantService {
  final String fallbackRole;
  final _supabase = Supabase.instance.client;

  AssistantService({required this.fallbackRole});

  String _getUserRole() {
    final user = _supabase.auth.currentUser;
    final dynamic role = user?.userMetadata?['role'] ?? user?.userMetadata?['role_key'];
    return role?.toString().toLowerCase() ?? fallbackRole.toLowerCase();
  }

  Future<List<Map<String, dynamic>>> getConversations() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from('assistant_conversations')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching conversations: $e');
      return [];
    }
  }

  Future<String> createConversation(String title) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Non connecté');

    try {
      final response = await _supabase
          .from('assistant_conversations')
          .insert({'user_id': userId, 'title': title})
          .select()
          .single();

      return response['id'] as String;
    } catch (e) {
      print('Error creating conversation: $e');
      rethrow;
    }
  }

  Future<List<AssistantMessage>> getHistory({String? conversationId}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      var query = _supabase.from('assistant_messages').select();
      
      if (conversationId != null) {
        query = query.eq('conversation_id', conversationId);
      } else {
        query = query.eq('user_id', userId);
      }

      final response = await query.order('created_at', ascending: true);
      return (response as List).map((m) => AssistantMessage.fromJson(m)).toList();
    } catch (e) {
      print('Error fetching AI history: $e');
      return [];
    }
  }

  Future<AssistantMessage> sendMessage(String text, List<AssistantMessage> history, {String? conversationId}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    final currentRole = _getUserRole();
    // Le SDK Supabase injecte automatiquement l'API Key et le Bearer token
    // On ne les force plus manuellement pour éviter les erreurs de format (401)

    // 1. Get Business Context
    String contextInfo = "";
    if (currentRole == 'driver') {
      try {
        final tripsRes = await _supabase
            .from('trips_with_details')
            .select('departure_city_name, arrival_city_name, departure_time, status, total_seats, available_seats')
            .eq('driver_id', user.id)
            .neq('status', 'completed')
            .order('departure_time', ascending: true)
            .limit(1);
            
        if (tripsRes.isNotEmpty) {
          final t = tripsRes.first;
          contextInfo = "CONTEXTE CHAUFFEUR ACTUEL : ${t['departure_city_name']} ➔ ${t['arrival_city_name']} (${t['status']})";
        }
      } catch (_) {}
    }

    // 2. Call Supabase Edge Function NATIVE way
    try {
      final response = await _supabase.functions.invoke(
        'ai-assistant',
        body: {
          'query': text,
          'context': contextInfo,
          'history': history.map((m) => {
            'role': m.senderType == 'user' ? 'user' : 'model',
            'content': m.content,
          }).toList(),
          'role': currentRole,
        },
      );

      if (response.status != 200) {
        throw Exception('Assistant error (${response.status}): ${response.data}');
      }

      final aiText = response.data['text'] ?? "Erreur de réponse.";

      // 3. Persist Messages
      final userMsgMap = {
        'user_id': user.id,
        'role': currentRole,
        'content': text,
        'sender_type': 'user',
        'conversation_id': conversationId,
      };
      
      await _supabase.from('assistant_messages').insert(userMsgMap);

      final aiMsgMap = {
        'user_id': user.id,
        'role': currentRole,
        'content': aiText,
        'sender_type': 'ai',
        'conversation_id': conversationId,
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
