import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/theme/cyber_theme.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/widgets/cyber_container.dart';

/// Sandi AND (Insertion Cipher) Tool
/// 
/// Encodes by appending "AND" after every letter.
/// Example: "AKU" -> "AAND KAND UAND"
/// Decodes by removing all "AND" occurrences.
class SandiAndPage extends StatefulWidget {
  final SandiModel sandi;

  const SandiAndPage({
    super.key,
    required this.sandi,
  });

  @override
  State<SandiAndPage> createState() => _SandiAndPageState();
}

class _SandiAndPageState extends State<SandiAndPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _encodeController = TextEditingController();
  final TextEditingController _decodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _encodeController.addListener(_onEncodeInputChanged);
    _decodeController.addListener(_onDecodeInputChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _encodeController.dispose();
    _decodeController.dispose();
    super.dispose();
  }

  void _onEncodeInputChanged() {
    setState(() {});
  }

  void _onDecodeInputChanged() {
    setState(() {});
  }

  void _onClearEncode() {
    setState(() {
      _encodeController.clear();
    });
  }

  void _onClearDecode() {
    setState(() {
      _decodeController.clear();
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

  /// Encode (Scout Sandi AND style):
  /// - Consonant(s) come first, followed by a vowel.
  /// - Insert "and" right before the vowel.
  ///
  /// Examples:
  /// - "kamu" -> "kanda mandu"   (ka -> k + and + a, mu -> m + and + u)
  /// - "pra"  -> "pranda"       (pra -> pr + and + a)
  /// If a word ends with consonant(s) without a vowel, we append a filler 'a'
  /// so the result never ends with a consonant.
  String _encodeText(String text) {
    if (text.isEmpty) return '';

    final words = text.split(RegExp(r'\s+'));
    final outWords = <String>[];

    bool _isVowel(String ch) {
      final c = ch.toLowerCase();
      return c == 'a' || c == 'i' || c == 'u' || c == 'e' || c == 'o';
    }

    for (final rawWord in words) {
      if (rawWord.trim().isEmpty) continue;

      // Keep only letters in the word (ignore punctuation for now)
      final letters = rawWord
          .split('')
          .where((c) => RegExp(r'[A-Za-z]').hasMatch(c))
          .toList();
      if (letters.isEmpty) continue;

      final parts = <String>[];
      final consonantBuf = StringBuffer();

      for (final ch in letters) {
        if (_isVowel(ch)) {
          final onset = consonantBuf.toString();
          consonantBuf.clear();

          // If word starts with vowel (no onset), we still encode as: and + vowel
          // (best-effort; common pramuka examples usually start with consonant).
          if (onset.isEmpty) {
            parts.add('and$ch');
          } else {
            parts.add('$onset' 'and' '$ch');
          }
        } else {
          consonantBuf.write(ch);
        }
      }

      // Trailing consonants without vowel -> append filler vowel 'a'
      if (consonantBuf.isNotEmpty) {
        parts.add('${consonantBuf}and' 'a');
      }

      outWords.add(parts.join(' '));
    }

    return outWords.join(' ');
  }

  /// Decode: Remove all "AND" occurrences from each word (case-insensitive)
  /// Example: "ANDAN ANDAK PRANDA MANDU" -> "AN AK PRA MU"
  /// Logic: Remove "AND" from each word, then join the remaining letters
  String _decodeText(String text) {
    if (text.isEmpty) return '';
    
    // Split by spaces to get individual words
    final words = text.split(RegExp(r'\s+'));
    
    final result = <String>[];
    for (final word in words) {
      if (word.isEmpty) continue;
      
      // Remove all "AND" occurrences (case-insensitive) from each word
      final cleaned = word.replaceAll(RegExp('AND', caseSensitive: false), '');
      if (cleaned.isNotEmpty) {
        result.add(cleaned);
      }
    }
    
    // Join all decoded words with spaces
    return result.join(' ');
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
            Tab(text: 'BUAT SANDI (ENCODE)'),
            Tab(text: 'BACA SANDI (DECODE)'),
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

  Widget _buildEncodeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Box
          CyberContainer(
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: CyberTheme.neonCyan,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tip: Konsonan dulu, lalu vokal. \"and\" disisipkan sebelum vokal (contoh: pra → pranda).',
                    style: CyberTheme.body().copyWith(
                      color: CyberTheme.textSecondary,
                      fontSize: 12,
                    ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Masukkan Pesan Asli',
                      style: CyberTheme.headline().copyWith(fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear, color: CyberTheme.neonCyan, size: 20),
                      onPressed: _onClearEncode,
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
                    hintText: 'Contoh: ANAK PRAMUKA',
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

          // Output Section
          if (_encodeController.text.isNotEmpty) ...[
            CyberContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hasil Sandi AND',
                        style: CyberTheme.headline().copyWith(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: CyberTheme.neonCyan),
                        onPressed: () {
                          final encoded = _encodeText(_encodeController.text);
                          _copyToClipboard(encoded);
                        },
                        tooltip: 'Copy',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildHighlightedOutput(_encodeText(_encodeController.text)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDecodeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Box
          CyberContainer(
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: CyberTheme.neonCyan,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tip: Hapus semua kata "AND" untuk membaca pesan asli!',
                    style: CyberTheme.body().copyWith(
                      color: CyberTheme.textSecondary,
                      fontSize: 12,
                    ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Masukkan Kode AND',
                      style: CyberTheme.headline().copyWith(fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear, color: CyberTheme.neonCyan, size: 20),
                      onPressed: _onClearDecode,
                      tooltip: 'Clear',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _decodeController,
                  style: GoogleFonts.courierPrime(
                    fontSize: 18,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Contoh: ANDAN ANDAK PRANDA MANDU',
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

          // Output Section
          if (_decodeController.text.isNotEmpty) ...[
            CyberContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hasil Pesan Asli',
                        style: CyberTheme.headline().copyWith(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: CyberTheme.neonCyan),
                        onPressed: () {
                          final decoded = _decodeText(_decodeController.text);
                          if (decoded.isNotEmpty) {
                            _copyToClipboard(decoded);
                          }
                        },
                        tooltip: 'Copy',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      _decodeText(_decodeController.text),
                      style: GoogleFonts.courierPrime(
                        fontSize: 20,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHighlightedOutput(String text) {
    // Highlight "AND" in yellow/amber, rest in white.
    // IMPORTANT: We must not lose the matched "AND" segments (String.split discards matches).
    final regExp = RegExp('AND', caseSensitive: false);
    final spans = <TextSpan>[];

    int lastIndex = 0;
    for (final match in regExp.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: GoogleFonts.courierPrime(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: GoogleFonts.courierPrime(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
            letterSpacing: 1.5,
          ),
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastIndex),
          style: GoogleFonts.courierPrime(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText.rich(
        TextSpan(
          children: spans,
        ),
      ),
    );
  }
}
