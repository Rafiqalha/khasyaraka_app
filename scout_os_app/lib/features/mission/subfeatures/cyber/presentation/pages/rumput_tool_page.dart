import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/theme/cyber_theme.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/widgets/cyber_container.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/widgets/sandi_rumput_view.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/services/morse_audio_service.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/services/morse_haptic_service.dart';

/// Rumput Tool Page - Same layout as Morse but with Rumput visualization
/// 
/// Real-time conversion between text and Rumput pattern
/// with visual rumput pattern display using CustomPainter
class RumputToolPage extends StatefulWidget {
  final SandiModel sandi;

  const RumputToolPage({
    super.key,
    required this.sandi,
  });

  @override
  State<RumputToolPage> createState() => _RumputToolPageState();
}

class _RumputToolPageState extends State<RumputToolPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _graphScrollController = ScrollController();
  bool _isEncryptMode = true; // true = Text to Rumput, false = Rumput to Text
  String _previousText = ''; // Track previous text for detecting new characters

  // Decode mode state variables
  String _rawMorseSequence = ''; // For visualization (e.g., ".- -")
  String _currentLetterBuffer = ''; // Current letter being built (e.g., ".-")
  String _decodedText = ''; // Final decoded text (e.g., "A K U")

  // Morse to Alphabet dictionary (reverse lookup)
  static const Map<String, String> morseToAlphabet = {
    '.-': 'A', '-...': 'B', '-.-.': 'C', '-..': 'D', '.': 'E',
    '..-.': 'F', '--.': 'G', '....': 'H', '..': 'I', '.---': 'J',
    '-.-': 'K', '.-..': 'L', '--': 'M', '-.': 'N', '---': 'O',
    '.--.': 'P', '--.-': 'Q', '.-.': 'R', '...': 'S', '-': 'T',
    '..-': 'U', '...-': 'V', '.--': 'W', '-..-': 'X', '-.--': 'Y',
    '--..': 'Z',
    '-----': '0', '.----': '1', '..---': '2', '...--': '3',
    '....-': '4', '.....': '5', '-....': '6', '--...': '7',
    '---..': '8', '----.': '9',
  };

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    
    // Initialize audio service
    MorseAudioService.initialize();
  }

  @override
  void dispose() {
    _textController.dispose();
    _graphScrollController.dispose();
    MorseAudioService.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_isEncryptMode) {
      // In encode mode: text -> morse -> visualization
      final currentText = _textController.text;
      
      // CRITICAL: Call setState to trigger widget rebuild and update visualization
      setState(() {
        // State update triggers rebuild
      });
      
      // Play audio and haptic for newly typed characters
      if (currentText.length > _previousText.length) {
        final newChars = currentText.substring(_previousText.length);
        _playFeedbackForText(newChars);
      }
      
      _previousText = currentText;
    }
  }

  /// Get text for visualization (encode: from text, decode: from morse converted to text)
  String _getVisualizationText() {
    if (_isEncryptMode) {
      // Encode mode: visualize the text directly
      return _textController.text;
    } else {
      // Decode mode: convert raw morse sequence to text for visualization
      // The grafik shows the decoded text, not the raw morse
      return _convertMorseSequenceToText(_rawMorseSequence);
    }
  }

  /// Convert raw morse sequence to text (for visualization in decode mode)
  String _convertMorseSequenceToText(String morseSequence) {
    if (morseSequence.isEmpty) return '';
    
    final result = <String>[];
    final parts = morseSequence.split(' ');

    for (var part in parts) {
      if (part.isEmpty) continue;
      if (morseToAlphabet.containsKey(part)) {
        result.add(morseToAlphabet[part]!);
      } else {
        result.add('?'); // Unknown pattern
      }
    }

    return result.join(' ');
  }

  /// Play feedback for newly typed characters
  Future<void> _playFeedbackForText(String text) async {
    if (text.isEmpty) return;
    
    for (int i = 0; i < text.length; i++) {
      final char = text[i].toUpperCase();
      
      if (char == ' ') {
        // Space = short pause
        await Future.delayed(const Duration(milliseconds: 100));
      } else {
        // Character = short beep + haptic (like Morse dot)
        await Future.wait([
          MorseAudioService.playDot(),
          MorseHapticService.playDot(),
        ]);
        
        // Small delay between characters
        if (i < text.length - 1) {
          await Future.delayed(const Duration(milliseconds: 50));
        }
      }
    }
  }

  void _onClear() {
    setState(() {
      if (_isEncryptMode) {
        _textController.clear();
        _previousText = '';
      } else {
        // Clear decode mode state
        _rawMorseSequence = '';
        _currentLetterBuffer = '';
        _decodedText = '';
      }
    });
  }

  void _toggleMode() {
    setState(() {
      _isEncryptMode = !_isEncryptMode;
      _textController.clear();
      _previousText = '';
      // Clear decode mode state
      _rawMorseSequence = '';
      _currentLetterBuffer = '';
      _decodedText = '';
    });
  }

  // ========== DECODE MODE BUTTON HANDLERS ==========

  /// Handle Short Grass button (Dot)
  void _onShortGrassPressed() {
    setState(() {
      _currentLetterBuffer += '.';
      _rawMorseSequence += '.';
      
      // Play feedback
      Future.wait([
        MorseAudioService.playDot(),
        MorseHapticService.playDot(),
      ]);
      
      // Auto-scroll graph to right
      _scrollGraphToEnd();
    });
  }

  /// Handle Tall Grass button (Dash)
  void _onTallGrassPressed() {
    setState(() {
      _currentLetterBuffer += '-';
      _rawMorseSequence += '-';
      
      // Play feedback
      Future.wait([
        MorseAudioService.playDash(),
        MorseHapticService.playDash(),
      ]);
      
      // Auto-scroll graph to right
      _scrollGraphToEnd();
    });
  }

  /// Handle Separator button (Space between letters)
  void _onSeparatorPressed() {
    setState(() {
      // Decode current letter buffer
      if (_currentLetterBuffer.isNotEmpty) {
        final letter = morseToAlphabet[_currentLetterBuffer] ?? '?';
        _decodedText += letter;
        _currentLetterBuffer = ''; // Clear buffer
        
        // Add space to raw sequence for visualization (after the letter)
        if (!_rawMorseSequence.endsWith(' ')) {
          _rawMorseSequence += ' ';
        }
      } else {
        // If buffer is empty but user presses separator, just add space
        if (!_rawMorseSequence.endsWith(' ')) {
          _rawMorseSequence += ' ';
        }
      }
      
      // Auto-scroll graph to right
      _scrollGraphToEnd();
    });
  }

  /// Handle Backspace button
  void _onBackspacePressed() {
    setState(() {
      if (_rawMorseSequence.isNotEmpty) {
        // Remove last character from raw sequence
        _rawMorseSequence = _rawMorseSequence.substring(0, _rawMorseSequence.length - 1);
        
        // Update current letter buffer
        if (_currentLetterBuffer.isNotEmpty) {
          _currentLetterBuffer = _currentLetterBuffer.substring(0, _currentLetterBuffer.length - 1);
        } else if (_decodedText.isNotEmpty) {
          // If buffer is empty, remove last decoded letter
          _decodedText = _decodedText.substring(0, _decodedText.length - 1);
          // Also remove trailing space from raw sequence if exists
          if (_rawMorseSequence.endsWith(' ')) {
            _rawMorseSequence = _rawMorseSequence.substring(0, _rawMorseSequence.length - 1);
          }
        }
      }
      
      // Auto-scroll graph to right
      _scrollGraphToEnd();
    });
  }

  /// Auto-scroll graph to the right end
  void _scrollGraphToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_graphScrollController.hasClients) {
        _graphScrollController.animateTo(
          _graphScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.sandi.name.toUpperCase()} TOOL',
          style: CyberTheme.headline().copyWith(
            fontSize: 16,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Mode Toggle
            _buildModeToggle(),
            
            // Main Content
            Expanded(
              child: _isEncryptMode
                  ? _buildEncodeMode()
                  : _buildDecodeMode(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: CyberTheme.matrixGreen.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              label: 'ENCODE',
              isActive: _isEncryptMode,
              onTap: () {
                if (!_isEncryptMode) _toggleMode();
              },
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              label: 'DECODE',
              isActive: !_isEncryptMode,
              onTap: () {
                if (_isEncryptMode) _toggleMode();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? CyberTheme.matrixGreen.withOpacity(0.2)
              : Colors.transparent,
          border: Border.all(
            color: isActive
                ? CyberTheme.matrixGreen
                : Colors.transparent,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.orbitron(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? CyberTheme.matrixGreen : CyberTheme.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  // ========== ENCODE MODE UI ==========

  Widget _buildEncodeMode() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Text Input Section
          _buildTextSection(),
          const SizedBox(height: 16),
          
          // Rumput Visual Section
          _buildRumputVisualSection(),
        ],
      ),
    );
  }

  Widget _buildTextSection() {
    return CyberContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PLAINTEXT',
                style: GoogleFonts.courierPrime(
                  fontSize: 10,
                  color: CyberTheme.matrixGreen,
                  letterSpacing: 1.5,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.clear, color: CyberTheme.matrixGreen, size: 20),
                onPressed: _onClear,
                tooltip: 'Clear',
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _textController,
            enabled: true,
            style: GoogleFonts.courierPrime(
              fontSize: 16,
              color: Colors.white,
              letterSpacing: 1,
            ),
            decoration: InputDecoration(
              hintText: 'Type your message...',
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
            autofocus: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRumputVisualSection() {
    final visualizationText = _getVisualizationText();
    
    return CyberContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RUMPUT VISUALIZATION',
            style: GoogleFonts.courierPrime(
              fontSize: 10,
              color: CyberTheme.matrixGreen,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 120,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: CyberTheme.matrixGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: visualizationText.trim().isEmpty
                ? Center(
                    child: Text(
                      'Type text to see rumput visualization...',
                      style: GoogleFonts.courierPrime(
                        fontSize: 12,
                        color: CyberTheme.textSecondary,
                      ),
                    ),
                  )
                : Align(
                    alignment: Alignment.bottomCenter,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: false,
                      child: SandiRumputView(
                        text: visualizationText,
                        strokeWidth: 3.0,
                        color: CyberTheme.matrixGreen,
                        unitWidth: 18.0,
                        shortHeight: 30.0,
                        tallHeight: 80.0,
                        spaceWidth: 25.0,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ========== DECODE MODE UI ==========

  Widget _buildDecodeMode() {
    return Column(
      children: [
        // Top: Decoded Text Display
        Expanded(
          flex: 2,
          child: _buildDecodedTextDisplay(),
        ),
        
        // Middle: Graph Visualization
        Expanded(
          flex: 3,
          child: _buildDecodeGraphSection(),
        ),
        
        // Bottom: Custom Keyboard
        _buildDecodeKeyboard(),
      ],
    );
  }

  Widget _buildDecodedTextDisplay() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: CyberTheme.matrixGreen.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DECODED TEXT',
            style: GoogleFonts.courierPrime(
              fontSize: 10,
              color: CyberTheme.matrixGreen,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: Text(
                _decodedText.isEmpty ? '...' : _decodedText,
                style: GoogleFonts.orbitron(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecodeGraphSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: CyberTheme.matrixGreen.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RUMPUT GRAPH',
            style: GoogleFonts.courierPrime(
              fontSize: 10,
              color: CyberTheme.matrixGreen,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _rawMorseSequence.isEmpty
                  ? Center(
                      child: Text(
                        'Tap buttons below to build graph...',
                        style: GoogleFonts.courierPrime(
                          fontSize: 12,
                          color: CyberTheme.textSecondary,
                        ),
                      ),
                    )
                  : Align(
                      alignment: Alignment.bottomCenter,
                      child: SingleChildScrollView(
                        controller: _graphScrollController,
                        scrollDirection: Axis.horizontal,
                        reverse: false,
                        child: SandiRumputView(
                          morseCode: _rawMorseSequence, // Use raw morse code directly
                          strokeWidth: 3.0,
                          color: CyberTheme.matrixGreen,
                          unitWidth: 18.0,
                          shortHeight: 30.0,
                          tallHeight: 80.0,
                          spaceWidth: 25.0,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecodeKeyboard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(
            color: CyberTheme.matrixGreen.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Row 1: Short Grass and Tall Grass
          Row(
            children: [
              Expanded(
                child: _buildGrassButton(
                  label: 'SHORT GRASS',
                  icon: Icons.arrow_drop_up,
                  color: CyberTheme.matrixGreen,
                  onPressed: _onShortGrassPressed,
                  isShort: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGrassButton(
                  label: 'TALL GRASS',
                  icon: Icons.arrow_drop_up,
                  color: CyberTheme.alertOrange,
                  onPressed: _onTallGrassPressed,
                  isShort: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 2: Separator and Backspace
          Row(
            children: [
              Expanded(
                child: _buildGrassButton(
                  label: 'SEPARATOR',
                  icon: Icons.remove,
                  color: CyberTheme.neonCyan,
                  onPressed: _onSeparatorPressed,
                  isShort: null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGrassButton(
                  label: 'BACKSPACE',
                  icon: Icons.backspace,
                  color: Colors.red.shade400,
                  onPressed: _onBackspacePressed,
                  isShort: null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Clear button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onClear,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade900.withOpacity(0.3),
                foregroundColor: Colors.red.shade300,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Colors.red.shade400,
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                'CLEAR ALL',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrassButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool? isShort,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          border: Border.all(
            color: color.withOpacity(0.6),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with different sizes for short/tall
            Icon(
              icon,
              size: isShort == true ? 32 : (isShort == false ? 48 : 28),
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.courierPrime(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
