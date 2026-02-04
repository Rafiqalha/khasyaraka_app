import 'package:scout_os_app/features/mission/subfeatures/cyber/cipher/base_cipher.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';

/// AZ/Atbash Cipher Implementation
/// 
/// Atbash cipher: A=Z, B=Y, C=X, ..., Z=A
class AzAtbashCipher extends BaseCipher {
  AzAtbashCipher(SandiModel sandiType) : super(sandiType);

  static const String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static final Map<String, String> atbashMap = {
    for (int i = 0; i < alphabet.length; i++)
      alphabet[i]: alphabet[alphabet.length - 1 - i],
  };

  @override
  String encrypt(String text) {
    final result = <String>[];
    final textUpper = text.toUpperCase();

    for (var char in textUpper.split('')) {
      if (atbashMap.containsKey(char)) {
        result.add(atbashMap[char]!);
      } else {
        result.add(char); // Keep non-alphabetic characters
      }
    }

    return result.join('');
  }

  @override
  String decrypt(String text) {
    // Atbash is self-reciprocal (encrypt and decrypt are the same)
    return encrypt(text);
  }
}
