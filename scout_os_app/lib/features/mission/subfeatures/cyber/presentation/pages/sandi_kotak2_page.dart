import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/theme/cyber_theme.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/widgets/cyber_container.dart';

/// Sandi Kotak 2 (Pigpen Cipher Variant 2) Tool
///
/// Uses a 3x3 Tic-Tac-Toe grid where each box holds 3 letters.
/// Dot logic: 1st letter (no dot), 2nd letter (1 centered dot), 3rd letter (2 horizontal dots).
class SandiKotak2Page extends StatefulWidget {
  final SandiModel sandi;

  const SandiKotak2Page({super.key, required this.sandi});

  @override
  State<SandiKotak2Page> createState() => _SandiKotak2PageState();
}

class _SandiKotak2PageState extends State<SandiKotak2Page>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _encodeController = TextEditingController();
  final TextEditingController _decodeController = TextEditingController();
  String _encodedText = '';
  List<String> _inputHistory = []; // Track symbols tapped in decode mode

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _encodeController.addListener(_onEncodeInputChanged);
    _decodeController.addListener(_onDecodeChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _encodeController.dispose();
    _decodeController.dispose();
    super.dispose();
  }

  void _onEncodeInputChanged() {
    setState(() {
      _encodedText = _encodeController.text.toUpperCase();
    });
  }

  void _onDecodeChanged() {
    setState(() {});
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
      if (_tabController.index == 0) {
        _encodeController.clear();
        _encodedText = '';
      } else {
        _decodeController.clear();
        _inputHistory.clear();
      }
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard'),
        duration: const Duration(seconds: 1),
        backgroundColor: CyberTheme.neonCyan.withOpacity(0.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.sandi.name.toUpperCase(),
          style: CyberTheme.headline().copyWith(
            fontSize: 18,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: CyberTheme.neonCyan,
          labelColor: CyberTheme.neonCyan,
          unselectedLabelColor: CyberTheme.textSecondary,
          labelStyle: GoogleFonts.courierPrime(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          tabs: const [
            Tab(text: 'ENCODE'),
            Tab(text: 'DECODE'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildEncodeTab(), _buildDecodeTab()],
      ),
    );
  }

  Widget _buildEncodeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual Reference (3x3 Grid)
          CyberContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Visual Reference',
                      style: CyberTheme.headline().copyWith(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildReferenceGrid(),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Input Section
          CyberContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Plaintext',
                      style: CyberTheme.headline().copyWith(fontSize: 16),
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
                  controller: _encodeController,
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
                        style: CyberTheme.headline().copyWith(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.copy,
                          color: CyberTheme.neonCyan,
                        ),
                        onPressed: () => _copyToClipboard(_encodedText),
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
        ],
      ),
    );
  }

  Widget _buildDecodeTab() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Decoded Text Display
                CyberContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Decoded Text',
                            style: CyberTheme.headline().copyWith(fontSize: 16),
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

                // Input History (Symbols tapped)
                if (_inputHistory.isNotEmpty) ...[
                  CyberContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Input History',
                          style: CyberTheme.headline().copyWith(fontSize: 16),
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
                                painter: Kotak2SymbolPainter(character: char),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Decode Keyboard (Bottom)
        _buildDecodeKeyboard(),
      ],
    );
  }

  Widget _buildReferenceGrid() {
    return Kotak2ReferenceChart();
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
          child: CustomPaint(painter: Kotak2SymbolPainter(character: char)),
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
              return Kotak2Key(
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

/// Custom Key Widget for Sandi Kotak 2 Keyboard
/// Displays a symbol key that can be tapped to decode
class Kotak2Key extends StatelessWidget {
  final String character;
  final VoidCallback onTap;

  const Kotak2Key({super.key, required this.character, required this.onTap});

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
        child: CustomPaint(painter: Kotak2SymbolPainter(character: character)),
      ),
    );
  }
}

/// Shape IDs for Sandi Kotak 2
enum Kotak2Shape {
  bottomRight, // Group 1: A, B, C
  bottomLeftRight, // Group 2: D, E, F
  bottomLeft, // Group 3: G, H, I
  topBottomRight, // Group 4: J, K, L
  box, // Group 5: M, N, O
  topBottomLeft, // Group 6: P, Q, R
  topRight, // Group 7: S, T, U
  topLeftRight, // Group 8: V, W, X
  topLeft, // Group 9: Y, Z
}

