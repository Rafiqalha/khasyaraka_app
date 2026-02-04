import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/theme/cyber_theme.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/widgets/cyber_container.dart';

/// Sandi Kimia Page
/// 
/// Chemical Cipher Tool that disguises Morse Code as Chemical Formulas
/// - Dot (.) = Vowels (O, I, A)
/// - Dash (-) = Consonants (H, C, N, S, K)
/// - Repetition uses Number Subscripts (e.g., O₃ for ...)
class SandiKimiaPage extends StatefulWidget {
  final SandiModel sandi;

  const SandiKimiaPage({
    super.key,
    required this.sandi,
  });

  @override
  State<SandiKimiaPage> createState() => _SandiKimiaPageState();
}

class _SandiKimiaPageState extends State<SandiKimiaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Encode mode
  final TextEditingController _encodeTextController = TextEditingController();
  String _encodedResult = '';

  // Decode mode
  final TextEditingController _decodeFormulaController = TextEditingController();
  String _decodedResult = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _encodeTextController.addListener(_onEncodeTextChanged);
    _decodeFormulaController.addListener(_onDecodeFormulaChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _encodeTextController.dispose();
    _decodeFormulaController.dispose();
    super.dispose();
  }

  void _onEncodeTextChanged() {
    final text = _encodeTextController.text;
    setState(() {
      _encodedResult = ChemicalCipherLogic.encode(text);
    });
  }

  void _onDecodeFormulaChanged() {
    final formula = _decodeFormulaController.text;
    setState(() {
      _decodedResult = ChemicalCipherLogic.decode(formula);
    });
  }

  void _onCopyEncoded() {
    if (_encodedResult.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _encodedResult));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Formula copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onInsertAtom(String atom) {
    final text = _decodeFormulaController.text;
    final selection = _decodeFormulaController.selection;
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      atom,
    );
    _decodeFormulaController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + atom.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A1F), // Dark teal background
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1A1F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.sandi.name.toUpperCase()} TOOL',
          style: GoogleFonts.orbitron(
            fontSize: 16,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: CyberTheme.neonCyan,
          labelColor: CyberTheme.neonCyan,
          unselectedLabelColor: CyberTheme.textSecondary,
          labelStyle: GoogleFonts.orbitron(
            fontSize: 12,
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
        children: [
          _buildEncodeTab(),
          _buildDecodeTab(),
        ],
      ),
    );
  }

  // ========== ENCODE TAB ==========

  Widget _buildEncodeTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Section
            CyberContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PLAINTEXT',
                    style: GoogleFonts.courierPrime(
                      fontSize: 10,
                      color: CyberTheme.neonCyan,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _encodeTextController,
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
            ),
            const SizedBox(height: 24),
            
            // Result Section (Periodic Table Style)
            Text(
              'CHEMICAL FORMULA',
              style: GoogleFonts.courierPrime(
                fontSize: 10,
                color: CyberTheme.neonCyan,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            _buildFormulaCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulaCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CyberTheme.neonCyan.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: CyberTheme.neonCyan.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FORMULA',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  color: CyberTheme.neonCyan,
                  letterSpacing: 2,
                ),
              ),
              if (_encodedResult.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.copy, color: CyberTheme.neonCyan),
                  onPressed: _onCopyEncoded,
                  tooltip: 'Copy',
                ),
            ],
          ),
          const SizedBox(height: 16),
          _encodedResult.isEmpty
              ? Text(
                  'Enter text above to generate formula...',
                  style: GoogleFonts.courierPrime(
                    fontSize: 14,
                    color: CyberTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                )
              : SelectableText(
                  _encodedResult,
                  style: GoogleFonts.courierPrime(
                    fontSize: 20,
                    color: Colors.white,
                    letterSpacing: 1,
                    height: 1.5,
                  ),
                ),
        ],
      ),
    );
  }

  // ========== DECODE TAB ==========

  Widget _buildDecodeTab() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Helper Chips Section
                  _buildHelperChips(),
                  const SizedBox(height: 16),
                  
                  // Formula Input Section
                  CyberContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CHEMICAL FORMULA',
                          style: GoogleFonts.courierPrime(
                            fontSize: 10,
                            color: CyberTheme.neonCyan,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _decodeFormulaController,
                          style: GoogleFonts.courierPrime(
                            fontSize: 16,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Paste formula here (e.g., H O₂ H)',
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
                  ),
                  const SizedBox(height: 24),
                  
                  // Decoded Result Section
                  Text(
                    'DECODED TEXT',
                    style: GoogleFonts.courierPrime(
                      fontSize: 10,
                      color: CyberTheme.neonCyan,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDecodedResultCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelperChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK INSERT',
          style: GoogleFonts.courierPrime(
            fontSize: 10,
            color: CyberTheme.neonCyan,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Common Atoms
            _buildHelperChip('H', 'Hydrogen'),
            _buildHelperChip('O', 'Oxygen'),
            _buildHelperChip('C', 'Carbon'),
            _buildHelperChip('N', 'Nitrogen'),
            _buildHelperChip('S', 'Sulfur'),
            _buildHelperChip('K', 'Potassium'),
            _buildHelperChip('I', 'Iodine'),
            _buildHelperChip('A', 'Argon'),
            // Subscripts
            _buildHelperChip('₂', 'Subscript 2', isSubscript: true),
            _buildHelperChip('₃', 'Subscript 3', isSubscript: true),
            _buildHelperChip('₄', 'Subscript 4', isSubscript: true),
            _buildHelperChip('₅', 'Subscript 5', isSubscript: true),
          ],
        ),
      ],
    );
  }

  Widget _buildHelperChip(String label, String tooltip, {bool isSubscript = false}) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () => _onInsertAtom(label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSubscript
                ? CyberTheme.alertOrange.withOpacity(0.2)
                : CyberTheme.neonCyan.withOpacity(0.2),
            border: Border.all(
              color: isSubscript
                  ? CyberTheme.alertOrange
                  : CyberTheme.neonCyan,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: GoogleFonts.courierPrime(
              fontSize: isSubscript ? 16 : 14,
              color: isSubscript
                  ? CyberTheme.alertOrange
                  : CyberTheme.neonCyan,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDecodedResultCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CyberTheme.neonCyan.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RESULT',
            style: GoogleFonts.orbitron(
              fontSize: 12,
              color: CyberTheme.neonCyan,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          _decodedResult.isEmpty
              ? Text(
                  'Enter formula above to decode...',
                  style: GoogleFonts.courierPrime(
                    fontSize: 14,
                    color: CyberTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                )
              : SelectableText(
                  _decodedResult,
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    color: Colors.white,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ],
      ),
    );
  }
}

/// Chemical Cipher Logic Helper Class
/// 
/// Handles encoding text to chemical formulas and decoding formulas back to text
class ChemicalCipherLogic {
  // Morse Code Dictionary: Text -> Morse
  static const Map<String, String> textToMorse = {
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

  // Reverse Dictionary: Morse -> Text
  static final Map<String, String> morseToText = {
    for (var entry in textToMorse.entries) entry.value: entry.key,
  };

  // Vowel mapping for Dots (.)
  static const List<String> vowels = ['O', 'I', 'A'];

  // Consonant mapping for Dashes (-)
  static const List<String> consonants = ['H', 'C', 'N', 'S', 'K'];

  // Subscript Unicode mapping
  static const Map<int, String> subscriptMap = {
    2: '\u2082', // ₂
    3: '\u2083', // ₃
    4: '\u2084', // ₄
    5: '\u2085', // ₅
    6: '\u2086', // ₆
    7: '\u2087', // ₇
    8: '\u2088', // ₈
    9: '\u2089', // ₉
  };

  /// Encode text to Chemical Formula
  /// 
  /// Steps:
  /// 1. Convert text to Morse Code
  /// 2. Beautify: Use real chemical atoms (O/I for dots, H/C/N for dashes)
  /// 3. Compress repetitions with subscripts
  /// 4. Join with " + " separator
  static String encode(String input) {
    if (input.trim().isEmpty) return '';

    final textUpper = input.toUpperCase();
    final morseParts = <String>[];

    // Step 1: Convert text to Morse Code
    for (var char in textUpper.split('')) {
      if (textToMorse.containsKey(char)) {
        morseParts.add(textToMorse[char]!);
      } else if (char == ' ') {
        morseParts.add(' '); // Space between words
      }
    }

    if (morseParts.isEmpty) return '';

    // Step 2 & 3: Convert Morse to Chemical with compression
    final chemicalParts = <String>[];

    for (var morse in morseParts) {
      if (morse == ' ') {
        // Space between words - add space separator
        if (chemicalParts.isNotEmpty) {
          chemicalParts.add(' ');
        }
      } else {
        // Process morse pattern with compression
        // Atoms within one letter are NOT separated by space
        final chemical = _morseToChemical(morse);
        if (chemical.isNotEmpty) {
          if (chemicalParts.isNotEmpty && !chemicalParts.last.endsWith(' ')) {
            chemicalParts.add(' '); // Use space to separate letters only
          }
          chemicalParts.add(chemical);
        }
      }
    }

    return chemicalParts.join('');
  }

  /// Convert Morse pattern to Chemical formula with compression
  /// 
  /// Example: "..." -> "O₃"
  /// Example: "-.." -> "HO₂" (no space between atoms in one letter)
  /// Example: ".-" -> "OH" (no space between atoms in one letter)
  static String _morseToChemical(String morse) {
    if (morse.isEmpty) return '';

    final result = <String>[];
    int i = 0;
    int vowelIndex = 0;
    int consonantIndex = 0;

    while (i < morse.length) {
      final char = morse[i];
      int count = 1;

      // Count consecutive same characters
      while (i + count < morse.length && morse[i + count] == char) {
        count++;
      }

      if (char == '.') {
        // Dot: Use vowel (O, I, A)
        final atom = vowels[vowelIndex % vowels.length];
        vowelIndex++;
        
        if (count > 1) {
          // Use subscript for repetition (e.g., ... -> O₃)
          final subscript = subscriptMap[count];
          if (subscript != null) {
            result.add('$atom$subscript');
          } else {
            // Fallback: repeat atom if subscript not available
            result.add(atom * count);
          }
        } else {
          result.add(atom);
        }
      } else if (char == '-') {
        // Dash: Use consonant (H, C, N, S, K)
        final atom = consonants[consonantIndex % consonants.length];
        consonantIndex++;
        
        if (count > 1) {
          // Use subscript for repetition (e.g., --- -> H₃)
          final subscript = subscriptMap[count];
          if (subscript != null) {
            result.add('$atom$subscript');
          } else {
            // Fallback: repeat atom if subscript not available
            result.add(atom * count);
          }
        } else {
          result.add(atom);
        }
      }

      i += count;
    }

    return result.join(''); // No space between atoms within one letter
  }

  /// Decode Chemical Formula to Text
  /// 
  /// Steps:
  /// 1. Parse formula (handle spaces and "+")
  /// 2. Identify vowels -> Dot, consonants -> Dash
  /// 3. Handle subscripts -> repeat previous signal n times
  /// 4. Convert Morse back to Text
  static String decode(String input) {
    if (input.trim().isEmpty) return '';

    // Step 1: Parse formula - split by " + " or spaces
    final parts = input
        .replaceAll(' + ', '|') // Replace " + " with separator
        .replaceAll(RegExp(r'\s+'), '|') // Replace spaces with separator
        .split('|')
        .where((part) => part.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) return '';

    // Step 2 & 3: Convert chemical parts to Morse
    final morseParts = <String>[];

    for (var part in parts) {
      final morse = _chemicalToMorse(part.trim());
      if (morse.isNotEmpty) {
        morseParts.add(morse);
      }
    }

    if (morseParts.isEmpty) return '';

    // Step 4: Convert Morse to Text
    final result = <String>[];
    for (var morse in morseParts) {
      if (morseToText.containsKey(morse)) {
        result.add(morseToText[morse]!);
      } else {
        result.add('?'); // Unknown pattern
      }
    }

    return result.join('');
  }

  /// Convert Chemical formula part to Morse pattern
  /// 
  /// Handles subscripts and atom identification
  static String _chemicalToMorse(String chemical) {
    if (chemical.isEmpty) return '';

    final morse = StringBuffer();
    int i = 0;

    while (i < chemical.length) {
      final char = chemical[i];

      // Check if it's a vowel (dot) or consonant (dash)
      if (vowels.contains(char.toUpperCase())) {
        // Check for subscript
        if (i + 1 < chemical.length) {
          final nextChar = chemical[i + 1];
          final subscriptValue = _getSubscriptValue(nextChar);
          
          if (subscriptValue != null) {
            // Found subscript - repeat dot
            morse.write('.' * subscriptValue);
            i += 2; // Skip atom and subscript
          } else {
            // Single dot
            morse.write('.');
            i++;
          }
        } else {
          // Single dot
          morse.write('.');
          i++;
        }
      } else if (consonants.contains(char.toUpperCase())) {
        // Check for subscript
        if (i + 1 < chemical.length) {
          final nextChar = chemical[i + 1];
          final subscriptValue = _getSubscriptValue(nextChar);
          
          if (subscriptValue != null) {
            // Found subscript - repeat dash
            morse.write('-' * subscriptValue);
            i += 2; // Skip atom and subscript
          } else {
            // Single dash
            morse.write('-');
            i++;
          }
        } else {
          // Single dash
          morse.write('-');
          i++;
        }
      } else {
        // Unknown character, skip
        i++;
      }
    }

    return morse.toString();
  }

  /// Get numeric value from subscript Unicode
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
