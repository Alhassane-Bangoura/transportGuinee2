import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/assistant_message.dart';

class AssistantService {
  final String fallbackRole;
  final _supabase = Supabase.instance.client;

  AssistantService({required this.fallbackRole});

  String _getUserRole() {
    final user = _supabase.auth.currentUser;
    final metadata = user?.userMetadata ?? {};
    final dynamic role = metadata['role_key'] ?? 
                         metadata['role'] ?? 
                         metadata['role_name'];
    
    final String roleStr = role?.toString().toLowerCase() ?? fallbackRole.toLowerCase();
    if (roleStr.contains('chauffeur') || roleStr.contains('driver')) return 'driver';
    return roleStr.trim();
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
      debugPrint('Error fetching conversations: $e');
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
      debugPrint('Error creating conversation: $e');
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
      debugPrint('Error fetching AI history: $e');
      return [];
    }
  }

  Future<AssistantMessage> sendMessage(String text, List<AssistantMessage> history, {String? conversationId}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    final currentRole = _getUserRole();
    
    // 1. Get Business Context from Database (Omniscience)
    String contextInfo = "Rôle: $currentRole. GuinéeTransport AI.\n";
    
    if (currentRole == 'driver' || currentRole == 'chauffeur') {
      try {
        final tripsRes = await _supabase.from('trips_with_details')
            .select()
            .eq('driver_id', user.id)
            .order('departure_time', ascending: false)
            .limit(20);
            
        if (tripsRes.isNotEmpty) {
          contextInfo += "VOS TRAJETS (CHAUFFEUR) :\n";
          for (var t in tripsRes) {
            contextInfo += "- ${t['departure_city_name']} → ${t['arrival_city_name']} le ${t['departure_time']} [Status: ${t['status']}, Places: ${t['available_seats']}]\n";
          }
        } else {
          contextInfo += "Vous n'avez pas encore publié de trajet.\n";
        }
      } catch (e) { debugPrint('Error driver context: $e'); }
    } else {
      // Passager : On récupère les trajets disponibles
      try {
        final tripsRes = await _supabase.from('trips_with_details')
            .select()
            .gte('departure_time', DateTime.now().toIso8601String())
            .order('departure_time', ascending: true)
            .limit(50);
            
        if (tripsRes.isNotEmpty) {
          contextInfo += "TRAJETS DISPONIBLES :\n";
          for (var t in tripsRes) {
            contextInfo += "- ${t['departure_city_name']} → ${t['arrival_city_name']} | Départ: ${t['departure_time']} | Prix: ${t['price']} GNF\n";
          }
        }
      } catch (e) { debugPrint('Error passenger context: $e'); }
    }

    // 2. Map History for Edge Function
    final List<Map<String, dynamic>> geminiHistory = history.map((m) {
      return {
        'role': m.senderType == 'user' ? 'user' : 'model',
        'parts': [{'text': m.content}],
      };
    }).toList();

    // 3. Invoke Secure Edge Function
    try {
      final response = await _supabase.functions.invoke(
        'ai-assistant',
        body: {
          'query': text,
          'context': contextInfo,
          'history': geminiHistory,
        },
      );

      if (response.status != 200) {
        throw Exception('Erreur assistant (${response.status})');
      }

      final String aiText = response.data['text'] ?? "Désolé, je n'ai pas pu répondre.";

      // 4. Persist Messages
      await _supabase.from('assistant_messages').insert({
        'user_id': user.id,
        'role': currentRole,
        'content': text,
        'sender_type': 'user',
        'conversation_id': conversationId,
      });

      final savedAiMsg = await _supabase.from('assistant_messages').insert({
        'user_id': user.id,
        'role': currentRole,
        'content': aiText,
        'sender_type': 'ai',
        'conversation_id': conversationId,
      }).select().single();

      return AssistantMessage.fromJson(savedAiMsg);
    } catch (e) {
      debugPrint('AI Service Error: $e');
      rethrow;
    }
  }

  Future<void> deleteConversation(String id) async {
    await _supabase.from('assistant_conversations').delete().eq('id', id);
  }
}
