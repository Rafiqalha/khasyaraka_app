import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/theme/cyber_theme.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/widgets/cyber_container.dart';

/// Sandi Kotak 1 (Pigpen Cipher Variant 1) Tool
///
/// Replaces letters with geometric symbols from tic-tac-toe and X grids.
/// Some symbols have dots, some don't.
class SandiKotak1Page extends StatefulWidget {
  final SandiModel sandi;

  const SandiKotak1Page({super.key, required this.sandi});

  @override
  State<SandiKotak1Page> createState() => _SandiKotak1PageState();
}

class _SandiKotak1PageState extends State<SandiKotak1Page> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _decodeController = TextEditingController();
  String _encodedText = '';
  bool _isEncryptMode = true; // true = Encode, false = Decode
  List<String> _inputHistory = []; // Track symbols tapped in decode mode

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_onInputChanged);
    _decodeController.addListener(_onDecodeChanged);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _decodeController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    setState(() {
      _encodedText = _inputController.text.toUpperCase();
    });
  }

  void _onDecodeChanged() {
    setState(() {});
  }

  void _toggleMode() {
    setState(() {
      _isEncryptMode = !_isEncryptMode;
      _inputController.clear();
      _decodeController.clear();
      _encodedText = '';
      _inputHistory.clear();
    });
  }

  void _onSymbolKeyTap(String letter) {
    setState(() {
      _decodeController.text += letter;
      _inputHistory.add(letter);
    });
  }

  void _onBackspace() {
    if (_decodeController.text.isNotEmpty) {
      setState(() {
        _decodeController.text = _decodeController.text.substring(
          0,
          _decodeController.text.length - 1,
        );
        if (_inputHistory.isNotEmpty) {
          _inputHistory.removeLast();
        }
      });
    }
  }

  void _onSpace() {
    setState(() {
      _decodeController.text += ' ';
      _inputHistory.add(' '); // Add space marker
    });
  }

  void _onClear() {
    setState(() {
      if (_isEncryptMode) {
        _inputController.clear();
      } else {
        _decodeController.clear();
        _inputHistory.clear();
      }
      _encodedText = '';
    });
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Copied to clipboard!',
            style: CyberTheme.body().copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.black.withOpacity(0.9),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // OLED black
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CyberTheme.neonCyan),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SANDI KOTAK 1',
          style: CyberTheme.headline().copyWith(
            fontSize: 18,
            color: CyberTheme.neonCyan,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Mode Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildModeButton('ENCODE', _isEncryptMode, () {
                        if (!_isEncryptMode) _toggleMode();
                      }),
                      const SizedBox(width: 16),
                      _buildModeButton('DECODE', !_isEncryptMode, () {
                        if (_isEncryptMode) _toggleMode();
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Reference Section (Cheat Sheet)
                  Text(
                    'Reference Chart',
                    style: CyberTheme.headline().copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  CyberContainer(child: _buildReferenceChart()),
                  const SizedBox(height: 24),

                  if (_isEncryptMode) ...[
                    // Encode Mode: Input Section
                    CyberContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Plaintext',
                                style: CyberTheme.headline().copyWith(
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: CyberTheme.neonCyan,
                                  size: 20,
                                ),
                                onPressed: _onClear,
                                tooltip: 'Clear',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _inputController,
                            style: GoogleFonts.courierPrime(
                              fontSize: 18,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter text to encode...',
                              hintStyle: GoogleFonts.courierPrime(
                                fontSize: 14,
                                color: CyberTheme.textSecondary,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Output Section
                    if (_encodedText.isNotEmpty) ...[
                      CyberContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Encoded Symbols',
                                  style: CyberTheme.headline().copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.copy,
                                    color: CyberTheme.neonCyan,
                                  ),
                                  onPressed: () =>
                                      _copyToClipboard(_encodedText),
                                  tooltip: 'Copy',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSymbolOutput(_encodedText),
                          ],
                        ),
                      ),
                    ],
                  ] else ...[
                    // Decode Mode: Decoded Text Display
                    CyberContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Decoded Text',
                                style: CyberTheme.headline().copyWith(
                                  fontSize: 16,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.copy,
                                      color: CyberTheme.neonCyan,
                                      size: 20,
                                    ),
                                    onPressed: _decodeController.text.isNotEmpty
                                        ? () => _copyToClipboard(
                                            _decodeController.text,
                                          )
                                        : null,
                                    tooltip: 'Copy',
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: CyberTheme.neonCyan,
                                      size: 20,
                                    ),
                                    onPressed: _onClear,
                                    tooltip: 'Clear',
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SelectableText(
                              _decodeController.text.isEmpty
                                  ? 'Use keyboard below to decode symbols...'
                                  : _decodeController.text,
                              style: GoogleFonts.courierPrime(
                                fontSize: 20,
                                color: _decodeController.text.isEmpty
                                    ? CyberTheme.textSecondary
                                    : Colors.white,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Decode Input History (Symbols tapped)
                    if (_inputHistory.isNotEmpty) ...[
                      CyberContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Input History',
                              style: CyberTheme.headline().copyWith(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _inputHistory.map((char) {
                                if (char == ' ') {
                                  return const SizedBox(width: 20, height: 40);
                                }
                                return SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CustomPaint(
                                    painter: Kotak1EncodedSymbolPainter(
                                      character: char,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ],
              ),
            ),
          ),

          // Decode Keyboard (only shown in decode mode)
          if (!_isEncryptMode) _buildDecodeKeyboard(),
        ],
      ),
    );
  }

  Widget _buildReferenceChart() {
    return Kotak1ReferenceBoard();
  }

  Widget _buildModeButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? CyberTheme.neonCyan : Colors.transparent,
          border: Border.all(color: CyberTheme.neonCyan, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.courierPrime(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.black : CyberTheme.neonCyan,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSymbolOutput(String text) {
    final characters = text.split('');
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: characters.map((char) {
        if (char == ' ') {
          return const SizedBox(width: 30);
        }
        return SizedBox(
          width: 60,
          height: 60,
          child: CustomPaint(
            painter: Kotak1EncodedSymbolPainter(character: char),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDecodeKeyboard() {
    // Generate A-Z alphabetically
    final letters = List.generate(
      26,
      (index) => String.fromCharCode(65 + index),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(
            color: CyberTheme.neonCyan.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Symbol keyboard grid (A-Z)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemCount: letters.length,
            itemBuilder: (context, index) {
              return Kotak1Key(
                character: letters[index],
                onTap: () => _onSymbolKeyTap(letters[index]),
              );
            },
          ),
          const SizedBox(height: 12),
          // Control buttons
          Row(
            children: [
              Expanded(
                child: _buildControlButton(
                  label: 'SPACE',
                  icon: Icons.space_bar,
                  onPressed: _onSpace,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildControlButton(
                  label: 'BACKSPACE',
                  icon: Icons.backspace,
                  onPressed: _onBackspace,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: CyberTheme.neonCyan, width: 1.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: CyberTheme.neonCyan, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.courierPrime(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: CyberTheme.neonCyan,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum GridType { ticTacToe, xGrid }

/// Painter for the reference grids
class GridReferencePainter extends CustomPainter {
  final GridType gridType;
  final bool hasDots;
  final List<String> letters;

  GridReferencePainter({
    required this.gridType,
    required this.hasDots,
    required this.letters,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFF8B6F47) // Dark Brown/Grey (Scout theme)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeJoin = StrokeJoin.miter;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    if (gridType == GridType.ticTacToe) {
      // Draw tic-tac-toe grid (3x3)
      final cellWidth = size.width / 3;
      final cellHeight = size.height / 3;

      // Vertical lines
      canvas.drawLine(
        Offset(cellWidth, 0),
        Offset(cellWidth, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(cellWidth * 2, 0),
        Offset(cellWidth * 2, size.height),
        paint,
      );

      // Horizontal lines
      canvas.drawLine(
        Offset(0, cellHeight),
        Offset(size.width, cellHeight),
        paint,
      );
      canvas.drawLine(
        Offset(0, cellHeight * 2),
        Offset(size.width, cellHeight * 2),
        paint,
      );

      // Draw letters and dots
      for (int i = 0; i < letters.length && i < 9; i++) {
        final row = i ~/ 3;
        final col = i % 3;
        final centerX = col * cellWidth + cellWidth / 2;
        final centerY = row * cellHeight + cellHeight / 2;

        // Draw letter
        textPainter.text = TextSpan(
          text: letters[i],
          style: GoogleFonts.courierPrime(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            centerX - textPainter.width / 2,
            centerY - textPainter.height / 2 - (hasDots ? 8 : 0),
          ),
        );

        // Draw dot if needed
        if (hasDots) {
          canvas.drawCircle(Offset(centerX, centerY + 12), 3.0, dotPaint);
        }
      }
    } else {
      // Draw X grid (2x2 with X in center)
      final cellWidth = size.width / 2;
      final cellHeight = size.height / 2;

      // Vertical line
      canvas.drawLine(
        Offset(cellWidth, 0),
        Offset(cellWidth, size.height),
        paint,
      );

      // Horizontal line
      canvas.drawLine(
        Offset(0, cellHeight),
        Offset(size.width, cellHeight),
        paint,
      );

      // Draw X in center
      final centerX = size.width / 2;
      final centerY = size.height / 2;
      final xSize = cellWidth * 0.6;
      canvas.drawLine(
        Offset(centerX - xSize / 2, centerY - xSize / 2),
        Offset(centerX + xSize / 2, centerY + xSize / 2),
        paint,
      );
      canvas.drawLine(
        Offset(centerX - xSize / 2, centerY + xSize / 2),
        Offset(centerX + xSize / 2, centerY - xSize / 2),
        paint,
      );

      // Draw letters and dots
      for (int i = 0; i < letters.length && i < 4; i++) {
        final row = i ~/ 2;
        final col = i % 2;
        final centerX = col * cellWidth + cellWidth / 2;
        final centerY = row * cellHeight + cellHeight / 2;

        // Draw letter
        textPainter.text = TextSpan(
          text: letters[i],
          style: GoogleFonts.courierPrime(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            centerX - textPainter.width / 2,
            centerY - textPainter.height / 2 - (hasDots ? 8 : 0),
          ),
        );

        // Draw dot if needed
        if (hasDots) {
          canvas.drawCircle(Offset(centerX, centerY + 12), 3.0, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter for individual Kotak 1 symbols
class Kotak1SymbolPainter extends CustomPainter {
  final String character;

  Kotak1SymbolPainter({required this.character});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CyberTheme.neonCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.miter
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = CyberTheme.neonCyan
      ..style = PaintingStyle.fill;

    final padding = 6.0;
    final width = size.width - padding * 2;
    final height = size.height - padding * 2;
    final offset = Offset(padding, padding);

    // Get symbol configuration for the character
    final config = _getSymbolConfig(character);

    if (config == null) return;

    if (config.gridType == GridType.ticTacToe) {
      // Tic-tac-toe grid: 3x3 cells
      final cellWidth = width / 3;
      final cellHeight = height / 3;
      final row = config.position ~/ 3;
      final col = config.position % 3;

      // Calculate cell boundaries
      final left = offset.dx + col * cellWidth;
      final top = offset.dy + row * cellHeight;
      final right = left + cellWidth;
      final bottom = top + cellHeight;

      // Draw borders based on cell position in 3x3 grid
      // Top-left (A): top + left
      // Top-center (B): top
      // Top-right (C): top + right
      // Middle-left (D): left
      // Center (E): none (or all - using none for simplicity)
      // Middle-right (F): right
      // Bottom-left (G): bottom + left
      // Bottom-center (H): bottom
      // Bottom-right (I): bottom + right

      if (row == 0) {
        // Top row: always draw top border
        canvas.drawLine(Offset(left, top), Offset(right, top), paint);
        if (col == 0) {
          // Top-left: also draw left border
          canvas.drawLine(Offset(left, top), Offset(left, bottom), paint);
        } else if (col == 2) {
          // Top-right: also draw right border
          canvas.drawLine(Offset(right, top), Offset(right, bottom), paint);
        }
      } else if (row == 1) {
        // Middle row
        if (col == 0) {
          // Middle-left: draw left border
          canvas.drawLine(Offset(left, top), Offset(left, bottom), paint);
        } else if (col == 2) {
          // Middle-right: draw right border
          canvas.drawLine(Offset(right, top), Offset(right, bottom), paint);
        }
        // Center (col == 1, row == 1): draw nothing
      } else {
        // Bottom row: always draw bottom border
        canvas.drawLine(Offset(left, bottom), Offset(right, bottom), paint);
        if (col == 0) {
          // Bottom-left: also draw left border
          canvas.drawLine(Offset(left, top), Offset(left, bottom), paint);
        } else if (col == 2) {
          // Bottom-right: also draw right border
          canvas.drawLine(Offset(right, top), Offset(right, bottom), paint);
        }
      }

      // Draw dot if needed (centered in cell)
      if (config.hasDot) {
        final centerX = left + cellWidth / 2;
        final centerY = top + cellHeight / 2;
        canvas.drawCircle(Offset(centerX, centerY), 4.0, dotPaint);
      }
    } else {
      // X grid: 4 triangular sections
      // Position 0: Left triangle (S-T)
      // Position 1: Top triangle (U-V)
      // Position 2: Right triangle (W-X)
      // Position 3: Bottom triangle (Y-Z)

      final centerX = size.width / 2;
      final centerY = size.height / 2;
      final triangleSize = width * 0.6;

      // Draw X in center (always for X grid)
      final xSize = triangleSize * 0.4;
      canvas.drawLine(
        Offset(centerX - xSize / 2, centerY - xSize / 2),
        Offset(centerX + xSize / 2, centerY + xSize / 2),
        paint,
      );
      canvas.drawLine(
        Offset(centerX - xSize / 2, centerY + xSize / 2),
        Offset(centerX + xSize / 2, centerY - xSize / 2),
        paint,
      );

      // Draw borders based on triangle position
      switch (config.position) {
        case 0: // Left triangle (S-T)
          // Left border
          canvas.drawLine(
            Offset(offset.dx, offset.dy),
            Offset(centerX, centerY),
            paint,
          );
          canvas.drawLine(
            Offset(centerX, centerY),
            Offset(offset.dx, offset.dy + height),
            paint,
          );
          break;
        case 1: // Top triangle (U-V)
          // Top border
          canvas.drawLine(
            Offset(offset.dx, offset.dy),
            Offset(centerX, centerY),
            paint,
          );
          canvas.drawLine(
            Offset(centerX, centerY),
            Offset(offset.dx + width, offset.dy),
            paint,
          );
          break;
        case 2: // Right triangle (W-X)
          // Right border
          canvas.drawLine(
            Offset(offset.dx + width, offset.dy),
            Offset(centerX, centerY),
            paint,
          );
          canvas.drawLine(
            Offset(centerX, centerY),
            Offset(offset.dx + width, offset.dy + height),
            paint,
          );
          break;
        case 3: // Bottom triangle (Y-Z)
          // Bottom border
          canvas.drawLine(
            Offset(offset.dx, offset.dy + height),
            Offset(centerX, centerY),
            paint,
          );
          canvas.drawLine(
            Offset(centerX, centerY),
            Offset(offset.dx + width, offset.dy + height),
            paint,
          );
          break;
      }

      // Draw dot if needed (centered in triangle)
      if (config.hasDot) {
        double dotX, dotY;
        switch (config.position) {
          case 0: // Left
            dotX = offset.dx + width * 0.2;
            dotY = centerY;
            break;
          case 1: // Top
            dotX = centerX;
            dotY = offset.dy + height * 0.2;
            break;
          case 2: // Right
            dotX = offset.dx + width * 0.8;
            dotY = centerY;
            break;
          case 3: // Bottom
            dotX = centerX;
            dotY = offset.dy + height * 0.8;
            break;
          default:
            dotX = centerX;
            dotY = centerY;
        }
        canvas.drawCircle(Offset(dotX, dotY), 4.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  SymbolConfig? _getSymbolConfig(String char) {
    final upperChar = char.toUpperCase();
    if (upperChar.length != 1) return null;

    final code = upperChar.codeUnitAt(0);

    // Mapping berdasarkan Pigpen Cipher yang benar:
    // Setiap pair memiliki posisi yang sama, huruf kedua memiliki dot
    // A-B (pos 0), C-D (pos 1), E-F (pos 2), G-H (pos 3), I-J (pos 4),
    // K-L (pos 5), M-N (pos 6), O-P (pos 7), Q-R (pos 8) - Grid 3x3
    // S-T (pos 0), U-V (pos 1), W-X (pos 2), Y-Z (pos 3) - Grid X

    if (code >= 65 && code <= 82) {
      // A-R: Grid 3x3
      final pairIndex = (code - 65) ~/ 2; // 0-8
      final isSecondLetter = (code - 65) % 2 == 1; // B, D, F, H, J, L, N, P, R
      return SymbolConfig(
        gridType: GridType.ticTacToe,
        position: pairIndex,
        hasDot: isSecondLetter,
      );
    }

    if (code >= 83 && code <= 90) {
      // S-Z: Grid X
      final pairIndex = (code - 83) ~/ 2; // 0-3
      final isSecondLetter = (code - 83) % 2 == 1; // T, V, X, Z
      return SymbolConfig(
        gridType: GridType.xGrid,
        position: pairIndex,
        hasDot: isSecondLetter,
      );
    }

    return null;
  }
}

class SymbolConfig {
  final GridType gridType;
  final int position;
  final bool hasDot;

  SymbolConfig({
    required this.gridType,
    required this.position,
    required this.hasDot,
  });
}

/// Painter for reference chart symbols (exact match to image)
class Kotak1ReferenceSymbolPainter extends CustomPainter {
  final String character;

  Kotak1ReferenceSymbolPainter({required this.character});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.miter
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final symbolSize = size.width * 0.7;

    final char = character.toUpperCase();
    if (char.isEmpty) return;

    switch (char) {
      case 'A':
        // L-shape like '7' (vertical right, horizontal top-left)
        canvas.drawLine(
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX - symbolSize / 2, centerY - symbolSize / 2),
          paint,
        );
        break;
      case 'B':
        // Same as A with dot above left
        canvas.drawLine(
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX - symbolSize / 2, centerY - symbolSize / 2),
          paint,
        );
        canvas.drawCircle(
          Offset(centerX - symbolSize / 2, centerY - symbolSize / 2 - 4),
          2.5,
          dotPaint,
        );
        break;
      case 'C':
        // U-shape open at top
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        break;
      case 'D':
        // U-shape like C with dot inside top-left
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawCircle(
          Offset(centerX - symbolSize / 2 + 4, centerY - symbolSize / 2 + 4),
          2.5,
          dotPaint,
        );
        break;
      case 'E':
        // L-shape like 'L' (vertical left, horizontal top-right)
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
          paint,
        );
        break;
      case 'F':
        // Same as E with dot above right
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
          paint,
        );
        canvas.drawCircle(
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2 - 4),
          2.5,
          dotPaint,
        );
        break;
      case 'G':
        // U-shape open at bottom (inverted U)
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
          paint,
        );
        break;
      case 'H':
        // Square outline with top-right corner missing, dot in top-left
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY),
          paint,
        );
        canvas.drawCircle(
          Offset(centerX - symbolSize / 2 + 4, centerY - symbolSize / 2 + 4),
          2.5,
          dotPaint,
        );
        break;
      case 'I':
        // Complete square outline
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(centerX, centerY),
            width: symbolSize,
            height: symbolSize,
          ),
          paint,
        );
        break;
      case 'J':
        // Complete square outline with dot in top-left
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(centerX, centerY),
            width: symbolSize,
            height: symbolSize,
          ),
          paint,
        );
        canvas.drawCircle(
          Offset(centerX - symbolSize / 2 + 4, centerY - symbolSize / 2 + 4),
          2.5,
          dotPaint,
        );
        break;
      case 'K':
        // Square outline with top-left corner missing
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY),
          Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY),
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
          paint,
        );
        break;
      case 'L':
        // Square outline like K with dot in top-right
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY),
          Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY),
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
          paint,
        );
        canvas.drawCircle(
          Offset(centerX + symbolSize / 2 - 4, centerY - symbolSize / 2 + 4),
          2.5,
          dotPaint,
        );
        break;
      case 'M':
        // L-shape like 'J' without curve (horizontal top, vertical right bottom)
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        break;
      case 'N':
        // Same as M with dot below right
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawCircle(
          Offset(centerX + symbolSize / 2 - 4, centerY + symbolSize / 2 + 4),
          2.5,
          dotPaint,
        );
        break;
      case 'O':
        // U-shape open at top with dot in top-right
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawCircle(
          Offset(centerX + symbolSize / 2 - 4, centerY - symbolSize / 2 + 4),
          2.5,
          dotPaint,
        );
        break;
      case 'P':
        // L-shape with vertical left, horizontal bottom-right
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        break;
      case 'Q':
        // Same as P with dot below left
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawCircle(
          Offset(centerX - symbolSize / 2 + 4, centerY + symbolSize / 2 + 4),
          2.5,
          dotPaint,
        );
        break;
      case 'R':
        // L-shape with vertical right, horizontal bottom-left
        canvas.drawLine(
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        break;
      case 'S':
        // Same as R with dot below left
        canvas.drawLine(
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawCircle(
          Offset(centerX - symbolSize / 2 + 4, centerY + symbolSize / 2 + 4),
          2.5,
          dotPaint,
        );
        break;
      case 'T':
        // Chevron pointing right (>) with dot in center
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX, centerY),
          paint,
        );
        canvas.drawLine(
          Offset(centerX, centerY),
          Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX, centerY),
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX, centerY),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawCircle(Offset(centerX, centerY), 2.5, dotPaint);
        break;
      case 'U':
        // Chevron pointing down (V)
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX, centerY + symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
          paint,
        );
        break;
      case 'V':
        // Chevron pointing down (V) with dot in center
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX, centerY + symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
          paint,
        );
        canvas.drawCircle(Offset(centerX, centerY), 2.5, dotPaint);
        break;
      case 'W':
        // Chevron pointing left (<)
        canvas.drawLine(
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX, centerY),
          paint,
        );
        canvas.drawLine(
          Offset(centerX, centerY),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX, centerY),
          Offset(centerX - symbolSize / 2, centerY - symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX, centerY),
          Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        break;
      case 'X':
        // Chevron pointing left (<) with dot in center
        canvas.drawLine(
          Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
          Offset(centerX, centerY),
          paint,
        );
        canvas.drawLine(
          Offset(centerX, centerY),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX, centerY),
          Offset(centerX - symbolSize / 2, centerY - symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX, centerY),
          Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawCircle(Offset(centerX, centerY), 2.5, dotPaint);
        break;
      case 'Y':
        // Chevron pointing up (^)
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
          Offset(centerX, centerY - symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX, centerY - symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        break;
      case 'Z':
        // Chevron pointing up (^) with dot in center
        canvas.drawLine(
          Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
          Offset(centerX, centerY - symbolSize / 2),
          paint,
        );
        canvas.drawLine(
          Offset(centerX, centerY - symbolSize / 2),
          Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
          paint,
        );
        canvas.drawCircle(Offset(centerX, centerY), 2.5, dotPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter for 3x3 Grid with letters AB, CD, EF, GH, IJ, KL, MN, OP, QR
class Grid3x3Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeJoin = StrokeJoin.miter;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final cellWidth = size.width / 3;
    final cellHeight = size.height / 3;

    // Draw grid lines
    // Vertical lines
    canvas.drawLine(
      Offset(cellWidth, 0),
      Offset(cellWidth, size.height),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cellWidth * 2, 0),
      Offset(cellWidth * 2, size.height),
      gridPaint,
    );
    // Horizontal lines
    canvas.drawLine(
      Offset(0, cellHeight),
      Offset(size.width, cellHeight),
      gridPaint,
    );
    canvas.drawLine(
      Offset(0, cellHeight * 2),
      Offset(size.width, cellHeight * 2),
      gridPaint,
    );

    // Draw letters in each cell
    final letters = [
      ['A', 'B'],
      ['C', 'D'],
      ['E', 'F'],
      ['G', 'H'],
      ['I', 'J'],
      ['K', 'L'],
      ['M', 'N'],
      ['O', 'P'],
      ['Q', 'R'],
    ];

    for (int i = 0; i < 9; i++) {
      final row = i ~/ 3;
      final col = i % 3;
      final centerX = col * cellWidth + cellWidth / 2;
      final centerY = row * cellHeight + cellHeight / 2;

      // Draw two letters side by side
      for (int j = 0; j < 2; j++) {
        final letter = letters[i][j];
        final offsetX = j == 0 ? -8.0 : 8.0;

        textPainter.text = TextSpan(
          text: letter,
          style: GoogleFonts.courierPrime(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            centerX - textPainter.width / 2 + offsetX,
            centerY - textPainter.height / 2,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter for X Grid with letters ST, UV, WX, YZ
class GridXPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeJoin = StrokeJoin.miter;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final xSize = size.width * 0.6;

    // Draw X (diagonal lines)
    canvas.drawLine(
      Offset(centerX - xSize / 2, centerY - xSize / 2),
      Offset(centerX + xSize / 2, centerY + xSize / 2),
      gridPaint,
    );
    canvas.drawLine(
      Offset(centerX - xSize / 2, centerY + xSize / 2),
      Offset(centerX + xSize / 2, centerY - xSize / 2),
      gridPaint,
    );

    // Draw letters in each section
    // Top: UV
    textPainter.text = TextSpan(
      text: 'U',
      style: GoogleFonts.courierPrime(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(centerX - textPainter.width / 2 - 8, centerY - xSize / 2 - 20),
    );

    textPainter.text = TextSpan(
      text: 'V',
      style: GoogleFonts.courierPrime(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(centerX - textPainter.width / 2 + 8, centerY - xSize / 2 - 20),
    );

    // Left: ST
    textPainter.text = TextSpan(
      text: 'S',
      style: GoogleFonts.courierPrime(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(centerX - xSize / 2 - 20, centerY - textPainter.height / 2 - 8),
    );

    textPainter.text = TextSpan(
      text: 'T',
      style: GoogleFonts.courierPrime(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(centerX - xSize / 2 - 20, centerY - textPainter.height / 2 + 8),
    );

    // Right: WX
    textPainter.text = TextSpan(
      text: 'W',
      style: GoogleFonts.courierPrime(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(centerX + xSize / 2 + 20, centerY - textPainter.height / 2 - 8),
    );

    textPainter.text = TextSpan(
      text: 'X',
      style: GoogleFonts.courierPrime(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(centerX + xSize / 2 + 20, centerY - textPainter.height / 2 + 8),
    );

    // Bottom: YZ
    textPainter.text = TextSpan(
      text: 'Y',
      style: GoogleFonts.courierPrime(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(centerX - textPainter.width / 2 - 8, centerY + xSize / 2 + 20),
    );

    textPainter.text = TextSpan(
      text: 'Z',
      style: GoogleFonts.courierPrime(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(centerX - textPainter.width / 2 + 8, centerY + xSize / 2 + 20),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter for example symbols (B, P, S)
class ExampleSymbolPainter extends CustomPainter {
  final String letter;
  final int gridPosition; // Position in grid (0-8 for 3x3, 0-3 for X)
  final int letterIndex; // 0 for first letter, 1 for second letter

  ExampleSymbolPainter({
    required this.letter,
    required this.gridPosition,
    required this.letterIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.miter
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final symbolSize = size.width * 0.6;

    if (letter == 'B') {
      // B: L-shape (top-right corner) with dot
      // Vertical line on right
      canvas.drawLine(
        Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
        Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
        paint,
      );
      // Horizontal line on top
      canvas.drawLine(
        Offset(centerX - symbolSize / 2, centerY - symbolSize / 2),
        Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
        paint,
      );
      // Dot inside
      canvas.drawCircle(Offset(centerX, centerY), 3.0, dotPaint);
    } else if (letter == 'P') {
      // P: Inverted L-shape (bottom-left corner) with dot
      // Vertical line on left
      canvas.drawLine(
        Offset(centerX - symbolSize / 2, centerY - symbolSize / 2),
        Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
        paint,
      );
      // Horizontal line on bottom
      canvas.drawLine(
        Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
        Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
        paint,
      );
      // Dot inside
      canvas.drawCircle(Offset(centerX, centerY), 3.0, dotPaint);
    } else if (letter == 'S') {
      // S: Chevron pointing right (>) without dot
      canvas.drawLine(
        Offset(centerX - symbolSize / 2, centerY - symbolSize / 2),
        Offset(centerX, centerY),
        paint,
      );
      canvas.drawLine(
        Offset(centerX, centerY),
        Offset(centerX - symbolSize / 2, centerY + symbolSize / 2),
        paint,
      );
      canvas.drawLine(
        Offset(centerX, centerY),
        Offset(centerX + symbolSize / 2, centerY - symbolSize / 2),
        paint,
      );
      canvas.drawLine(
        Offset(centerX, centerY),
        Offset(centerX + symbolSize / 2, centerY + symbolSize / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Kotak1ReferenceBoard - Visual reference board for Sandi Kotak 1
/// Displays the 3x3 grid and X grid with letter pairs
class Kotak1ReferenceBoard extends StatelessWidget {
  const Kotak1ReferenceBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.yellow, width: 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use side-by-side layout on larger screens, stacked on smaller
          if (constraints.maxWidth > 600) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildTicTacToeGrid()),
                const SizedBox(width: 24),
                Expanded(child: _buildXGrid()),
              ],
            );
          } else {
            return Column(
              children: [
                _buildTicTacToeGrid(),
                const SizedBox(height: 24),
                _buildXGrid(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildTicTacToeGrid() {
    return Column(
      children: [
        Text(
          'Grid 3x3',
          style: GoogleFonts.courierPrime(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.yellow,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
          child: Stack(
            children: [
              // Draw grid lines
              CustomPaint(
                size: const Size(double.infinity, 300),
                painter: TicTacToeGridPainter(),
              ),
              // Overlay text
              _buildTicTacToeText(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTicTacToeText() {
    final letters = [
      ['A', 'B'],
      ['C', 'D'],
      ['E', 'F'],
      ['G', 'H'],
      ['I', 'J'],
      ['K', 'L'],
      ['M', 'N'],
      ['O', 'P'],
      ['Q', 'R'],
    ];

    return Positioned.fill(
      child: Column(
        children: List.generate(3, (row) {
          return Expanded(
            child: Row(
              children: List.generate(3, (col) {
                final index = row * 3 + col;
                final pair = letters[index];
                return Expanded(
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // First letter
                        Text(
                          pair[0],
                          style: GoogleFonts.courierPrime(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Second letter with dot above
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              pair[1],
                              style: GoogleFonts.courierPrime(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Positioned(
                              top: -8,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.yellow,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildXGrid() {
    return Column(
      children: [
        Text(
          'Grid X',
          style: GoogleFonts.courierPrime(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.yellow,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
          child: Stack(
            children: [
              // Draw X lines
              CustomPaint(
                size: const Size(double.infinity, 300),
                painter: XGridPainter(),
              ),
              // Overlay text
              _buildXGridText(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildXGridText() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Top: UV
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'U',
                    style: GoogleFonts.courierPrime(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        'V',
                        style: GoogleFonts.courierPrime(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        top: -8,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.yellow,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Left: ST
          Positioned(
            left: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'S',
                    style: GoogleFonts.courierPrime(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        'T',
                        style: GoogleFonts.courierPrime(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        top: -8,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.yellow,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Right: WX
          Positioned(
            right: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'W',
                    style: GoogleFonts.courierPrime(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        'X',
                        style: GoogleFonts.courierPrime(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        top: -8,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.yellow,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Bottom: YZ
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Y',
                    style: GoogleFonts.courierPrime(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        'Z',
                        style: GoogleFonts.courierPrime(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        top: -8,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.yellow,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter for 3x3 Tic-Tac-Toe Grid
class TicTacToeGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeJoin = StrokeJoin.miter;

    final cellWidth = size.width / 3;
    final cellHeight = size.height / 3;

    // Draw vertical lines
    canvas.drawLine(
      Offset(cellWidth, 0),
      Offset(cellWidth, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(cellWidth * 2, 0),
      Offset(cellWidth * 2, size.height),
      paint,
    );

    // Draw horizontal lines
    canvas.drawLine(
      Offset(0, cellHeight),
      Offset(size.width, cellHeight),
      paint,
    );
    canvas.drawLine(
      Offset(0, cellHeight * 2),
      Offset(size.width, cellHeight * 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter for X Grid (diagonal lines)
class XGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeJoin = StrokeJoin.miter;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final diagonalSize = size.width * 0.7;

    // Draw diagonal lines forming X
    canvas.drawLine(
      Offset(centerX - diagonalSize / 2, centerY - diagonalSize / 2),
      Offset(centerX + diagonalSize / 2, centerY + diagonalSize / 2),
      paint,
    );
    canvas.drawLine(
      Offset(centerX - diagonalSize / 2, centerY + diagonalSize / 2),
      Offset(centerX + diagonalSize / 2, centerY - diagonalSize / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter for encoded symbols in output (matches reference chart exactly)
/// Follows standard Pigpen Cipher 1 rules: # Grid (A-R) and X Grid (S-Z)
class Kotak1EncodedSymbolPainter extends CustomPainter {
  final String character;

  Kotak1EncodedSymbolPainter({required this.character});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final symbolSize = size.width * 0.7;

    final char = character.toUpperCase();
    if (char.isEmpty) return;

    // Calculate boundaries
    final left = centerX - symbolSize / 2;
    final right = centerX + symbolSize / 2;
    final top = centerY - symbolSize / 2;
    final bottom = centerY + symbolSize / 2;

    // Check if second letter of pair (has dot)
    final isSecondLetter = _isSecondLetterOfPair(char);

    switch (char) {
      // # Grid: A-R
      case 'A':
      case 'B':
        // Pair (A, B): Shape `_|` (Bottom & Right border)
        canvas.drawLine(
          Offset(right, bottom),
          Offset(left, bottom),
          paint,
        ); // Bottom
        canvas.drawLine(
          Offset(right, top),
          Offset(right, bottom),
          paint,
        ); // Right
        if (isSecondLetter) {
          canvas.drawCircle(Offset(centerX, centerY), 4.0, dotPaint);
        }
        break;
      case 'C':
      case 'D':
        // Pair (C, D): Shape `|_|` (Bottom, Left, Right border)
        canvas.drawLine(
          Offset(left, bottom),
          Offset(right, bottom),
          paint,
        ); // Bottom
        canvas.drawLine(Offset(left, top), Offset(left, bottom), paint); // Left
        canvas.drawLine(
          Offset(right, top),
          Offset(right, bottom),
          paint,
        ); // Right
        if (isSecondLetter) {
          canvas.drawCircle(Offset(centerX, centerY), 4.0, dotPaint);
        }
        break;
      case 'E':
      case 'F':
        // Pair (E, F): Shape `|_` (Bottom & Left border)
        canvas.drawLine(
          Offset(left, bottom),
          Offset(right, bottom),
          paint,
        ); // Bottom
        canvas.drawLine(Offset(left, top), Offset(left, bottom), paint); // Left
        if (isSecondLetter) {
          canvas.drawCircle(Offset(centerX, centerY), 4.0, dotPaint);
        }
        break;
      case 'G':
      case 'H':
        // Pair (G, H): Square missing left (Top, Bottom, Right border)
        canvas.drawLine(Offset(left, top), Offset(right, top), paint); // Top
        canvas.drawLine(
          Offset(left, bottom),
          Offset(right, bottom),
          paint,
        ); // Bottom
        canvas.drawLine(
          Offset(right, top),
          Offset(right, bottom),
          paint,
        ); // Right
        if (isSecondLetter) {
          canvas.drawCircle(Offset(centerX, centerY), 4.0, dotPaint);
        }
        break;
      case 'I':
      case 'J':
        // Pair (I, J): Complete box (All 4 borders)
        canvas.drawRect(
          Rect.fromLTWH(left, top, symbolSize, symbolSize),
          paint,
        );
        if (isSecondLetter) {
          canvas.drawCircle(Offset(centerX, centerY), 4.0, dotPaint);
        }
        break;
      case 'K':
      case 'L':
        // Pair (K, L): Square missing right (Top, Bottom, Left border)
        canvas.drawLine(Offset(left, top), Offset(right, top), paint); // Top
        canvas.drawLine(
          Offset(left, bottom),
          Offset(right, bottom),
          paint,
        ); // Bottom
        canvas.drawLine(Offset(left, top), Offset(left, bottom), paint); // Left
        if (isSecondLetter) {
          canvas.drawCircle(Offset(centerX, centerY), 4.0, dotPaint);
        }
        break;
      case 'M':
      case 'N':
        // Pair (M, N): Shape `7` (Top & Right border)
        canvas.drawLine(Offset(left, top), Offset(right, top), paint); // Top
        canvas.drawLine(
          Offset(right, top),
          Offset(right, bottom),
          paint,
        ); // Right
        if (isSecondLetter) {
          canvas.drawCircle(Offset(centerX, centerY), 4.0, dotPaint);
        }
        break;
      case 'O':
      case 'P':
        // Pair (O, P): Square missing bottom (Top, Left, Right border)
        canvas.drawLine(Offset(left, top), Offset(right, top), paint); // Top
        canvas.drawLine(Offset(left, top), Offset(left, bottom), paint); // Left
        canvas.drawLine(
          Offset(right, top),
          Offset(right, bottom),
          paint,
        ); // Right
        if (isSecondLetter) {
          canvas.drawCircle(Offset(centerX, centerY), 4.0, dotPaint);
        }
        break;
      case 'Q':
      case 'R':
        // Pair (Q, R): Shape `Γ` (Top & Left border)
        canvas.drawLine(Offset(left, top), Offset(right, top), paint); // Top
        canvas.drawLine(Offset(left, top), Offset(left, bottom), paint); // Left
        if (isSecondLetter) {
          canvas.drawCircle(Offset(centerX, centerY), 4.0, dotPaint);
        }
        break;
      // X Grid: S-Z
      case 'S':
      case 'T':
        // Pair (S, T): V-shape opening Top (diagonal lines from bottom-center to top-left and top-right)
        canvas.drawLine(Offset(centerX, bottom), Offset(left, top), paint);
        canvas.drawLine(Offset(centerX, bottom), Offset(right, top), paint);
        if (isSecondLetter) {
          canvas.drawCircle(Offset(centerX, centerY), 4.0, dotPaint);
        }
        break;
      case 'U':
      case 'V':
        // Pair (U, V): > shape opening Left (diagonal lines from right-center to top-left and bottom-left)
        canvas.drawLine(Offset(right, centerY), Offset(left, top), paint);
        canvas.drawLine(Offset(right, centerY), Offset(left, bottom), paint);
        if (isSecondLetter) {
          canvas.drawCircle(Offset(centerX, centerY), 4.0, dotPaint);
        }
        break;
      case 'W':
      case 'X':
        // Pair (W, X): < shape opening Right (diagonal lines from left-center to top-right and bottom-right)
        canvas.drawLine(Offset(left, centerY), Offset(right, top), paint);
        canvas.drawLine(Offset(left, centerY), Offset(right, bottom), paint);
        if (isSecondLetter) {
          canvas.drawCircle(Offset(centerX, centerY), 4.0, dotPaint);
        }
        break;
      case 'Y':
      case 'Z':
        // Pair (Y, Z): ^-shape opening Bottom (diagonal lines from top-center to bottom-left and bottom-right)
        canvas.drawLine(Offset(centerX, top), Offset(left, bottom), paint);
        canvas.drawLine(Offset(centerX, top), Offset(right, bottom), paint);
        if (isSecondLetter) {
          canvas.drawCircle(Offset(centerX, centerY), 4.0, dotPaint);
        }
        break;
    }
  }

  /// Check if character is the second letter of its pair (has dot)
  bool _isSecondLetterOfPair(String char) {
    final code = char.codeUnitAt(0);
    // B, D, F, H, J, L, N, P, R, T, V, X, Z are second letters
    return code == 66 ||
        code == 68 ||
        code == 70 ||
        code == 72 ||
        code == 74 ||
        code == 76 ||
        code == 78 ||
        code == 80 ||
        code == 82 ||
        code == 84 ||
        code == 86 ||
        code == 88 ||
        code == 90;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom Key Widget for Sandi Kotak 1 Keyboard
/// Displays a symbol key that can be tapped to decode
class Kotak1Key extends StatelessWidget {
  final String character;
  final VoidCallback onTap;

  const Kotak1Key({super.key, required this.character, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: CyberTheme.neonCyan, width: 1.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: CustomPaint(
          painter: Kotak1EncodedSymbolPainter(character: character),
        ),
      ),
    );
  }
}