/// Helper function to map character to ShapeID and DotCount
/// Returns (ShapeID, DotCount) based on the "Group of 3" rule
(Kotak2Shape shape, int dotCount) _getKotak2Mapping(String char) {
  final code = char.codeUnitAt(0);
  final letterIndex = code - 65; // A=0, B=1, ..., Z=25

  // Determine group (0-8) and position in group (0-2)
  final groupIndex = letterIndex ~/ 3; // 0-8
  final position = letterIndex % 3; // 0, 1, or 2

  // Map group to shape
  Kotak2Shape shape;
  switch (groupIndex) {
    case 0: // A, B, C
      shape = Kotak2Shape.bottomRight;
      break;
    case 1: // D, E, F
      shape = Kotak2Shape.bottomLeftRight;
      break;
    case 2: // G, H, I
      shape = Kotak2Shape.bottomLeft;
      break;
    case 3: // J, K, L
      shape = Kotak2Shape.topBottomRight;
      break;
    case 4: // M, N, O
      shape = Kotak2Shape.box;
      break;
    case 5: // P, Q, R
      shape = Kotak2Shape.topBottomLeft;
      break;
    case 6: // S, T, U
      shape = Kotak2Shape.topRight;
      break;
    case 7: // V, W, X
      shape = Kotak2Shape.topLeftRight;
      break;
    case 8: // Y, Z
      shape = Kotak2Shape.topLeft;
      break;
    default:
      shape = Kotak2Shape.box;
  }

  // Dot count based on position: 0=0 dots, 1=1 dot, 2=2 dots
  return (shape, position);
}

/// Painter for Sandi Kotak 2 symbols
/// Draws letters A-Z based on 3x3 grid with 3 letters per box
/// Perfect symmetry with yellow dots
class Kotak2SymbolPainter extends CustomPainter {
  final String character;

  Kotak2SymbolPainter({required this.character});

