// ============================================================================
// Modèle WalletTransaction — Historique des transactions du portefeuille
// ============================================================================

enum TransactionType { topup, payment, refund }

class WalletTransaction {
  final String id;
  final String userId;
  final double amount;
  final TransactionType type;
  final String method; // ex: Orange Money, MTN, Paiement Trajet
  final String description;
  final DateTime createdAt;
  final bool isSuccess;
  final String? fromCity;
  final String? toCity;

  const WalletTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.method,
    required this.description,
    required this.createdAt,
    this.isSuccess = true,
    this.fromCity,
    this.toCity,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    // Parsing sécurisé du type
    TransactionType typeValue = TransactionType.topup;
    try {
      typeValue = TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => TransactionType.topup,
      );
    } catch (_) {}

    return WalletTransaction(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: json['user_id']?.toString() ?? 'unknown',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: typeValue,
      method: json['method'] as String? ?? 'Inconnu',
      description: json['description'] as String? ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
      isSuccess: json['is_success'] as bool? ?? true,
      fromCity: json['from_city'] as String?,
      toCity: json['to_city'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'type': type.toString().split('.').last,
      'method': method,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'is_success': isSuccess,
      'from_city': fromCity,
      'to_city': toCity,
    };
  }

  String get formattedAmount {
    final prefix = type == TransactionType.topup ? '+' : '-';
    final value = amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => "${m[1]}.",
    );
    return '$prefix$value GNF';
  }
}
