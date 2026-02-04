import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/theme/cyber_theme.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/widgets/cyber_container.dart';

/// Sandi AZ (AZ Cipher / Atbash) Tool
/// 
/// Reverses the alphabet:
/// A <-> Z, B <-> Y, C <-> X, ... M <-> N
/// 
/// Mathematical logic: NewChar = 'Z' - (OriginalChar - 'A')
/// Applying it twice returns the original text (self-inverse).
class SandiAzPage extends StatefulWidget {
  final SandiModel sandi;

  const SandiAzPage({
    super.key,
    required this.sandi,
  });

  @override
  State<SandiAzPage> createState() => _SandiAzPageState();
}

class _SandiAzPageState extends State<SandiAzPage> {
  final TextEditingController _encodeInputController = TextEditingController();
  final TextEditingController _decodeInputController = TextEditingController();
  bool _isEncryptMode = true;
  String _encodeResult = '';
  String _decodeResult = '';

  @override
  void initState() {
    super.initState();
    _encodeInputController.addListener(_onEncodeInputChanged);
    _decodeInputController.addListener(_onDecodeInputChanged);
  }

  @override
  void dispose() {
    _encodeInputController.dispose();
    _decodeInputController.dispose();
    super.dispose();
  }

  void _onEncodeInputChanged() {
    final text = _encodeInputController.text;
    if (text.isNotEmpty) {
      setState(() {
        _encodeResult = AzCipherLogic.process(text);
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
        _decodeResult = AzCipherLogic.process(text);
      });
    } else {
      setState(() {
        _decodeResult = '';
      });
    }
  }

  void _toggleMode() {
    setState(() {
      _isEncryptMode = !_isEncryptMode;
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
          'SANDI AZ',
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
            // Cheat Sheet Section (At the top)
            Text(
              'Cheat Sheet',
              style: CyberTheme.headline().copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),
            CyberContainer(
              child: _buildCheatSheet(),
            ),
            const SizedBox(height: 24),

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
                      controller: _encodeInputController,
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
                      controller: _decodeInputController,
                      style: GoogleFonts.courierPrime(
                        fontSize: 18,
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

            // Output Section
            if (_isEncryptMode) ...[
              CyberContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Encrypted Result',
                          style: CyberTheme.headline().copyWith(fontSize: 16),
                        ),
                        if (_encodeResult.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.copy, color: CyberTheme.neonCyan),
                            onPressed: () => _copyToClipboard(_encodeResult),
                            tooltip: 'Copy',
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      _encodeResult.isEmpty ? 'Result will appear here...' : _encodeResult,
                      style: GoogleFonts.courierPrime(
                        fontSize: 20,
                        color: _encodeResult.isEmpty
                            ? CyberTheme.textSecondary
                            : CyberTheme.neonCyan,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              CyberContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Decrypted Result',
                          style: CyberTheme.headline().copyWith(fontSize: 16),
                        ),
                        if (_decodeResult.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.copy, color: CyberTheme.matrixGreen),
                            onPressed: () => _copyToClipboard(_decodeResult),
                            tooltip: 'Copy',
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      _decodeResult.isEmpty ? 'Result will appear here...' : _decodeResult,
                      style: GoogleFonts.courierPrime(
                        fontSize: 20,
                        color: _decodeResult.isEmpty
                            ? CyberTheme.textSecondary
                            : CyberTheme.matrixGreen,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCheatSheet() {
    const row1 = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M'];
    const row2 = ['Z', 'Y', 'X', 'W', 'V', 'U', 'T', 'S', 'R', 'Q', 'P', 'O', 'N'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5DC).withOpacity(0.15), // Cream background (subtle)
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CyberTheme.surface.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Row 1: A-M
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row1.map((letter) {
              return Expanded(
                child: Center(
                  child: Text(
                    letter,
                    style: GoogleFonts.courierPrime(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Arrow indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(13, (index) {
              return Expanded(
                child: Center(
                  child: Icon(
                    Icons.swap_vert,
                    size: 16,
                    color: CyberTheme.neonCyan.withOpacity(0.6),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // Row 2: Z-N (reversed)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row2.map((letter) {
              return Expanded(
                child: Center(
                  child: Text(
                    letter,
                    style: GoogleFonts.courierPrime(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Explanation
          Text(
            'A ↔ Z  |  B ↔ Y  |  C ↔ X  |  ...  |  M ↔ N',
            style: GoogleFonts.courierPrime(
              fontSize: 12,
              color: CyberTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
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
}

/// AzCipherLogic - Handles AZ Cipher (Atbash) encoding/decoding
class AzCipherLogic {
  /// Process text using AZ Cipher (Atbash)
  /// Since Atbash is self-inverse, this function works for both encoding and decoding
  static String process(String input) {
    final text = input.toUpperCase();
    final result = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final codeUnit = char.codeUnitAt(0);

      if (codeUnit >= 65 && codeUnit <= 90) {
        // A-Z: Reverse the alphabet
        // Calculate offset from 'A'
        final offset = codeUnit - 'A'.codeUnitAt(0);
        // Find reverse char: 'Z' - offset
        final reverseCode = 'Z'.codeUnitAt(0) - offset;
        result.writeCharCode(reverseCode);
      } else {
        // Non-alphabetic characters remain unchanged
        result.write(char);
      }
    }

    return result.toString();
  }
}
