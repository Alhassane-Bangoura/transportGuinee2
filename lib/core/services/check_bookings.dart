import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_config.dart';

void main() async {
  final supabase = SupabaseClient(SupabaseConfig.url, SupabaseConfig.anonKey);
  try {
    final res = await supabase.from('bookings').select().limit(1);
    if (res.isNotEmpty) {
      print('Bookings columns: ${res.first.keys}');
    } else {
      print('Bookings table is empty');
    }
  } catch (e) {
    print('Error: $e');
  }
}
