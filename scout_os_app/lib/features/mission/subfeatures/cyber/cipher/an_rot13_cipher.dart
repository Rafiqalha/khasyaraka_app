import 'package:scout_os_app/features/mission/subfeatures/cyber/cipher/base_cipher.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';

/// AN/ROT13 Cipher Implementation (Caesar cipher with shift 13)
class AnRot13Cipher extends BaseCipher {
  AnRot13Cipher(SandiModel sandiType) : super(sandiType);

  static const String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  @override
  String encrypt(String text) {
    final result = <String>[];
    final textUpper = text.toUpperCase();

    for (var char in textUpper.split('')) {
      if (alphabet.contains(char)) {
        final index = alphabet.indexOf(char);
        final shiftedIndex = (index + 13) % 26;
        result.add(alphabet[shiftedIndex]);
      } else {
        result.add(char); // Keep non-alphabetic characters
      }
    }

    return result.join('');
  }

  @override
  String decrypt(String text) {
    // ROT13 is self-reciprocal (encrypt and decrypt are the same)
    return encrypt(text);
  }
}
