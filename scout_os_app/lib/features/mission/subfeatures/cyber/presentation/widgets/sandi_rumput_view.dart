import 'package:flutter/material.dart';

/// Sandi Rumput View Widget
///
/// Visualizes text as a continuous line graph representing grass/mountains
/// based on Morse Code pattern.
///
/// Example: "AKU" -> ".- -.- ..-" -> continuous line with peaks
///
/// Can also accept morse code directly via [morseCode] parameter
class SandiRumputView extends StatelessWidget {
  final String? text;
  final String? morseCode; // Direct morse code input (for decode mode)
  final double strokeWidth;
  final Color color;
  final double unitWidth;
  final double shortHeight;
  final double tallHeight;
  final double spaceWidth;

  const SandiRumputView({
    super.key,
    this.text,
    this.morseCode,
    this.strokeWidth = 2.0,
    this.color = Colors.black,
    this.unitWidth = 15.0,
    this.shortHeight = 25.0,
    this.tallHeight = 75.0,
    this.spaceWidth = 20.0,
  }) : assert(
         text != null || morseCode != null,
         'Either text or morseCode must be provided',
       );

  /// Convert text to Morse Code string
  ///
  /// Comprehensive dictionary for A-Z and 0-9
  static String textToMorse(String text) {
    final morseMap = {
      'A': '.-', 'B': '-...', 'C': '-.-.', 'D': '-..', 'E': '.',
      'F': '..-.', 'G': '--.', 'H': '....', 'I': '..', 'J': '.---',
      'K': '-.-', 'L': '.-..', 'M': '--', 'N': '-.', 'O': '---',
      'P': '.--.', 'Q': '--.-', 'R': '.-.', 'S': '...', 'T': '-',
      'U': '..-', 'V': '...-', 'W': '.--', 'X': '-..-', 'Y': '-.--',
      'Z': '--..',
      '0': '-----', '1': '.----', '2': '..---', '3': '...--',
      '4': '....-', '5': '.....', '6': '-....', '7': '--...',
      '8': '---..', '9': '----.',
      ' ': ' ', // Space between words
    };

    final result = <String>[];
    final textUpper = text.toUpperCase();

    for (var char in textUpper.split('')) {
      if (morseMap.containsKey(char)) {
        result.add(morseMap[char]!);
      }
    }

    return result.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    // Use morseCode directly if provided, otherwise convert text to morse
    final finalMorseCode =
        morseCode ?? (text != null ? textToMorse(text!) : '');

    if (finalMorseCode.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate required width based on morse code
    double totalWidth = 32.0; // Start with padding (16px left + 16px right)
    for (var char in finalMorseCode.split('')) {
      if (char == '.' || char == '-') {
        totalWidth += unitWidth;
      } else if (char == ' ') {
        totalWidth += spaceWidth;
      }
    }

    // Ensure minimum width
    if (totalWidth < 100) {
      totalWidth = 100;
    }

    return SizedBox(
      width: totalWidth,
      height: tallHeight + 40, // Height based on tallest peak + padding
      child: CustomPaint(
        painter: SandiRumputPainter(
          morseCode: finalMorseCode,
          strokeWidth: strokeWidth,
          color: color,
          unitWidth: unitWidth,
          shortHeight: shortHeight,
          tallHeight: tallHeight,
          spaceWidth: spaceWidth,
        ),
      ),
    );
  }
}

/// Custom Painter for Sandi Rumput visualization
///
/// Draws a continuous line graph representing Morse Code as grass/mountains.
///
/// Rules:
/// - Baseline at y = 0 (bottom of canvas)
/// - Continuous path (never breaks)
/// - Dot (.) = small triangle peak (height = shortHeight)
/// - Dash (-) = tall triangle peak (height = tallHeight = 3x shortHeight)
/// - Letter spacing = flat horizontal line on baseline
/// - Sharp peaks (StrokeJoin.miter)
class SandiRumputPainter extends CustomPainter {
  final String morseCode;
  final double strokeWidth;
  final Color color;
  final double unitWidth;
  final double shortHeight;
  final double tallHeight;
  final double spaceWidth;

  SandiRumputPainter({
    required this.morseCode,
    this.strokeWidth = 2.0,
    this.color = Colors.black,
    this.unitWidth = 15.0,
    this.shortHeight = 25.0,
    this.tallHeight = 75.0,
    this.spaceWidth = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (morseCode.isEmpty || size.width <= 0 || size.height <= 0) return;

    // Configure paint for sharp peaks - CRITICAL: StrokeJoin.miter for sharp peaks
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin
          .miter // Sharp peaks, not rounded - CRITICAL!
      ..strokeCap = StrokeCap.butt; // Sharp caps

    // Create continuous path - ONE SINGLE PATH, NEVER BREAKS
    final path = Path();

    // Baseline at y = 0 means bottom of canvas
    // In Flutter coordinate system: y=0 is top, y=size.height is bottom
    // So baselineY = size.height (bottom of canvas)
    // Add padding from left edge
    double x = 16.0;
    final baselineY = size.height - 20; // 20px padding from bottom

    // Ensure baseline is within canvas bounds
    if (baselineY <= 0 || baselineY >= size.height) return;

    // Start path at baseline (bottom left) - THIS IS WHERE WE START
    path.moveTo(x, baselineY);

    // Iterate through Morse code characters - CONTINUOUS PATH, NO BREAKS
    for (int i = 0; i < morseCode.length; i++) {
      final char = morseCode[i];

      if (char == '.') {
        // Dot: small triangle peak
        // Move to peak (center of unit width, up by shortHeight from baseline)
        final peakX = x + unitWidth / 2;
        final peakY = baselineY - shortHeight;

        // Ensure peak is within bounds
        if (peakY >= 0 && peakX < size.width) {
          path.lineTo(peakX, peakY); // Go up to peak

          // Move to base (end of unit width, back to baseline)
          x += unitWidth;
          if (x <= size.width) {
            path.lineTo(x, baselineY); // Return to baseline
          }
        } else {
          break; // Stop if out of bounds
        }
      } else if (char == '-') {
        // Dash: tall triangle peak (3x height of dot)
        // Move to peak (center of unit width, up by tallHeight from baseline)
        final peakX = x + unitWidth / 2;
        final peakY = baselineY - tallHeight;

        // Ensure peak is within bounds
        if (peakY >= 0 && peakX < size.width) {
          path.lineTo(peakX, peakY); // Go up to peak

          // Move to base (end of unit width, back to baseline)
          x += unitWidth;
          if (x <= size.width) {
            path.lineTo(x, baselineY); // Return to baseline
          }
        } else {
          break; // Stop if out of bounds
        }
      } else if (char == ' ') {
        // Space between letters: flat horizontal line on baseline (DO NOT LIFT PEN)
        x += spaceWidth;
        if (x <= size.width) {
          path.lineTo(x, baselineY); // Continue on baseline
        } else {
          break; // Stop if out of bounds
        }
      }
      // Ignore other characters
    }

    // Draw the continuous path - ONE SINGLE UNBROKEN PATH
    if (path.computeMetrics().isNotEmpty) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(SandiRumputPainter oldDelegate) {
    return oldDelegate.morseCode != morseCode ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.color != color ||
        oldDelegate.unitWidth != unitWidth ||
        oldDelegate.shortHeight != shortHeight ||
        oldDelegate.tallHeight != tallHeight ||
        oldDelegate.spaceWidth != spaceWidth;
  }
}
