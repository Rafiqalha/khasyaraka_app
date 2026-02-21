import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/theme/cyber_theme.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/widgets/cyber_container.dart';

/// Sandi Koordinat (Coordinate Cipher) Tool
///
/// Uses a 6x6 grid with keywords in the first row and column.
/// Encodes letters to coordinate pairs (ColumnHeader + RowHeader).
class SandiKoordinatPage extends StatefulWidget {
  final SandiModel sandi;

  const SandiKoordinatPage({super.key, required this.sandi});

  @override
  State<SandiKoordinatPage> createState() => _SandiKoordinatPageState();
}

class _SandiKoordinatPageState extends State<SandiKoordinatPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _keyRowController = TextEditingController(
    text: 'MERAH',
  );
  final TextEditingController _keyColController = TextEditingController(
    text: 'PUTIH',
  );
  final TextEditingController _encodeController = TextEditingController();
  final TextEditingController _decodeController = TextEditingController();

  String _keyRow = 'MERAH';
  String _keyCol = 'PUTIH';
  String _currentEncodeChar = ''; // For highlighting
  Map<String, String> _coordinateMap =
      {}; // Letter -> Coordinate (e.g., 'A' -> 'MP')
  Map<String, String> _reverseMap =
      {}; // Coordinate -> Letter (e.g., 'MP' -> 'A')

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _keyRowController.addListener(_onKeyRowChanged);
    _keyColController.addListener(_onKeyColChanged);
    _encodeController.addListener(_onEncodeInputChanged);
    _decodeController.addListener(_onDecodeInputChanged);
    _generateMaps();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _keyRowController.dispose();
    _keyColController.dispose();
    _encodeController.dispose();
    _decodeController.dispose();
    super.dispose();
  }

  void _onKeyRowChanged() {
    final text = _keyRowController.text.toUpperCase().replaceAll(
      RegExp(r'[^A-Z]'),
      '',
    );
    if (text.length <= 5) {
      setState(() {
        _keyRowController.value = TextEditingValue(
          text: text,
          selection: _keyRowController.selection,
        );
        _keyRow = text;
        _generateMaps();
      });
    }
  }

  void _onKeyColChanged() {
    final text = _keyColController.text.toUpperCase().replaceAll(
      RegExp(r'[^A-Z]'),
      '',
    );
    if (text.length <= 5) {
      setState(() {
        _keyColController.value = TextEditingValue(
          text: text,
          selection: _keyColController.selection,
        );
        _keyCol = text;
        _generateMaps();
      });
    }
  }

  void _onEncodeInputChanged() {
    final text = _encodeController.text.toUpperCase();
    if (text.isNotEmpty) {
      final lastChar = text[text.length - 1];
      if (lastChar.codeUnitAt(0) >= 65 && lastChar.codeUnitAt(0) <= 90) {
        setState(() {
          _currentEncodeChar = lastChar;
        });
      } else {
        setState(() {
          _currentEncodeChar = '';
        });
      }
    } else {
      setState(() {
        _currentEncodeChar = '';
      });
    }
  }

  void _onDecodeInputChanged() {
    setState(() {});
  }

  void _generateMaps() {
    // Ensure keys are exactly 5 characters, pad with X if needed
    String keyRow = _keyRow.padRight(5, 'X').substring(0, 5).toUpperCase();
    String keyCol = _keyCol.padRight(5, 'X').substring(0, 5).toUpperCase();

    // Remove duplicates while preserving order
    keyRow = _removeDuplicates(keyRow);
    keyCol = _removeDuplicates(keyCol);

    // Pad again if needed after removing duplicates
    while (keyRow.length < 5) {
      keyRow += _getNextAvailableLetter(keyRow + keyCol);
    }
    while (keyCol.length < 5) {
      keyCol += _getNextAvailableLetter(keyRow + keyCol);
    }

    keyRow = keyRow.substring(0, 5);
    keyCol = keyCol.substring(0, 5);

    // Generate alphabet A-Y (25 letters for 5x5 grid)
    final alphabet = List.generate(
      25,
      (i) => String.fromCharCode(65 + i),
    ); // A-Y

    _coordinateMap.clear();
    _reverseMap.clear();

    // Fill the 5x5 grid with A-Y
    int letterIndex = 0;
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 5; col++) {
        if (letterIndex < alphabet.length) {
          final letter = alphabet[letterIndex];
          final coordinate = '${keyCol[col]}${keyRow[row]}';
          _coordinateMap[letter] = coordinate;
          _reverseMap[coordinate] = letter;
          letterIndex++;
        }
      }
    }

    setState(() {});
  }

  String _removeDuplicates(String text) {
    final seen = <String>{};
    final result = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      if (!seen.contains(char)) {
        seen.add(char);
        result.write(char);
      }
    }
    return result.toString();
  }

  String _getNextAvailableLetter(String used) {
    for (int i = 0; i < 26; i++) {
      final letter = String.fromCharCode(65 + i);
      if (!used.contains(letter)) {
        return letter;
      }
    }
    return 'X';
  }

  void _swapKeys() {
    setState(() {
      final temp = _keyRow;
      _keyRow = _keyCol;
      _keyCol = temp;
      _keyRowController.text = _keyRow;
      _keyColController.text = _keyCol;
      _generateMaps();
    });
  }

  void _onClear() {
    setState(() {
      if (_tabController.index == 0) {
        _encodeController.clear();
        _currentEncodeChar = '';
      } else {
        _decodeController.clear();
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

  String _encodeText(String text) {
    final upperText = text.toUpperCase();
    final result = <String>[];

    for (int i = 0; i < upperText.length; i++) {
      final char = upperText[i];
      if (char == ' ') {
        result.add(' ');
        continue;
      }
      if (char.codeUnitAt(0) >= 65 && char.codeUnitAt(0) <= 90) {
        // Handle Z as S (common in coordinate cipher)
        final letter = char == 'Z' ? 'S' : char;
        if (_coordinateMap.containsKey(letter)) {
          result.add(_coordinateMap[letter]!);
        }
      }
    }

    return result.join(' ');
  }

  String _decodeText(String text) {
    // Remove spaces and split into pairs
    final cleanText = text.replaceAll(' ', '').toUpperCase();
    final result = <String>[];

    for (int i = 0; i < cleanText.length; i += 2) {
      if (i + 1 < cleanText.length) {
        final pair = cleanText.substring(i, i + 2);
        if (_reverseMap.containsKey(pair)) {
          result.add(_reverseMap[pair]!);
        } else {
          result.add('?');
        }
      }
    }

    return result.join('');
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
          // Keyword Inputs
          CyberContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Keywords',
                      style: CyberTheme.headline().copyWith(fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: _swapKeys,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                            color: CyberTheme.neonCyan,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swap_horiz,
                              color: CyberTheme.neonCyan,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'SWAP',
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
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keyword 1 (Row Header)',
                            style: CyberTheme.body().copyWith(
                              color: CyberTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _keyRowController,
                            style: GoogleFonts.courierPrime(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                            decoration: InputDecoration(
                              hintText: 'MERAH',
                              hintStyle: GoogleFonts.courierPrime(
                                fontSize: 14,
                                color: CyberTheme.textSecondary,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: CyberTheme.neonCyan,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: CyberTheme.neonCyan,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: CyberTheme.neonCyan,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.3),
                            ),
                            maxLength: 5,
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keyword 2 (Column Header)',
                            style: CyberTheme.body().copyWith(
                              color: CyberTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _keyColController,
                            style: GoogleFonts.courierPrime(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                            decoration: InputDecoration(
                              hintText: 'PUTIH',
                              hintStyle: GoogleFonts.courierPrime(
                                fontSize: 14,
                                color: CyberTheme.textSecondary,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: CyberTheme.neonCyan,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: CyberTheme.neonCyan,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: CyberTheme.neonCyan,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.3),
                            ),
                            maxLength: 5,
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_keyRow.length < 5 || _keyCol.length < 5) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Keywords must be exactly 5 letters. Auto-filling...',
                    style: CyberTheme.body().copyWith(
                      color: Colors.yellow,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Coordinate Grid
          CyberContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coordinate Grid',
                  style: CyberTheme.headline().copyWith(fontSize: 16),
                ),
                const SizedBox(height: 16),
                _buildCoordinateGrid(),
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
          if (_encodeController.text.isNotEmpty) ...[
            CyberContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Encoded Coordinates',
                        style: CyberTheme.headline().copyWith(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.copy,
                          color: CyberTheme.neonCyan,
                        ),
                        onPressed: () {
                          final encoded = _encodeText(_encodeController.text);
                          _copyToClipboard(encoded);
                        },
                        tooltip: 'Copy',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    _encodeText(_encodeController.text),
                    style: GoogleFonts.courierPrime(
                      fontSize: 18,
                      color: Colors.white,
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
    );
  }

  Widget _buildDecodeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Keyword Inputs (same as encode)
          CyberContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Keywords',
                      style: CyberTheme.headline().copyWith(fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: _swapKeys,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                            color: CyberTheme.neonCyan,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swap_horiz,
                              color: CyberTheme.neonCyan,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'SWAP',
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
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keyword 1 (Row Header)',
                            style: CyberTheme.body().copyWith(
                              color: CyberTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _keyRowController,
                            style: GoogleFonts.courierPrime(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                            decoration: InputDecoration(
                              hintText: 'MERAH',
                              hintStyle: GoogleFonts.courierPrime(
                                fontSize: 14,
                                color: CyberTheme.textSecondary,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: CyberTheme.neonCyan,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: CyberTheme.neonCyan,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: CyberTheme.neonCyan,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.3),
                            ),
                            maxLength: 5,
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keyword 2 (Column Header)',
                            style: CyberTheme.body().copyWith(
                              color: CyberTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _keyColController,
                            style: GoogleFonts.courierPrime(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                            decoration: InputDecoration(
                              hintText: 'PUTIH',
                              hintStyle: GoogleFonts.courierPrime(
                                fontSize: 14,
                                color: CyberTheme.textSecondary,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: CyberTheme.neonCyan,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: CyberTheme.neonCyan,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: CyberTheme.neonCyan,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.3),
                            ),
                            maxLength: 5,
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Coordinate Grid
          CyberContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coordinate Grid',
                  style: CyberTheme.headline().copyWith(fontSize: 16),
                ),
                const SizedBox(height: 16),
                _buildCoordinateGrid(),
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
                      'Coordinate Pairs',
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
                  controller: _decodeController,
                  style: GoogleFonts.courierPrime(
                    fontSize: 18,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Enter coordinate pairs (e.g., MP UT IH AR AH)...',
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
          if (_decodeController.text.isNotEmpty) ...[
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
                      IconButton(
                        icon: const Icon(
                          Icons.copy,
                          color: CyberTheme.neonCyan,
                        ),
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

  Widget _buildCoordinateGrid() {
    // Ensure keys are exactly 5 characters
    String keyRow = _keyRow.padRight(5, 'X').substring(0, 5).toUpperCase();
    String keyCol = _keyCol.padRight(5, 'X').substring(0, 5).toUpperCase();

    keyRow = _removeDuplicates(keyRow);
    keyCol = _removeDuplicates(keyCol);

    while (keyRow.length < 5) {
      keyRow += _getNextAvailableLetter(keyRow + keyCol);
    }
    while (keyCol.length < 5) {
      keyCol += _getNextAvailableLetter(keyRow + keyCol);
    }

    keyRow = keyRow.substring(0, 5);
    keyCol = keyCol.substring(0, 5);

    // Get highlighted coordinates for current encode char
    String? highlightCoord;
    int? highlightRow;
    int? highlightCol;

    if (_currentEncodeChar.isNotEmpty &&
        _coordinateMap.containsKey(_currentEncodeChar)) {
      highlightCoord = _coordinateMap[_currentEncodeChar];
      if (highlightCoord != null && highlightCoord.length == 2) {
        final colChar = highlightCoord[0];
        final rowChar = highlightCoord[1];
        highlightCol = keyCol.indexOf(colChar);
        highlightRow = keyRow.indexOf(rowChar);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        border: TableBorder.all(
          color: CyberTheme.neonCyan.withOpacity(0.3),
          width: 1,
        ),
        children: [
          // Header row (with empty corner cell)
          TableRow(
            children: [
              _buildGridCell('', isHeader: true, isCorner: true),
              for (int i = 0; i < 5; i++)
                _buildGridCell(
                  keyRow[i],
                  isHeader: true,
                  isHighlighted: highlightRow == i,
                ),
            ],
          ),
          // Data rows
          for (int row = 0; row < 5; row++)
            TableRow(
              children: [
                _buildGridCell(
                  keyCol[row],
                  isHeader: true,
                  isHighlighted: highlightCol == row,
                ),
                for (int col = 0; col < 5; col++)
                  _buildGridCell(
                    _getCellLetter(row, col),
                    isHighlighted: highlightRow == col && highlightCol == row,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildGridCell(
    String content, {
    bool isHeader = false,
    bool isCorner = false,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCorner
            ? Colors.transparent
            : isHeader
            ? CyberTheme.neonCyan.withOpacity(0.2)
            : isHighlighted
            ? Colors.yellow.withOpacity(0.3)
            : Colors.transparent,
        border: isHighlighted
            ? Border.all(color: Colors.yellow, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          content,
          style: GoogleFonts.courierPrime(
            fontSize: isHeader ? 16 : 14,
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            color: isHeader
                ? CyberTheme.neonCyan
                : isHighlighted
                ? Colors.yellow
                : Colors.white,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  String _getCellLetter(int row, int col) {
    // Calculate letter index: row * 5 + col
    final index = row * 5 + col;
    if (index < 25) {
      return String.fromCharCode(65 + index); // A-Y
    }
    return '';
  }
}
