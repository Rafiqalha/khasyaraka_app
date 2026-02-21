import 'package:scout_os_app/features/mission/subfeatures/cyber/cipher/base_cipher.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/cipher/morse_cipher.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/cipher/rumput_cipher.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/cipher/an_rot13_cipher.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/cipher/az_atbash_cipher.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/cipher/angka_cipher.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/cipher/placeholder_cipher.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';

/// Factory class to create cipher instances based on codename
class CipherFactory {
  /// Create cipher instance based on sandi codename
  ///
  /// Returns BaseCipher instance, or PlaceholderCipher if not implemented
  static BaseCipher createCipher(SandiModel sandiType) {
    final codename = sandiType.codename.toLowerCase();

    switch (codename) {
      case 'morse':
        return MorseCipher(sandiType);
      case 'rumput':
        return RumputCipher(sandiType);
      case 'an_rot13':
        return AnRot13Cipher(sandiType);
      case 'az_atbash':
        return AzAtbashCipher(sandiType);
      case 'angka':
        return AngkaCipher(sandiType);
      // Add more cipher implementations here as they are developed
      default:
        return PlaceholderCipher(sandiType);
    }
  }
}
