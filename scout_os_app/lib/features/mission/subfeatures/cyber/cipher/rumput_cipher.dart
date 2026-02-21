import 'package:scout_os_app/features/mission/subfeatures/cyber/cipher/base_cipher.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';

/// Sandi Rumput Cipher Implementation
///
/// Sandi Rumput menggunakan pola garis-garis vertikal dan horizontal
/// yang menyerupai rumput untuk menyandikan huruf.
///
/// Format: Setiap huruf direpresentasikan dengan pola 5 baris
/// - Baris 1-5: Kombinasi garis vertikal (|) dan spasi
/// - Contoh: A = "| |\n| |\n|||\n| |\n| |"
class RumputCipher extends BaseCipher {
  RumputCipher(SandiModel sandiType) : super(sandiType);

  // Sandi Rumput mapping: Text -> Rumput Pattern (5 lines)
  // Setiap huruf direpresentasikan dengan 5 baris pola rumput
  // Format: Setiap baris menggunakan '|' untuk garis vertikal (rumput)
  static const Map<String, String> textToRumput = {
    'A': ' | | \n|   |\n|||||\n|   |\n|   |',
    'B': '|||  \n|   |\n|||  \n|   |\n|||  ',
    'C': ' ||| \n|    \n|    \n|    \n ||| ',
    'D': '|||  \n|   |\n|   |\n|   |\n|||  ',
    'E': '|||||\n|    \n|||  \n|    \n|||||',
    'F': '|||||\n|    \n|||  \n|    \n|    ',
    'G': ' ||| \n|    \n|  ||\n|   |\n ||| ',
    'H': '|   |\n|   |\n|||||\n|   |\n|   |',
    'I': '|||||\n  |  \n  |  \n  |  \n|||||',
    'J': '|||||\n   | \n   | \n|  | \n ||| ',
    'K': '|   |\n|  | \n|||  \n|  | \n|   |',
    'L': '|    \n|    \n|    \n|    \n|||||',
    'M': '|   |\n|| ||\n| | |\n|   |\n|   |',
    'N': '|   |\n||  |\n| | |\n|  ||\n|   |',
    'O': ' ||| \n|   |\n|   |\n|   |\n ||| ',
    'P': '|||  \n|   |\n|||  \n|    \n|    ',
    'Q': ' ||| \n|   |\n| | |\n|  ||\n ||| ',
    'R': '|||  \n|   |\n|||  \n| |  \n|   |',
    'S': ' ||| \n|    \n ||| \n    |\n ||| ',
    'T': '|||||\n  |  \n  |  \n  |  \n  |  ',
    'U': '|   |\n|   |\n|   |\n|   |\n ||| ',
    'V': '|   |\n|   |\n|   |\n | | \n  |  ',
    'W': '|   |\n|   |\n| | |\n|| ||\n|   |',
    'X': '|   |\n | | \n  |  \n | | \n|   |',
    'Y': '|   |\n | | \n  |  \n  |  \n  |  ',
    'Z': '|||||\n   | \n  |  \n |   \n|||||',
    '0': ' ||| \n|   |\n|   |\n|   |\n ||| ',
    '1': '  |  \n ||  \n  |  \n  |  \n ||| ',
    '2': ' ||| \n    |\n ||| \n|    \n ||| ',
    '3': ' ||| \n    |\n ||| \n    |\n ||| ',
    '4': '|   |\n|   |\n ||| \n    |\n    |',
    '5': ' ||| \n|    \n ||| \n    |\n ||| ',
    '6': ' ||| \n|    \n ||| \n|   |\n ||| ',
    '7': ' ||| \n    |\n    |\n    |\n    |',
    '8': ' ||| \n|   |\n ||| \n|   |\n ||| ',
    '9': ' ||| \n|   |\n ||| \n    |\n ||| ',
    ' ': '     \n     \n     \n     \n     ', // 5 empty lines for space
  };

  // Reverse mapping: Rumput Pattern -> Text
  static final Map<String, String> rumputToText = {
    for (var entry in textToRumput.entries) entry.value: entry.key,
  };

  @override
  String encrypt(String text) {
    final result = <String>[];
    final textUpper = text.toUpperCase();

    for (var char in textUpper.split('')) {
      if (textToRumput.containsKey(char)) {
        result.add(textToRumput[char]!);
      } else {
        // For unknown characters, use space pattern
        result.add(textToRumput[' ']!);
      }
    }

    // Join with double newline to separate letters
    return result.join('\n\n');
  }

  @override
  String decrypt(String text) {
    final result = <String>[];

    // Split by double newline to get individual letter patterns
    final letterPatterns = text.split('\n\n');

    for (var pattern in letterPatterns) {
      // Normalize pattern (remove trailing/leading whitespace)
      final normalized = pattern.trim();

      if (normalized.isEmpty) {
        result.add(' ');
      } else if (rumputToText.containsKey(normalized)) {
        result.add(rumputToText[normalized]!);
      } else {
        // Try to find closest match or add placeholder
        result.add('?');
      }
    }

    return result.join('');
  }
}
