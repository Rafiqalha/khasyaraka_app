import 'package:scout_os_app/features/mission/subfeatures/cyber/cipher/base_cipher.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';

/// Placeholder cipher for unimplemented types
class PlaceholderCipher extends BaseCipher {
  PlaceholderCipher(SandiModel sandiType) : super(sandiType);

  @override
  String encrypt(String text) {
    return '[Not Implemented] ENCRYPT: $text';
  }

  @override
  String decrypt(String text) {
    return '[Not Implemented] DECRYPT: $text';
  }
}
