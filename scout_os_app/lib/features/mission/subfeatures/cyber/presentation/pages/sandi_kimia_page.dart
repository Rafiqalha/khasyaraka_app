import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/cipher/morse_cipher.dart';

/// Sandi Kimia Page - Redesigned with Gamified/Duolingo Style
///
/// Theme: Science Purple & Dark Slate
/// Logic: Preserved from original
class SandiKimiaPage extends StatefulWidget {
  final SandiModel sandi;

  const SandiKimiaPage({super.key, required this.sandi});

  @override
  State<SandiKimiaPage> createState() => _SandiKimiaPageState();
}

class _SandiKimiaPageState extends State<SandiKimiaPage> {
  // Logic Controllers
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Logic State
  bool _isEncryptMode =
      true; // true = Text to Chemical, false = Chemical to Text
  String _previousText = '';
  String _decodedText = '';
  String _chemicalResult = ''; // Holds the result for both modes (Output)

  // Colors - Science Purple Theme
  static const Color _bgDark = Color(0xFF0F172A);
  static const Color _sciencePurple = Color(0xFF9C27B0); // Purple (Primary)
  static const Color _lightPurple = Color(0xFFE1BEE7); // Light Purple (Accent)
  static const Color _darkPurple = Color(0xFF7B1FA2); // Dark Purple (Shadow)
  static const Color _cardWhite = Colors.white;
  static const Color _textBlack = Colors.black87;