  @override
  void paint(Canvas canvas, Size size) {
    final char = character.toUpperCase();
    if (char.length != 1 ||
        char.codeUnitAt(0) < 65 ||
        char.codeUnitAt(0) > 90) {
      return;
    }

    // Get shape and dot count from mapping
    final (shape, dotCount) = _getKotak2Mapping(char);

    // Use larger stroke width for better visibility, especially in decode keyboard
    final strokeWidth = size.width < 50 ? 6.0 : 5.0;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.miter;

    final dotPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    // Calculate cell boundaries using dynamic sizing
    // Use 80% of available space for the shape, centered
    final boxSize = size.width * 0.8;
    final left = (size.width - boxSize) / 2;
    final top = (size.height - boxSize) / 2;
    final right = left + boxSize;
    final bottom = top + boxSize;

    // Draw shape based on ShapeID
    // All coordinates use dynamic sizing for perfect symmetry
    switch (shape) {
      case Kotak2Shape.bottomRight:
        // Group 1: A, B, C - Draw Bottom & Right borders
        canvas.drawLine(Offset(left, bottom), Offset(right, bottom), paint);
        canvas.drawLine(Offset(right, top), Offset(right, bottom), paint);
        break;
      case Kotak2Shape.bottomLeftRight:
        // Group 2: D, E, F - Draw Bottom, Left, Right borders
        canvas.drawLine(Offset(left, bottom), Offset(right, bottom), paint);
        canvas.drawLine(Offset(left, top), Offset(left, bottom), paint);
        canvas.drawLine(Offset(right, top), Offset(right, bottom), paint);
        break;
      case Kotak2Shape.bottomLeft:
        // Group 3: G, H, I - Draw Bottom & Left borders
        canvas.drawLine(Offset(left, bottom), Offset(right, bottom), paint);
        canvas.drawLine(Offset(left, top), Offset(left, bottom), paint);
        break;
      case Kotak2Shape.topBottomRight:
        // Group 4: J, K, L - Draw Top, Bottom, Right borders
        canvas.drawLine(Offset(left, top), Offset(right, top), paint);
        canvas.drawLine(Offset(left, bottom), Offset(right, bottom), paint);
        canvas.drawLine(Offset(right, top), Offset(right, bottom), paint);
        break;
      case Kotak2Shape.box:
        // Group 5: M, N, O - Draw All 4 borders
        canvas.drawLine(Offset(left, top), Offset(right, top), paint);
        canvas.drawLine(Offset(left, bottom), Offset(right, bottom), paint);
        canvas.drawLine(Offset(left, top), Offset(left, bottom), paint);
        canvas.drawLine(Offset(right, top), Offset(right, bottom), paint);
        break;
      case Kotak2Shape.topBottomLeft:
        // Group 6: P, Q, R - Draw Top, Bottom, Left borders
        canvas.drawLine(Offset(left, top), Offset(right, top), paint);
        canvas.drawLine(Offset(left, bottom), Offset(right, bottom), paint);
        canvas.drawLine(Offset(left, top), Offset(left, bottom), paint);
        break;
      case Kotak2Shape.topRight:
        // Group 7: S, T, U - Draw Top & Right borders
        canvas.drawLine(Offset(left, top), Offset(right, top), paint);
        canvas.drawLine(Offset(right, top), Offset(right, bottom), paint);
        break;
      case Kotak2Shape.topLeftRight:
        // Group 8: V, W, X - Draw Top, Left, Right borders
        canvas.drawLine(Offset(left, top), Offset(right, top), paint);
        canvas.drawLine(Offset(left, top), Offset(left, bottom), paint);
        canvas.drawLine(Offset(right, top), Offset(right, bottom), paint);
        break;
      case Kotak2Shape.topLeft:
        // Group 9: Y, Z - Draw Top & Left borders
        canvas.drawLine(Offset(left, top), Offset(right, top), paint);
        canvas.drawLine(Offset(left, top), Offset(left, bottom), paint);
        break;
    }

    // Draw dots with perfect symmetry using canvas center
    // Dot count: 0=no dots, 1=1 centered dot, 2=2 horizontal dots
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    if (dotCount == 1) {
      // 1 Centered Dot (B, E, H, K, N, Q, T, W, Z)
      canvas.drawCircle(Offset(centerX, centerY), 5.0, dotPaint);
    } else if (dotCount == 2) {
      // 2 Horizontal Dots (C, F, I, L, O, R, U, X)
      // Dynamic spacing: gap = size.width * 0.2
      final gap = size.width * 0.2;
      canvas.drawCircle(Offset(centerX - gap, centerY), 5.0, dotPaint);
      canvas.drawCircle(Offset(centerX + gap, centerY), 5.0, dotPaint);
    }
    // dotCount == 0: No dots (A, D, G, J, M, P, S, V, Y)
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Visual Reference Chart for Sandi Kotak 2
/// Displays 3x3 grid with letters and dots (matching the reference image)
class Kotak2ReferenceChart extends StatelessWidget {
  const Kotak2ReferenceChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      decoration: BoxDecoration(
        color: Colors.black, // Black background matching cyber theme
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CyberTheme.neonCyan.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Draw grid lines (3x3)
          LayoutBuilder(
            builder: (context, constraints) {
              return CustomPaint(
                painter: Kotak2ReferenceGridPainter(),
                size: Size(constraints.maxWidth, constraints.maxHeight),
              );
            },
          ),
          // Content: 3x3 grid cells
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Top Row
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildCell(['A', 'B', 'C'])), // Cell 1
                      Expanded(child: _buildCell(['D', 'E', 'F'])), // Cell 2
                      Expanded(child: _buildCell(['G', 'H', 'I'])), // Cell 3
                    ],
                  ),
                ),
                // Middle Row
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildCell(['J', 'K', 'L'])), // Cell 4
                      Expanded(child: _buildCell(['M', 'N', 'O'])), // Cell 5
                      Expanded(child: _buildCell(['P', 'Q', 'R'])), // Cell 6
                    ],
                  ),
                ),
                // Bottom Row
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildCell(['S', 'T', 'U'])), // Cell 7
                      Expanded(child: _buildCell(['V', 'W', 'X'])), // Cell 8
                      Expanded(
                        child: _buildCell(['Y', 'Z']),
                      ), // Cell 9 (only 2 letters)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(List<String> letters) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: letters.asMap().entries.map((entry) {
          final index = entry.key;
          final letter = entry.value;
          final dotType = index; // 0: no dot, 1: 1 dot, 2: 2 dots

          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dots above letter
                SizedBox(height: 20, child: _buildDots(dotType)),
                const SizedBox(height: 4),
                // Letter
                Text(
                  letter,
                  style: GoogleFonts.courierPrime(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text matching cyber theme
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDots(int dotType) {
    if (dotType == 0) {
      // No dots
      return const SizedBox.shrink();
    } else if (dotType == 1) {
      // 1 dot centered
      return Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.yellow, // Yellow dots matching cyber theme
            shape: BoxShape.circle,
          ),
        ),
      );
    } else {
      // 2 dots horizontally
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.yellow, // Yellow dots matching cyber theme
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.yellow, // Yellow dots matching cyber theme
              shape: BoxShape.circle,
            ),
          ),
        ],
      );
    }
  }
}

/// Painter for the 3x3 grid lines in the reference chart
class Kotak2ReferenceGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors
          .yellow // Yellow lines matching cyber theme
      ..style = PaintingStyle.stroke
      ..strokeWidth =
          4.0 // Thick lines
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.miter;

    final padding = 16.0;
    final gridWidth = size.width - padding * 2;
    final gridHeight = size.height - padding * 2;
    final cellWidth = gridWidth / 3;
    final cellHeight = gridHeight / 3;

    // Draw vertical lines
    canvas.drawLine(
      Offset(padding + cellWidth, padding),
      Offset(padding + cellWidth, padding + gridHeight),
      gridPaint,
    );
    canvas.drawLine(
      Offset(padding + cellWidth * 2, padding),
      Offset(padding + cellWidth * 2, padding + gridHeight),
      gridPaint,
    );

    // Draw horizontal lines
    canvas.drawLine(
      Offset(padding, padding + cellHeight),
      Offset(padding + gridWidth, padding + cellHeight),
      gridPaint,
    );
    canvas.drawLine(
      Offset(padding, padding + cellHeight * 2),
      Offset(padding + gridWidth, padding + cellHeight * 2),
      gridPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
