import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static final _supabase = Supabase.instance.client;

  /// Upload an image to Supabase Storage and return the public URL
  static Future<String?> uploadProfileImage(File file, String userId) async {
    try {
      final fileExt = file.path.split('.').last;
      final fileName = '$userId/${const Uuid().v4()}.$fileExt';
      final filePath = fileName;

      debugPrint('[StorageService] Uploading image: $filePath');

      await _supabase.storage.from('profiles').upload(
            filePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final String publicUrl = _supabase.storage.from('profiles').getPublicUrl(filePath);
      debugPrint('[StorageService] Upload success: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('[StorageService] Upload error: $e');
      rethrow; // On relance l'erreur pour qu'elle soit capturée par l'UI
    }
  }
}