  // Element Button Colors
  static const Color _atomBlue = Color(0xFF2196F3);
  static const Color _atomOrange = Color(0xFFFF9800);
  static const Color _subscriptGreen = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      if (_isEncryptMode) {
        _chemicalResult = ChemicalCipherLogic.encode(_textController.text);
      } else {
        // In decode mode, text controller holds the chemical formula
        _chemicalResult = ChemicalCipherLogic.decode(_textController.text);
      }
    });
  }

  void _toggleMode() {
    setState(() {
      _isEncryptMode = !_isEncryptMode;
      _textController.clear();
      _chemicalResult = '';
      _decodedText = '';
    });
  }

  void _copyToClipboard() {
    if (_chemicalResult.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _chemicalResult));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Copied to Clipboard!", style: GoogleFonts.fredoka()),
          backgroundColor: _sciencePurple,
          duration: const Duration(milliseconds: 1000),
        ),
      );
    }
  }

  void _onClear() {
    setState(() {
      _textController.clear();
      _chemicalResult = '';
    });
  }

  // --- DECODE KEYBOARD LOGIC ---

  void _insertText(String text) {
    final currentText = _textController.text;
    final selection = _textController.selection;

    String newText;
    int newOffset;

    if (selection.isValid && selection.start >= 0) {
      newText = currentText.replaceRange(selection.start, selection.end, text);
      newOffset = selection.start + text.length;
    } else {
      newText = currentText + text;
      newOffset = newText.length;
    }

    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  void _backspace() {
    final currentText = _textController.text;
    final selection = _textController.selection;

    if (currentText.isEmpty) return;

    String newText;
    int newOffset;

    if (selection.isValid && selection.start > 0) {
      if (!selection.isCollapsed) {
        newText = currentText.replaceRange(selection.start, selection.end, '');
        newOffset = selection.start;
      } else {
        newText = currentText.replaceRange(
          selection.start - 1,
          selection.start,
          '',
        );
        newOffset = selection.start - 1;
      }
    } else {
      newText = currentText.substring(0, currentText.length - 1);
      newOffset = newText.length;
    }

    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  // --- UI BUILD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.science, color: _lightPurple),
            const SizedBox(width: 8),
            Text(
              "SANDI KIMIA",
              style: GoogleFonts.fredoka(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: [
                // MODE TOGGLE
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildModeBtn("ENCODE", _isEncryptMode)),
                      Expanded(child: _buildModeBtn("DECODE", !_isEncryptMode)),
                    ],
                  ),
                ),

                // 1. INPUT CARD (Upper)
                _buildUnifiedCard(
                  title: _isEncryptMode ? "INPUT PESAN" : "INPUT FORMULA KIMIA",
                  child: TextField(
                    controller: _textController,
                    style: GoogleFonts.fredoka(fontSize: 18, color: _textBlack),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: _isEncryptMode
                          ? "Ketik pesan..."
                          : "Gunakan tombol di bawah...",
                      hintStyle: GoogleFonts.fredoka(
                        color: Colors.grey.shade400,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: 3,
                    minLines: 1,
                    readOnly:
                        !_isEncryptMode, // Read only in decode mode (use custom keyboard)
                  ),
                ),

                const SizedBox(height: 24),

                // 2. OUTPUT CARD (Lower)
                _buildUnifiedCard(
                  title: _isEncryptMode ? "HASIL FORMULA" : "HASIL TERJEMAHAN",
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 80),
                    width: double.infinity,
                    child: _chemicalResult.isEmpty
                        ? Center(
                            child: Text(
                              "Hasil akan muncul di sini...",
                              style: GoogleFonts.fredoka(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          )
                        : SelectableText(
                            _chemicalResult,
                            style: GoogleFonts.fredoka(
                              fontSize: 22,
                              color: _isEncryptMode
                                  ? _sciencePurple
                                  : _textBlack,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),

                // ACTION BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      "SALIN",
                      Icons.copy,
                      Colors.blue,
                      _copyToClipboard,
                    ),
                    const SizedBox(width: 20),
                    _buildActionButton(
                      "HAPUS",
                      Icons.delete_outline,
                      Colors.redAccent,
                      _onClear,
                    ),
                  ],
                ),

                // Space for bottom keyboard in decode mode
                if (!_isEncryptMode) const SizedBox(height: 300),
              ],
            ),
          ),

          // DECODE KEYBOARD (Only if Decode Mode)
          if (!_isEncryptMode) _buildChemicalKeyboard(),
        ],
      ),
    );
  }

  Widget _buildUnifiedCard({required String title, required Widget child}) {
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
                color: _sciencePurple, // Purple shadow
                offset: Offset(0, 6),
                blurRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ],
    );
  }

  Widget _buildModeBtn(String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (!isActive) _toggleMode();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? _sciencePurple : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.fredoka(
            color: isActive ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.6),
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

  Widget _buildChemicalKeyboard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 24), // Reduced side margins
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        // Ensure safety on bottom devices
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: Vowels (Dots) + Backspace
            Row(
              children: [
                _buildExpandedKey("O", _atomBlue),
                _buildExpandedKey("I", _atomBlue),
                _buildExpandedKey("A", _atomBlue),
                _buildExpandedKeyButton(
                  icon: Icons.backspace,
                  color: Colors.redAccent,
                  onTap: _backspace,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Row 2: Consonants (Dashes)
            Row(
              children: [
                _buildExpandedKey("H", _atomOrange),
                _buildExpandedKey("C", _atomOrange),
                _buildExpandedKey("N", _atomOrange),
                _buildExpandedKey("S", _atomOrange),
                _buildExpandedKey("K", _atomOrange),
              ],
            ),
            const SizedBox(height: 10),

            // Row 3: Subscripts 2-5
            Row(
              children: [
                _buildExpandedKey("₂", _subscriptGreen, value: "\u2082"),
                _buildExpandedKey("₃", _subscriptGreen, value: "\u2083"),
                _buildExpandedKey("₄", _subscriptGreen, value: "\u2084"),
                _buildExpandedKey("₅", _subscriptGreen, value: "\u2085"),
              ],
            ),
            const SizedBox(height: 10),

            // Row 4: Subscripts 6-9
            Row(
              children: [
                _buildExpandedKey("₆", _subscriptGreen, value: "\u2086"),
                _buildExpandedKey("₇", _subscriptGreen, value: "\u2087"),
                _buildExpandedKey("₈", _subscriptGreen, value: "\u2088"),
                _buildExpandedKey("₉", _subscriptGreen, value: "\u2089"),
              ],
            ),
            const SizedBox(height: 10),

            // Row 5: Controls (+ and Space)
            Row(
              children: [
                _buildExpandedKey(" + ", Colors.blueGrey, flex: 1), // Separator
                _buildExpandedKey(
                  "SPASI",
                  _sciencePurple,
                  flex: 3,
                  value: " ",
                ), // Space
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedKey(
    String label,
    Color color, {
    String? value,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 2,
        ), // Tighter 2px margin
        child: _buildKeyButton(
          label: label,
          color: color,
          onTap: () => _insertText(value ?? label),
        ),
      ),
    );
  }

  Widget _buildExpandedKeyButton({
    IconData? icon,
    required Color color,
    required VoidCallback onTap,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: _buildKeyButton(icon: icon, color: color, onTap: onTap),
      ),
    );
  }

  Widget _buildKeyButton({
    String? label,
    IconData? icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52, // Taller buttons
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
        child: icon != null
            ? Icon(icon, color: Colors.white, size: 24)
            : Text(
                label!,
                style: GoogleFonts.fredoka(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
      ),
    );
  }
}

/// Chemical Cipher Logic Helper Class (Preserved)
class ChemicalCipherLogic {
  static const Map<String, String> textToMorse = {
    'A': '.-',
    'B': '-...',
    'C': '-.-.',
    'D': '-..',
    'E': '.',
    'F': '..-.',
    'G': '--.',
    'H': '....',
    'I': '..',
    'J': '.---',
    'K': '-.-',
    'L': '.-..',
    'M': '--',
    'N': '-.',
    'O': '---',
    'P': '.--.',
    'Q': '--.-',
    'R': '.-.',
    'S': '...',
    'T': '-',
    'U': '..-',
    'V': '...-',
    'W': '.--',
    'X': '-..-',
    'Y': '-.--',
    'Z': '--..',
    '0': '-----',
    '1': '.----',
    '2': '..---',
    '3': '...--',
    '4': '....-',
    '5': '.....',
    '6': '-....',
    '7': '--...',
    '8': '---..',
    '9': '----.',
    ' ': ' ',
  };

  static final Map<String, String> morseToText = {
    for (var entry in textToMorse.entries) entry.value: entry.key,
  };

  static const List<String> vowels = ['O', 'I', 'A'];
  static const List<String> consonants = ['H', 'C', 'N', 'S', 'K'];

  static const Map<int, String> subscriptMap = {
    2: '\u2082',
    3: '\u2083',
    4: '\u2084',
    5: '\u2085',
    6: '\u2086',
    7: '\u2087',
    8: '\u2088',
    9: '\u2089',
  };

  static String encode(String input) {
    if (input.trim().isEmpty) return '';
    final textUpper = input.toUpperCase();
    final morseParts = <String>[];
    for (var char in textUpper.split('')) {
      if (textToMorse.containsKey(char)) {
        morseParts.add(textToMorse[char]!);
      } else if (char == ' ') {
        morseParts.add(' ');
      }
    }
    if (morseParts.isEmpty) return '';
    final chemicalParts = <String>[];
    for (var morse in morseParts) {
      if (morse == ' ') {
        if (chemicalParts.isNotEmpty) {
          chemicalParts.add(' ');
        }
      } else {
        final chemical = _morseToChemical(morse);
        if (chemical.isNotEmpty) {
          if (chemicalParts.isNotEmpty && !chemicalParts.last.endsWith(' ')) {
            chemicalParts.add(' + ');
          }
          chemicalParts.add(chemical);
        }
      }
    }
    return chemicalParts.join('');
  }

  static String _morseToChemical(String morse) {
    if (morse.isEmpty) return '';
    final result = <String>[];
    int i = 0;
    int vowelIndex = 0;
    int consonantIndex = 0;
    while (i < morse.length) {
      final char = morse[i];
      int count = 1;
      while (i + count < morse.length && morse[i + count] == char) {
        count++;
      }
      if (char == '.') {
        final atom = vowels[vowelIndex % vowels.length];
        vowelIndex++;
        if (count > 1) {
          final subscript = subscriptMap[count];
          if (subscript != null)
            result.add('$atom$subscript');
          else
            result.add(atom * count);
        } else {
          result.add(atom);
        }
      } else if (char == '-') {
        final atom = consonants[consonantIndex % consonants.length];
        consonantIndex++;
        if (count > 1) {
          final subscript = subscriptMap[count];
          if (subscript != null)
            result.add('$atom$subscript');
          else
            result.add(atom * count);
        } else {
          result.add(atom);
        }
      }
      i += count;
    }
    return result.join('');
  }

  static String decode(String input) {
    if (input.trim().isEmpty) return '';
    final parts = input
        .replaceAll(' + ', '|')
        .replaceAll(RegExp(r'\s{2,}'), ' | ')
        .replaceAll(RegExp(r'\s+'), '|')
        .split('|')
        .where((part) => part.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    final morseParts = <String>[];
    for (var part in parts) {
      final morse = _chemicalToMorse(part.trim());
      if (morse.isNotEmpty) {
        morseParts.add(morse);
      }
    }
    if (morseParts.isEmpty) return '';
    final result = <String>[];
    for (var morse in morseParts) {
      if (morseToText.containsKey(morse)) {
        result.add(morseToText[morse]!);
      } else {
        result.add('?');
      }
    }
    return result.join('');
  }

  static String _chemicalToMorse(String chemical) {
    if (chemical.isEmpty) return '';
    final morse = StringBuffer();
    int i = 0;
    while (i < chemical.length) {
      final char = chemical[i];
      if (vowels.contains(char.toUpperCase())) {
        if (i + 1 < chemical.length) {
          final nextChar = chemical[i + 1];
          final subscriptValue = _getSubscriptValue(nextChar);
          if (subscriptValue != null) {
            morse.write('.' * subscriptValue);
            i += 2;
          } else {
            morse.write('.');
            i++;
          }
        } else {
          morse.write('.');
          i++;
        }
      } else if (consonants.contains(char.toUpperCase())) {
        if (i + 1 < chemical.length) {
          final nextChar = chemical[i + 1];
          final subscriptValue = _getSubscriptValue(nextChar);
          if (subscriptValue != null) {
            morse.write('-' * subscriptValue);
            i += 2;
          } else {
            morse.write('-');
            i++;
          }
        } else {
          morse.write('-');
          i++;
        }
      } else {
        i++;
      }
    }
    return morse.toString();
  }

  static int? _getSubscriptValue(String subscript) {
    final subscriptToNumber = {
      '\u2082': 2,
      '\u2083': 3,
      '\u2084': 4,
      '\u2085': 5,
      '\u2086': 6,
      '\u2087': 7,
      '\u2088': 8,
      '\u2089': 9,
    };
    return subscriptToNumber[subscript];
  }
}
