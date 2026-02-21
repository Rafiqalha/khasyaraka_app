import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/theme/cyber_theme.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/widgets/cyber_container.dart';

/// Sandi Angka (Number Cipher) Tool
///
/// Converts text to numbers and vice versa
/// Standard: A=1, B=2, ..., Z=26
/// Reverse: Z=1, Y=2, ..., A=26
class SandiAngkaPage extends StatefulWidget {
  final SandiModel sandi;

  const SandiAngkaPage({super.key, required this.sandi});

  @override
  State<SandiAngkaPage> createState() => _SandiAngkaPageState();
}

class _SandiAngkaPageState extends State<SandiAngkaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _encodeInputController = TextEditingController();
  final TextEditingController _decodeInputController = TextEditingController();
  bool _isReverseMode = false;
  String _encodeResult = '';
  String _decodeResult = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _encodeInputController.addListener(_onEncodeInputChanged);
    _decodeInputController.addListener(_onDecodeInputChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _encodeInputController.dispose();
    _decodeInputController.dispose();
    super.dispose();
  }

  void _onEncodeInputChanged() {
    final text = _encodeInputController.text;
    if (text.isNotEmpty) {
      setState(() {
        _encodeResult = NumberCipherLogic.encode(text, _isReverseMode);
      });
    } else {
      setState(() {
        _encodeResult = '';
      });
    }
  }

  void _onDecodeInputChanged() {
    final text = _decodeInputController.text;
    if (text.isNotEmpty) {
      setState(() {
        _decodeResult = NumberCipherLogic.decode(text, _isReverseMode);
      });
    } else {
      setState(() {
        _decodeResult = '';
      });
    }
  }

  void _toggleReverseMode() {
    setState(() {
      _isReverseMode = !_isReverseMode;
      // Recalculate results with new mode
      if (_encodeInputController.text.isNotEmpty) {
        _encodeResult = NumberCipherLogic.encode(
          _encodeInputController.text,
          _isReverseMode,
        );
      }
      if (_decodeInputController.text.isNotEmpty) {
        _decodeResult = NumberCipherLogic.decode(
          _decodeInputController.text,
          _isReverseMode,
        );
      }
    });
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Copied to clipboard',
            style: CyberTheme.body().copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.black.withOpacity(0.9),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CyberTheme.neonCyan),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SANDI ANGKA',
          style: CyberTheme.headline().copyWith(
            fontSize: 18,
            color: CyberTheme.neonCyan,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: CyberTheme.neonCyan,
          labelColor: CyberTheme.neonCyan,
          unselectedLabelColor: CyberTheme.textSecondary,
          labelStyle: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mode Toggle
          CyberContainer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mode',
                  style: CyberTheme.headline().copyWith(fontSize: 16),
                ),
                Switch(
                  value: _isReverseMode,
                  onChanged: (_) => _toggleReverseMode(),
                  activeColor: CyberTheme.neonCyan,
                ),
                Text(
                  _isReverseMode ? 'Reverse (Z=1)' : 'Standard (A=1)',
                  style: GoogleFonts.courierPrime(
                    fontSize: 14,
                    color: _isReverseMode
                        ? CyberTheme.neonYellow
                        : CyberTheme.neonCyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Input Section
          CyberContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plaintext Input',
                  style: CyberTheme.headline().copyWith(fontSize: 16),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _encodeInputController,
                  style: GoogleFonts.courierPrime(
                    fontSize: 16,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter text (e.g., PRAMUKA)',
                    hintStyle: GoogleFonts.courierPrime(
                      fontSize: 14,
                      color: CyberTheme.textSecondary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: CyberTheme.neonCyan.withOpacity(0.5),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: CyberTheme.neonCyan.withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: CyberTheme.neonCyan,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.3),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  maxLines: 3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Output Section
          CyberContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Number Output',
                      style: CyberTheme.headline().copyWith(fontSize: 16),
                    ),
                    if (_encodeResult.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.copy,
                          color: CyberTheme.neonCyan,
                        ),
                        onPressed: () => _copyToClipboard(_encodeResult),
                        tooltip: 'Copy to clipboard',
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: CyberTheme.neonCyan.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: _encodeResult.isEmpty
                      ? Text(
                          'Enter text to encode...',
                          style: GoogleFonts.courierPrime(
                            fontSize: 14,
                            color: CyberTheme.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      : SelectableText(
                          _encodeResult,
                          style: GoogleFonts.courierPrime(
                            fontSize: 18,
                            color: CyberTheme.neonCyan,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecodeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mode Toggle
          CyberContainer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mode',
                  style: CyberTheme.headline().copyWith(fontSize: 16),
                ),
                Switch(
                  value: _isReverseMode,
                  onChanged: (_) => _toggleReverseMode(),
                  activeColor: CyberTheme.neonCyan,
                ),
                Text(
                  _isReverseMode ? 'Reverse (Z=1)' : 'Standard (A=1)',
                  style: GoogleFonts.courierPrime(
                    fontSize: 14,
                    color: _isReverseMode
                        ? CyberTheme.neonYellow
                        : CyberTheme.neonCyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Input Section
          CyberContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Number Input',
                  style: CyberTheme.headline().copyWith(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Example: 16-18-1-13-21-11-1',
                  style: GoogleFonts.courierPrime(
                    fontSize: 12,
                    color: CyberTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _decodeInputController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.courierPrime(
                    fontSize: 16,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter numbers (e.g., 16-18-1-13)',
                    hintStyle: GoogleFonts.courierPrime(
                      fontSize: 14,
                      color: CyberTheme.textSecondary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: CyberTheme.neonCyan.withOpacity(0.5),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: CyberTheme.neonCyan.withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: CyberTheme.neonCyan,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.3),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Output Section
          CyberContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Decoded Text',
                  style: CyberTheme.headline().copyWith(fontSize: 16),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: CyberTheme.neonCyan.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: _decodeResult.isEmpty
                      ? Text(
                          'Enter numbers to decode...',
                          style: GoogleFonts.courierPrime(
                            fontSize: 14,
                            color: CyberTheme.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      : SelectableText(
                          _decodeResult,
                          style: GoogleFonts.courierPrime(
                            fontSize: 18,
                            color: CyberTheme.neonCyan,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Number Cipher Logic
///
/// Handles encoding and decoding of text to/from numbers
class NumberCipherLogic {
  /// Encode text to numbers
  ///
  /// [text] - Input text to encode
  /// [isReverse] - If true, uses reverse mode (Z=1, Y=2, ..., A=26)
  /// Returns formatted number string with "-" separator
  static String encode(String text, bool isReverse) {
    if (text.isEmpty) return '';

    final upperText = text.toUpperCase();
    final List<String> result = [];
    final List<int> currentWord = [];

    for (int i = 0; i < upperText.length; i++) {
      final char = upperText[i];

      if (char == ' ') {
        // If we have accumulated numbers, add them as a word
        if (currentWord.isNotEmpty) {
          result.add(currentWord.join('-'));
          currentWord.clear();
        }
        // Add space to preserve word separation
        result.add(' ');
      } else if (char.codeUnitAt(0) >= 65 && char.codeUnitAt(0) <= 90) {
        // A-Z
        final number = isReverse
            ? 27 -
                  (char.codeUnitAt(0) - 64) // Reverse: Z=1, Y=2, ..., A=26
            : char.codeUnitAt(0) - 64; // Standard: A=1, B=2, ..., Z=26
        currentWord.add(number);
      }
      // Ignore non-alphabetic characters (punctuation, etc.)
    }

    // Add remaining numbers if any
    if (currentWord.isNotEmpty) {
      result.add(currentWord.join('-'));
    }

    return result.join('');
  }

  /// Decode numbers to text
  ///
  /// [input] - Input string containing numbers separated by non-digit characters
  /// [isReverse] - If true, uses reverse mode (Z=1, Y=2, ..., A=26)
  /// Returns decoded text string
  static String decode(String input, bool isReverse) {
    if (input.isEmpty) return '';

    // Split by non-digit characters (spaces, dashes, etc.)
    final parts = input.split(RegExp(r'\D+'));
    final List<String> decodedChars = [];

    for (final part in parts) {
      if (part.isEmpty) continue;

      try {
        final number = int.parse(part);

        if (number >= 1 && number <= 26) {
          final charCode = isReverse
              ? 27 -
                    number +
                    64 // Reverse: 1=Z, 2=Y, ..., 26=A
              : number + 64; // Standard: 1=A, 2=B, ..., 26=Z

          decodedChars.add(String.fromCharCode(charCode));
        } else {
          // Invalid number, skip or add placeholder
          decodedChars.add('?');
        }
      } catch (e) {
        // Invalid format, skip
        continue;
      }
    }

    return decodedChars.join('');
  }
}
