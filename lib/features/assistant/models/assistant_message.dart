class AssistantMessage {
  final String id;
  final String userId;
  final String role; // User role (PASSAGER, etc.)
  final String content;
  final DateTime createdAt;
  final String senderType; // 'user' or 'ai'

  AssistantMessage({
    required this.id,
    required this.userId,
    required this.role,
    required this.content,
    required this.createdAt,
    required this.senderType,
  });

  factory AssistantMessage.fromJson(Map<String, dynamic> json) {
    return AssistantMessage(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      senderType: json['sender_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'role': role,
      'content': content,
      'sender_type': senderType,
    };
  }
}
