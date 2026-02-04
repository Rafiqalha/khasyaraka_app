import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/theme/cyber_theme.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/widgets/cyber_container.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/cipher/morse_cipher.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/services/morse_audio_service.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/services/morse_haptic_service.dart';

/// Morse Tool Page - Secret Agent Theme
/// 
/// Real-time conversion between text and Morse code
/// with custom Morse keyboard, haptic feedback, and audio
class MorseToolPage extends StatefulWidget {
  final SandiModel sandi;

  const MorseToolPage({
    super.key,
    required this.sandi,
  });

  @override
  State<MorseToolPage> createState() => _MorseToolPageState();
}

class _MorseToolPageState extends State<MorseToolPage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _morseController = TextEditingController();
  bool _isEncryptMode = true; // true = Text to Morse, false = Morse to Text
  String _previousText = ''; // Track previous text for detecting new characters

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _morseController.addListener(_onMorseChanged);
    // Initialize audio service
    MorseAudioService.initialize();
  }

  @override
  void dispose() {
    _textController.dispose();
    _morseController.dispose();
    MorseAudioService.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_isEncryptMode) {
      final currentText = _textController.text;
      final morse = _convertTextToMorse(currentText);
      
      // Update morse controller
      if (_morseController.text != morse) {
        _morseController.removeListener(_onMorseChanged);
        _morseController.text = morse;
        _morseController.addListener(_onMorseChanged);
      }
      
      // Play audio and haptic for newly typed characters
      if (currentText.length > _previousText.length) {
        // New character(s) added - play morse for new chars only
        final newChars = currentText.substring(_previousText.length);
        // Run in background to not block UI
        _playMorseForText(newChars);
      }
      
      _previousText = currentText;
    }
  }

  void _onMorseChanged() {
    if (!_isEncryptMode) {
      final text = _convertMorseToText(_morseController.text);
      if (_textController.text != text) {
        _textController.removeListener(_onTextChanged);
        _textController.text = text;
        _textController.addListener(_onTextChanged);
      }
    }
  }

  String _convertTextToMorse(String text) {
    final cipher = MorseCipher(widget.sandi);
    return cipher.encrypt(text);
  }

  String _convertMorseToText(String morse) {
    final cipher = MorseCipher(widget.sandi);
    return cipher.decrypt(morse);
  }

  /// Play Morse character feedback (audio + haptic)
  /// 
  /// According to Morse standard:
  /// - Dot (.) = 1 unit (short beep + short vibration)
  /// - Dash (-) = 3 units (long beep + long vibration)
  /// 
  /// Single playback, NOT multiple beeps/vibrations
  Future<void> _playMorseSound(String morseChar) async {
    if (morseChar == '.') {
      // Dot: 1 unit - short beep + short vibration
      await Future.wait([
        MorseAudioService.playDot(),
        MorseHapticService.playDot(),
      ]);
    } else if (morseChar == '-') {
      // Dash: 3 units - long beep + long vibration
      // Single playback, NOT multiple beeps
      await Future.wait([
        MorseAudioService.playDash(),
        MorseHapticService.playDash(),
      ]);
    }
  }

  /// Play Morse code for text characters (used in encode mode)
  /// 
  /// Converts text to morse and plays audio/haptic for each dot/dash
  /// Plays quickly as user types, character by character
  Future<void> _playMorseForText(String text) async {
    if (text.isEmpty) return;
    
    // Process each character individually
    for (int i = 0; i < text.length; i++) {
      final char = text[i].toUpperCase();
      
      // Get morse code for this character
      final morse = _getMorseForChar(char);
      
      if (morse.isEmpty) continue; // Skip unknown characters
      
      // Play each dot/dash in the morse code for this character
      for (int j = 0; j < morse.length; j++) {
        final morseChar = morse[j];
        
        if (morseChar == '.') {
          // Play dot
          await _playMorseSound('.');
          // Small delay between dots/dashes within same character (30ms)
          if (j < morse.length - 1) {
            await Future.delayed(const Duration(milliseconds: 30));
          }
        } else if (morseChar == '-') {
          // Play dash
          await _playMorseSound('-');
          // Small delay between dots/dashes within same character (30ms)
          if (j < morse.length - 1) {
            await Future.delayed(const Duration(milliseconds: 30));
          }
        }
      }
      
      // Delay between characters (100ms) - but don't wait if user is typing fast
      if (i < text.length - 1) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  /// Get morse code for a single character
  String _getMorseForChar(String char) {
    // Access the static textToMorse map from MorseCipher
    // Note: We need to make textToMorse accessible, or use encrypt method
    final cipher = MorseCipher(widget.sandi);
    final morse = cipher.encrypt(char);
    // Remove spaces (encrypt adds space between characters)
    return morse.trim();
  }

  void _onMorseKeyTap(String char) async {
    setState(() {
      _isEncryptMode = false; // Switch to decode mode when using Morse keyboard
      _morseController.text += char;
    });
    
    // Play sound and haptic feedback
    await _playMorseSound(char);
  }

  void _onBackspace() {
    if (_morseController.text.isNotEmpty) {
      setState(() {
        _morseController.text = _morseController.text.substring(
          0,
          _morseController.text.length - 1,
        );
      });
    }
  }

  void _onSpace() {
    setState(() {
      _morseController.text += ' / ';
    });
  }

  void _onClear() {
    setState(() {
      _textController.clear();
      _morseController.clear();
    });
  }

  void _toggleMode() {
    setState(() {
      _isEncryptMode = !_isEncryptMode;
      _textController.clear();
      _morseController.clear();
      _previousText = ''; // Reset previous text tracking
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
            
            // Input/Output Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Text Input Section
                    _buildTextSection(),
                    const SizedBox(height: 16),
                    
                    // Morse Output Section
                    _buildMorseSection(),
                    
                    // Morse Keyboard (only show in decode mode)
                    if (!_isEncryptMode) ...[
                      const SizedBox(height: 24),
                      _buildMorseKeyboard(),
                    ],
                  ],
                ),
              ),
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
          color: CyberTheme.neonCyan.withOpacity(0.3),
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
              ? CyberTheme.neonCyan.withOpacity(0.2)
              : Colors.transparent,
          border: Border.all(
            color: isActive
                ? CyberTheme.neonCyan
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
            color: isActive ? CyberTheme.neonCyan : CyberTheme.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
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
                _isEncryptMode ? 'PLAINTEXT' : 'DECODED',
                style: GoogleFonts.courierPrime(
                  fontSize: 10,
                  color: CyberTheme.neonCyan,
                  letterSpacing: 1.5,
                ),
              ),
              if (!_isEncryptMode)
                IconButton(
                  icon: const Icon(Icons.keyboard, color: CyberTheme.neonCyan, size: 20),
                  onPressed: () {
                    // Keyboard already shown in decode mode
                  },
                  tooltip: 'Morse Keyboard',
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _textController,
            enabled: _isEncryptMode,
            style: GoogleFonts.courierPrime(
              fontSize: 16,
              color: Colors.white,
              letterSpacing: 1,
            ),
            decoration: InputDecoration(
              hintText: _isEncryptMode
                  ? 'Type your message...'
                  : 'Decoded text appears here...',
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
            autofocus: _isEncryptMode,
          ),
        ],
      ),
    );
  }

  Widget _buildMorseSection() {
    return CyberContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isEncryptMode ? 'MORSE CODE' : 'MORSE INPUT',
            style: GoogleFonts.courierPrime(
              fontSize: 10,
              color: CyberTheme.matrixGreen,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _morseController,
            enabled: !_isEncryptMode,
            style: GoogleFonts.courierPrime(
              fontSize: 18,
              color: CyberTheme.matrixGreen,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: _isEncryptMode
                  ? 'Morse code appears here...'
                  : 'Tap Morse keys below...',
              hintStyle: GoogleFonts.courierPrime(
                fontSize: 14,
                color: CyberTheme.textSecondary,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            maxLines: null,
          ),
        ],
      ),
    );
  }

  Widget _buildMorseKeyboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MORSE KEYBOARD',
          style: GoogleFonts.courierPrime(
            fontSize: 10,
            color: CyberTheme.neonCyan,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        CyberContainer(
          child: Column(
            children: [
              // Dot and Dash buttons
              Row(
                children: [
                  Expanded(
                    child: _buildMorseKey(
                      label: 'DOT',
                      symbol: '.',
                      color: CyberTheme.matrixGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMorseKey(
                      label: 'DASH',
                      symbol: '-',
                      color: CyberTheme.alertOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Space and Backspace
              Row(
                children: [
                  Expanded(
                    child: _buildMorseKey(
                      label: 'SPACE',
                      symbol: '/',
                      color: CyberTheme.neonCyan,
                      onTap: _onSpace,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMorseKey(
                      label: 'DELETE',
                      symbol: '⌫',
                      color: Colors.red.shade400,
                      onTap: _onBackspace,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
    );
  }

  Widget _buildMorseKey({
    required String label,
    required String symbol,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () => _onMorseKeyTap(symbol),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              symbol,
              style: GoogleFonts.orbitron(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.courierPrime(
                fontSize: 10,
                color: color.withOpacity(0.8),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
