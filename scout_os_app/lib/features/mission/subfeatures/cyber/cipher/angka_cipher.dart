import 'package:scout_os_app/features/mission/subfeatures/cyber/cipher/base_cipher.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';

/// Angka Cipher Implementation
///
/// Sandi Angka: A=1, B=2, C=3, ..., Z=26
class AngkaCipher extends BaseCipher {
  AngkaCipher(SandiModel sandiType) : super(sandiType);

  static const String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static final Map<String, String> textToNumber = {
    for (int i = 0; i < alphabet.length; i++) alphabet[i]: (i + 1).toString(),
  };
  static final Map<String, String> numberToText = {
    for (var entry in textToNumber.entries) entry.value: entry.key,
  };

  @override
  String encrypt(String text) {
    final result = <String>[];
    final textUpper = text.toUpperCase();

    for (var char in textUpper.split('')) {
      if (textToNumber.containsKey(char)) {
        result.add(textToNumber[char]!);
      } else if (char == ' ') {
        result.add(' '); // Keep spaces
      } else {
        result.add(char); // Keep unknown characters
      }
    }

    return result.join(' ');
  }

  @override
  String decrypt(String text) {
    final result = <String>[];
    // Split by spaces to get numbers
    final parts = text.split(' ');

    for (var part in parts) {
      if (part.isEmpty) {
        continue;
      } else if (numberToText.containsKey(part)) {
        result.add(numberToText[part]!);
      } else {
        result.add(part); // Keep unknown patterns
      }
    }

    return result.join('');
  }
}
