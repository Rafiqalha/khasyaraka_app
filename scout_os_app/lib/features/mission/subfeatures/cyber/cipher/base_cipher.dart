import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';

/// Abstract base class for all cipher implementations
/// 
/// Semua cipher harus implement encrypt() dan decrypt()
abstract class BaseCipher {
  final SandiModel sandiType;

  BaseCipher(this.sandiType);

  /// Encrypt plaintext to ciphertext
  String encrypt(String text);

  /// Decrypt ciphertext to plaintext
  String decrypt(String text);
}
