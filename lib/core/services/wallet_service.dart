import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wallet_transaction.dart';

class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  static final _supabase = Supabase.instance.client;

  double _balance = 0.0;
  List<WalletTransaction> _transactions = [];
  bool _isInitialized = false;
  String? _walletId;
  
  final _balanceController = StreamController<double>.broadcast();
  Stream<double> get onBalanceChanged => _balanceController.stream;

  double get balance => _balance;
  List<WalletTransaction> get transactions => List.unmodifiable(_transactions);

  /// Réinitialise le service (déconnexion)
  void reset() {
    _balance = 0.0;
    _transactions = [];
    _isInitialized = false;
    _walletId = null;
    debugPrint('[WalletService] Reset');
  }

  Future<void> init() async {
    if (_isInitialized) return;
    
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // 1. Récupérer le wallet
      final walletData = await _supabase
          .from('wallets')
          .select('id, balance')
          .eq('user_id', userId)
          .maybeSingle();

      if (walletData != null) {
        _balance = (walletData['balance'] as num).toDouble();
        _walletId = walletData['id'];

        // 2. Charger les transactions
        final txData = await _supabase
            .from('wallet_transactions')
            .select()
            .eq('wallet_id', _walletId!)
            .order('created_at', ascending: false);

        _transactions = (txData as List)
            .map((item) => WalletTransaction.fromJson(item))
            .toList();
            
        // Sauvegarder dans SharedPreferences en cas de succès
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('wallet_balance_$userId', _balance);
        await prefs.setString('wallet_tx_$userId', jsonEncode(_transactions.map((t) => t.toJson()).toList()));
      } else {
        throw Exception('Wallet not found');
      }
    } catch (e) {
      // Fallback: Charger depuis SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _balance = prefs.getDouble('wallet_balance_$userId') ?? 0.0;
      final txString = prefs.getString('wallet_tx_$userId');
      if (txString != null) {
        try {
          final List<dynamic> decoded = jsonDecode(txString);
          _transactions = decoded.map((item) => WalletTransaction.fromJson(item)).toList();
        } catch (_) {
          _transactions = [];
        }
      } else {
        _transactions = [];
      }
    }
    
    _isInitialized = true;
    _balanceController.add(_balance);
  }

  Future<void> addTransaction(WalletTransaction tx) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // 1. Calcul du nouveau solde (le montant est déjà signé : + pour dépôt, - pour paiement)
    double newBalance = _balance + tx.amount;

    try {
      if (_walletId != null) {
        // 2. Mise à jour Supabase
        await _supabase
            .from('wallets')
            .update({'balance': newBalance})
            .eq('id', _walletId!);

        final txMap = {
          'wallet_id': _walletId,
          'amount': tx.amount,
          'type': tx.type.toString().split('.').last,
          'method': tx.method,
          'description': tx.description,
          'from_city': tx.fromCity,
          'to_city': tx.toCity,
          'created_at': DateTime.now().toIso8601String()
        };
        
        final insertedTx = await _supabase.from('wallet_transactions').insert(txMap).select().single();
        final savedTx = WalletTransaction.fromJson(insertedTx);
        _transactions.insert(0, savedTx);
      } else {
        throw Exception('No wallet_id to update');
      }
    } catch (e) {
      // Fallback local uniquement si la base de données ne répond pas ou que la table n'existe pas
      _transactions.insert(0, tx);
    }
    
    // Sauvegarder le nouveau solde et les transactions localement
    _balance = newBalance;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('wallet_balance_$userId', _balance);
    await prefs.setString('wallet_tx_$userId', jsonEncode(_transactions.map((t) => t.toJson()).toList()));

    _balanceController.add(_balance);
  }

  void dispose() {}
}
