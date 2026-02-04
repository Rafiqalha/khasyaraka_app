import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/theme/cyber_theme.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/widgets/cyber_container.dart';

/// Sandi Napoleon (Napoleon Cipher) Tool Page
/// 
/// Horizontal Boustrophedon (Row-by-Row Filling):
/// - Row 0 (Even): Fill Left-to-Right (Col 0 to Max)
/// - Row 1 (Odd): Fill Right-to-Left (Col Max to 0)
/// - Row 2 (Even): Fill Left-to-Right
/// - ...and so on
/// 
/// Encrypted text is read Row-by-Row (Left to Right)
class SandiNapoleonPage extends StatefulWidget {
  final SandiModel sandi;

  const SandiNapoleonPage({
    super.key,
    required this.sandi,
  });

  @override
  State<SandiNapoleonPage> createState() => _SandiNapoleonPageState();
}

class _SandiNapoleonPageState extends State<SandiNapoleonPage>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _encryptedController = TextEditingController();
  bool _isEncryptMode = true;
  double _columnCount = 5.0; // Default 5 columns (Key)
  List<List<String>> _grid = [];
  String _encryptedText = '';
  String _decryptedText = '';
  late AnimationController _gridAnimationController;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateGrid);
    _encryptedController.addListener(_updateDecode);
    _gridAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _encryptedController.dispose();
    _gridAnimationController.dispose();
    super.dispose();
  }

  void _updateGrid() {
    if (_isEncryptMode) {
      setState(() {
        _buildGrid();
        _gridAnimationController.forward(from: 0);
      });
    }
  }

  void _updateDecode() {
    if (!_isEncryptMode) {
      setState(() {
        _buildGridFromEncrypted();
        _gridAnimationController.forward(from: 0);
      });
    }
  }

  void _onColumnCountChanged(double value) {
    setState(() {
      _columnCount = value;
      if (_isEncryptMode) {
        _buildGrid();
      } else {
        _buildGridFromEncrypted();
      }
      _gridAnimationController.forward(from: 0);
    });
  }

  void _toggleMode() {
    setState(() {
      _isEncryptMode = !_isEncryptMode;
      if (_isEncryptMode) {
        _buildGrid();
      } else {
        _buildGridFromEncrypted();
      }
      _gridAnimationController.forward(from: 0);
    });
  }

  /// Build the horizontal napoleon grid from input text (Row-by-Row filling)
  void _buildGrid() {
    final text = _textController.text.toUpperCase().replaceAll(' ', '');
    if (text.isEmpty) {
      _grid = [];
      _encryptedText = '';
      return;
    }

    final cols = _columnCount.toInt();
    final rows = (text.length / cols).ceil();
    final totalCells = rows * cols;

    // Pad text with 'X' if needed
    final paddedText = text.padRight(totalCells, 'X');

    // Initialize empty grid
    _grid = List.generate(rows, (_) => List.filled(cols, ''));

    // Fill row by row with horizontal boustrophedon pattern
    int textIndex = 0;
    for (int row = 0; row < rows; row++) {
      if (row % 2 == 0) {
        // Even row: Fill LEFT-TO-RIGHT (Col 0 to Max)
        for (int col = 0; col < cols; col++) {
          if (textIndex < paddedText.length) {
            _grid[row][col] = paddedText[textIndex];
            textIndex++;
          }
        }
      } else {
        // Odd row: Fill RIGHT-TO-LEFT (Col Max to 0)
        for (int col = cols - 1; col >= 0; col--) {
          if (textIndex < paddedText.length) {
            _grid[row][col] = paddedText[textIndex];
            textIndex++;
          }
        }
      }
    }

    // Calculate encrypted text (read row by row, left to right)
    _calculateEncryptedText();
  }

  /// Calculate encrypted text by reading row by row (left to right)
  void _calculateEncryptedText() {
    if (_grid.isEmpty) {
      _encryptedText = '';
      return;
    }

    final result = <String>[];
    for (var row in _grid) {
      result.add(row.join(''));
    }

    _encryptedText = result.join('');
  }

  /// Build grid from encrypted text (decode mode)
  /// Encrypted text is read row by row, then we extract row by row with boustrophedon pattern
  void _buildGridFromEncrypted() {
    final encrypted = _encryptedController.text.toUpperCase().replaceAll(' ', '');
    if (encrypted.isEmpty) {
      _grid = [];
      _decryptedText = '';
      return;
    }

    final cols = _columnCount.toInt();
    final rows = (encrypted.length / cols).ceil();
    final totalCells = rows * cols;

    // Pad encrypted text with 'X' if needed
    final paddedEncrypted = encrypted.padRight(totalCells, 'X');

    // Build grid by reading row by row (encrypted text format)
    _grid = List.generate(rows, (_) => List.filled(cols, ''));
    
    int encryptedIndex = 0;
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (encryptedIndex < paddedEncrypted.length) {
          _grid[row][col] = paddedEncrypted[encryptedIndex];
          encryptedIndex++;
        }
      }
    }

    // Now extract text row by row with horizontal boustrophedon pattern
    _calculateDecryptedText();
  }

  /// Calculate decrypted text by reading row by row with horizontal boustrophedon pattern
  void _calculateDecryptedText() {
    if (_grid.isEmpty) {
      _decryptedText = '';
      return;
    }

    final rows = _grid.length;
    final cols = _grid[0].length;
    final result = <String>[];

    // Read row by row with horizontal boustrophedon pattern
    for (int row = 0; row < rows; row++) {
      if (row % 2 == 0) {
        // Even row: Read LEFT-TO-RIGHT (Col 0 to Max)
        for (int col = 0; col < cols; col++) {
          result.add(_grid[row][col]);
        }
      } else {
        // Odd row: Read RIGHT-TO-LEFT (Col Max to 0)
        for (int col = cols - 1; col >= 0; col--) {
          result.add(_grid[row][col]);
        }
      }
    }

    _decryptedText = result.join('').replaceAll('X', '').trim();
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
          'SANDI NAPOLEON',
          style: CyberTheme.headline().copyWith(
            fontSize: 18,
            color: CyberTheme.neonCyan,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mode Toggle
            CyberContainer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildModeButton('ENCODE', true),
                  const SizedBox(width: 16),
                  _buildModeButton('DECODE', false),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Input Section (Encode Mode)
            if (_isEncryptMode)
              CyberContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plaintext',
                      style: CyberTheme.headline().copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _textController,
                      style: GoogleFonts.courierPrime(
                        fontSize: 16,
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

            // Input Section (Decode Mode)
            if (!_isEncryptMode)
              CyberContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Encrypted Text',
                      style: CyberTheme.headline().copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _encryptedController,
                      style: GoogleFonts.courierPrime(
                        fontSize: 16,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Paste encrypted text here...',
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

            // Column Count Slider
            CyberContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Column Count (Key)',
                        style: CyberTheme.headline().copyWith(fontSize: 16),
                      ),
                      Text(
                        _columnCount.toInt().toString(),
                        style: GoogleFonts.orbitron(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: CyberTheme.neonCyan,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: _columnCount,
                    min: 2,
                    max: 8,
                    divisions: 6,
                    label: _columnCount.toInt().toString(),
                    activeColor: CyberTheme.neonCyan,
                    inactiveColor: CyberTheme.surface,
                    onChanged: _onColumnCountChanged,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Grid Visualization
            if (_grid.isNotEmpty) ...[
              Text(
                'Horizontal Boustrophedon Grid Pattern',
                style: CyberTheme.headline().copyWith(fontSize: 16),
              ),
              const SizedBox(height: 12),
              CyberContainer(
                child: _buildGridView(),
              ),
              const SizedBox(height: 24),

              // Result Section
              if (_isEncryptMode) ...[
                // Encrypted Result
                Text(
                  'Encrypted Text (Row-by-Row)',
                  style: CyberTheme.headline().copyWith(fontSize: 16),
                ),
                const SizedBox(height: 12),
                CyberContainer(
                  child: Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          _encryptedText,
                          style: GoogleFonts.courierPrime(
                            fontSize: 20,
                            color: CyberTheme.neonCyan,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: CyberTheme.neonCyan),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _encryptedText));
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
                        },
                        tooltip: 'Copy',
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Decrypted Result
                Text(
                  'Decrypted Text',
                  style: CyberTheme.headline().copyWith(fontSize: 16),
                ),
                const SizedBox(height: 12),
                CyberContainer(
                  child: Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          _decryptedText.isEmpty ? 'Decoding...' : _decryptedText,
                          style: GoogleFonts.courierPrime(
                            fontSize: 20,
                            color: CyberTheme.matrixGreen,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_decryptedText.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.copy, color: CyberTheme.matrixGreen),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _decryptedText));
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
                          },
                          tooltip: 'Copy',
                        ),
                    ],
                  ),
                ),
              ],
            ] else ...[
              CyberContainer(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      _isEncryptMode
                          ? 'Enter text above to visualize the grid...'
                          : 'Paste encrypted text above to decode...',
                      style: GoogleFonts.courierPrime(
                        fontSize: 14,
                        color: CyberTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(String label, bool isEncrypt) {
    final isActive = _isEncryptMode == isEncrypt;
    return Expanded(
      child: GestureDetector(
        onTap: _toggleMode,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? CyberTheme.neonCyan.withOpacity(0.2)
                : Colors.transparent,
            border: Border.all(
              color: isActive ? CyberTheme.neonCyan : CyberTheme.surface,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isActive ? CyberTheme.neonCyan : CyberTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridView() {
    if (_grid.isEmpty) return const SizedBox.shrink();

    final cols = _columnCount.toInt();

    return Column(
      children: [
        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: _grid.length * cols,
          itemBuilder: (context, index) {
            final row = index ~/ cols;
            final col = index % cols;

            if (row >= _grid.length || col >= _grid[row].length) {
              return const SizedBox.shrink();
            }

            final char = _grid[row][col];
            final isEvenRow = row % 2 == 0;

            // Animation delay based on position
            final delay = (row * cols + col) * 0.03;
            final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _gridAnimationController,
                curve: Interval(
                  delay.clamp(0.0, 0.9),
                  (delay + 0.1).clamp(0.0, 1.0),
                  curve: Curves.easeOut,
                ),
              ),
            );

            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return _buildGridCell(
                  char: char,
                  row: row,
                  col: col,
                  isEvenRow: isEvenRow,
                  animation: animation,
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(
              icon: Icons.arrow_forward,
              label: 'Even Rows (→)',
              color: Colors.green.shade400, // Green-ish
            ),
            const SizedBox(width: 24),
            _buildLegendItem(
              icon: Icons.arrow_back,
              label: 'Odd Rows (←)',
              color: Colors.orange.shade400, // Orange-ish
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridCell({
    required String char,
    required int row,
    required int col,
    required bool isEvenRow,
    required Animation<double> animation,
  }) {
    final cellColor = isEvenRow
        ? Colors.green.shade400.withOpacity(0.2) // Green-ish
        : Colors.orange.shade400.withOpacity(0.2); // Orange-ish

    final borderColor = isEvenRow
        ? Colors.green.shade400.withOpacity(0.5)
        : Colors.orange.shade400.withOpacity(0.5);

    // Animation values
    final fadeValue = animation.value;
    final scaleValue = 0.8 + (animation.value * 0.2);
    final slideOffset = isEvenRow
        ? (1 - animation.value) * 50 // Slide from left
        : (1 - animation.value) * -50; // Slide from right

    return Transform.translate(
      offset: Offset(slideOffset, 0),
      child: Transform.scale(
        scale: scaleValue,
        child: Opacity(
          opacity: fadeValue,
          child: Container(
            decoration: BoxDecoration(
              color: cellColor,
              border: Border.all(
                color: borderColor,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                if (animation.value > 0.5)
                  BoxShadow(
                    color: (isEvenRow
                            ? Colors.green.shade400
                            : Colors.orange.shade400)
                        .withOpacity(0.3 * animation.value),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Stack(
              children: [
                // Character
                Center(
                  child: Text(
                    char,
                    style: GoogleFonts.orbitron(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Arrow indicator
                Positioned(
                  top: 4,
                  right: isEvenRow ? 4 : null,
                  left: isEvenRow ? null : 4,
                  child: Icon(
                    isEvenRow ? Icons.arrow_forward : Icons.arrow_back,
                    size: 16,
                    color: isEvenRow
                        ? Colors.green.shade400
                        : Colors.orange.shade400,
                  ),
                ),

                // Position label (small, bottom)
                Positioned(
                  bottom: 2,
                  left: 4,
                  child: Text(
                    '${row},${col}',
                    style: GoogleFonts.courierPrime(
                      fontSize: 8,
                      color: CyberTheme.textSecondary.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.courierPrime(
            fontSize: 12,
            color: CyberTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
