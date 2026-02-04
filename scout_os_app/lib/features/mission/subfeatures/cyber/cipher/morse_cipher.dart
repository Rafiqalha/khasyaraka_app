import 'package:scout_os_app/features/mission/subfeatures/cyber/cipher/base_cipher.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';

/// Morse Code Cipher Implementation
class MorseCipher extends BaseCipher {
  MorseCipher(SandiModel sandiType) : super(sandiType);

  // Morse code dictionary: Morse -> Text
  static const Map<String, String> morseToText = {
    '.-': 'A', '-...': 'B', '-.-.': 'C', '-..': 'D', '.': 'E',
    '..-.': 'F', '--.': 'G', '....': 'H', '..': 'I', '.---': 'J',
    '-.-': 'K', '.-..': 'L', '--': 'M', '-.': 'N', '---': 'O',
    '.--.': 'P', '--.-': 'Q', '.-.': 'R', '...': 'S', '-': 'T',
    '..-': 'U', '...-': 'V', '.--': 'W', '-..-': 'X', '-.--': 'Y',
    '--..': 'Z',
    '-----': '0', '.----': '1', '..---': '2', '...--': '3',
    '....-': '4', '.....': '5', '-....': '6', '--...': '7',
    '---..': '8', '----.': '9',
    '.-.-.-': '.', '--..--': ',', '..--..': '?', '-.-.--': '!',
  };

  // Reverse dictionary: Text -> Morse
  static final Map<String, String> textToMorse = {
    for (var entry in morseToText.entries) entry.value: entry.key,
  };

  @override
  String encrypt(String text) {
    final result = <String>[];
    final textUpper = text.toUpperCase();

    for (var char in textUpper.split('')) {
      if (char == ' ') {
        result.add('/');
      } else if (textToMorse.containsKey(char)) {
        result.add(textToMorse[char]!);
      } else {
        result.add(char); // Keep unknown characters
      }
    }

    return result.join(' ');
  }

  @override
  String decrypt(String text) {
    final result = <String>[];
    // Split by spaces, but preserve '/' as word separator
    final parts = text.replaceAll('/', ' / ').split(' ');

    for (var part in parts) {
      if (part == '/') {
        result.add(' ');
      } else if (morseToText.containsKey(part)) {
        result.add(morseToText[part]!);
      } else if (part.isNotEmpty) {
        result.add(part); // Keep unknown patterns
      }
    }

    return result.join('');
  }
}
