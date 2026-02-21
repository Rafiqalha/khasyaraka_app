import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/cipher/morse_cipher.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/services/morse_audio_service.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/services/morse_haptic_service.dart';

/// Morse Tool Page - Dual Mode (Encode/Decode) - Cyber-Duolingo Style
class MorseToolPage extends StatefulWidget {
  final SandiModel sandi;

  const MorseToolPage({super.key, required this.sandi});

  @override
  State<MorseToolPage> createState() => _MorseToolPageState();
}

class _MorseToolPageState extends State<MorseToolPage>
    with SingleTickerProviderStateMixin {
  // Theme Colors
  static const Color _bgDark = Color(0xFF0F172A);
  static const Color _neonGreen = Color(0xFF00E676); // New Neon Pulse
  static const Color _neonGreenDim = Color(0xFF00C853);
  static const Color _cardWhite = Colors.white;
  static const Color _textBlack = Colors.black87;

  // Controllers
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  late AnimationController _swapController;

  // State
  bool _isEncodeMode = true; // true = Text -> Morse, false = Morse -> Text

  @override
  void initState() {
    super.initState();
    MorseAudioService.initialize();
    _swapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      upperBound: 0.5, // Half rotation (180 deg)
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    _swapController.dispose();
    MorseAudioService.dispose();
    super.dispose();
  }

  void _onInputChanged(String val) {
    if (val.isEmpty) {
      _outputController.clear();
      return;
    }

    final cipher = MorseCipher(widget.sandi);
    String result = "";

    if (_isEncodeMode) {
      result = cipher.encrypt(val);
    } else {
      result = cipher.decrypt(val);
    }

    setState(() {
      _outputController.text = result;
    });
  }

  void _swapMode() {
    if (_swapController.isDismissed) {
      _swapController.forward();
    } else {
      _swapController.reverse();
    }

    setState(() {
      _isEncodeMode = !_isEncodeMode;
      // Swap content
      _inputController.text = _outputController.text;
      _onInputChanged(_inputController.text);
    });
  }

  void _playOutput() async {
    String morseToPlay = "";
    if (_isEncodeMode) {
      morseToPlay = _outputController.text;
    } else {
      morseToPlay = _inputController.text;
    }

    if (morseToPlay.isEmpty) return;

    for (int i = 0; i < morseToPlay.length; i++) {
      if (!mounted) break;
      String char = morseToPlay[i];

      if (char == '.') {
        await Future.wait([
          MorseAudioService.playDot(),
          MorseHapticService.playDot(),
        ]);
        await Future.delayed(const Duration(milliseconds: 200));
      } else if (char == '-') {
        await Future.wait([
          MorseAudioService.playDash(),
          MorseHapticService.playDash(),
        ]);
        await Future.delayed(const Duration(milliseconds: 400));
      } else if (char == ' ' || char == '/') {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
  }

  void _copyOutput() {
    if (_outputController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _outputController.text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Copied Result!", style: GoogleFonts.fredoka()),
          backgroundColor: _neonGreenDim,
          duration: const Duration(milliseconds: 1000),
        ),
      );
    }
  }

  void _addMorseChar(String char) {
    if (!_isEncodeMode) {
      final text = _inputController.text;
      final selection = _inputController.selection;

      String newText;
      int newOffset;

      if (selection.start >= 0) {
        newText = text.replaceRange(selection.start, selection.end, char);
        newOffset = selection.start + char.length;
      } else {
        newText = text + char;
        newOffset = newText.length;
      }

      _inputController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newOffset),
      );
      _onInputChanged(newText);
    }
  }

  void _backspaceMorse() {
    final text = _inputController.text;
    final selection = _inputController.selection;
    if (text.isEmpty) return;

    String newText;
    int newOffset;

    if (selection.start > 0) {
      newText = text.replaceRange(selection.start - 1, selection.end, "");
      newOffset = selection.start - 1;
    } else if (selection.start == 0 && selection.end > 0) {
      newText = text.replaceRange(selection.start, selection.end, "");
      newOffset = 0;
    } else {
      if (text.isNotEmpty) {
        newText = text.substring(0, text.length - 1);
        newOffset = newText.length;
      } else {
        return;
      }
    }

    _inputController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
    _onInputChanged(newText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          "MORSE TRANSLATOR",
          style: GoogleFonts.fredoka(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: _bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: [
                // 1. INPUT CARD
                _buildUnifiedCard(
                  isInput: true,
                  title: _isEncodeMode
                      ? "INPUT TEKS (ABC)"
                      : "INPUT MORSE (.-)",
                  controller: _inputController,
                ),

                const SizedBox(height: 20), // More spacing for swap button
                // SWAP BUTTON
                Center(
                  child: RotationTransition(
                    turns: _swapController,
                    child: GestureDetector(
                      onTap: _swapMode,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _neonGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: _neonGreenDim,
                              offset: Offset(0, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.swap_vert,
                          color: Colors.black,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20), // More spacing
                // 2. OUTPUT CARD
                _buildUnifiedCard(
                  isInput: false,
                  title: _isEncodeMode ? "OUTPUT MORSE" : "OUTPUT TEKS",
                  controller: _outputController,
                ),

                const SizedBox(height: 30),

                // ACTION BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      label: "SALIN",
                      icon: Icons.copy,
                      color: Colors.blue,
                      shadowColor: Colors.blue.shade900,
                      onTap: _copyOutput,
                    ),
                    const SizedBox(width: 20),
                    _buildActionButton(
                      label: "DENGAR",
                      icon: Icons.volume_up,
                      color: _neonGreenDim,
                      shadowColor: Colors.green.shade900,
                      onTap: _playOutput,
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (!_isEncodeMode) _buildMorseKeyboard(),
        ],
      ),
    );
  }

  // Unified Card for Input & Output (White 3D Card)
  Widget _buildUnifiedCard({
    required bool isInput,
    required String title,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.fredoka(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: _cardWhite,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: _neonGreen, // Neon Green Bottom Border (3D Effect)
                offset: Offset(0, 6), // 6px Thickness
                blurRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20), // 20px padding
          child: TextField(
            controller: controller,
            readOnly: !isInput, // Output is read-only
            onChanged: isInput ? _onInputChanged : null,
            style: isInput || !_isEncodeMode
                ? GoogleFonts.fredoka(
                    fontSize: 18,
                    color: _textBlack,
                    fontWeight: FontWeight.normal,
                  )
                // Output Morse uses Monospace but Dark/Black because card is white
                : GoogleFonts.sourceCodePro(
                    fontSize: 18,
                    color: _textBlack,
                    fontWeight: FontWeight.bold,
                  ),
            maxLines: isInput ? 3 : 5,
            minLines: isInput ? 1 : 3,
            decoration: InputDecoration(
              border: InputBorder.none, // Removed default border
              contentPadding: EdgeInsets.zero,
              hintText: isInput ? "Ketik di sini..." : "Hasil akan muncul...",
              hintStyle: GoogleFonts.fredoka(color: Colors.grey.shade400),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.fredoka(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMorseKeyboard() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF1E293B), // Slate footer
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(child: _buildMorseKey('.', "DOT", _neonGreen)),
            const SizedBox(width: 8),
            Expanded(child: _buildMorseKey('-', "DASH", Colors.orange)),
            const SizedBox(width: 8),
            Expanded(child: _buildMorseKey(' ', "SPASI", Colors.blue)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _backspaceMorse,
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.shade900,
                      offset: const Offset(0, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(Icons.backspace, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMorseKey(String char, String label, Color color) {
    return GestureDetector(
      onTap: () {
        _addMorseChar(char);
        if (char == '.') {
          MorseAudioService.playDot();
          MorseHapticService.playDot();
        } else if (char == '-') {
          MorseAudioService.playDash();
          MorseHapticService.playDash();
        }
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label == "DOT" || label == "DASH" ? char : label,
          style: GoogleFonts.sourceCodePro(
            fontSize: label == "DOT" || label == "DASH" ? 32 : 16,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
