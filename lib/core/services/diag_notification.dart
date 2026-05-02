import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_config.dart';

// Ce script est destiné à être exécuté avec 'dart run' pour inspecter les données réelles
void main() async {
  final supabase = SupabaseClient(SupabaseConfig.url, SupabaseConfig.anonKey);
  try {
    final res = await supabase.from('notifications').select().limit(1);
    print('Sample notification: \$res');
  } catch (e) {
    print('Error: \$e');
  }
}
