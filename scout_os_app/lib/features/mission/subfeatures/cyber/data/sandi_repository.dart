/// Sandi Repository - Offline Tools Repository
/// 
/// 100% OFFLINE - NO API CALLS
/// Semua data hardcoded untuk kegiatan outdoor pramuka
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_data.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/cipher/cipher_factory.dart';

class SandiRepository {
  /// Get all Sandi types (hardcoded, offline)
  List<SandiModel> getAllSandi() {
    return SandiData.allSandi
        .map((data) {
          // Add timestamps for model compatibility
          final now = DateTime.now();
          return {
            ...data,
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          };
        })
        .map((data) => SandiModel.fromJson(data))
        .toList();
  }

  /// Get Sandi by codename
  SandiModel? getSandiByCodename(String codename) {
    try {
      return getAllSandi().firstWhere(
        (sandi) => sandi.codename.toLowerCase() == codename.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Process cipher encryption/decryption (client-side, offline)
  /// 
  /// [text] - Input text to process
  /// [codename] - Sandi codename (e.g., 'morse', 'an_rot13')
  /// [isEncrypt] - true for encrypt, false for decrypt
  String processCipher({
    required String text,
    required String codename,
    required bool isEncrypt,
  }) {
    if (text.isEmpty) return '';

    // Get Sandi type
    final sandi = getSandiByCodename(codename);
    if (sandi == null) {
      return '[Error] Sandi type "$codename" not found';
    }

    // Create cipher instance using factory
    final cipher = CipherFactory.createCipher(sandi);

    // Process text
    try {
      return isEncrypt ? cipher.encrypt(text) : cipher.decrypt(text);
    } catch (e) {
      return '[Error] Processing failed: $e';
    }
  }
}
