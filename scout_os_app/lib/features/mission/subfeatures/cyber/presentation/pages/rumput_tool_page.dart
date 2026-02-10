import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/widgets/sandi_rumput_view.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/cipher/morse_cipher.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/services/morse_audio_service.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/services/morse_haptic_service.dart';

/// Rumput Tool Page - Redesigned with Cyber-Duolingo Style
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
  // Logic Controllers
  final TextEditingController _textController = TextEditingController();
  final ScrollController _graphScrollController = ScrollController();
  
  // Logic State
  bool _isEncryptMode = true; // true = Text to Rumput, false = Rumput to Text
  String _previousText = ''; 
  String _rawMorseSequence = ''; 
  String _currentLetterBuffer = ''; 
  String _decodedText = ''; 

  // Colors
  static const Color _bgDark = Color(0xFF0F172A);
  static const Color _forestGreen = Color(0xFF2E7D32); // Hijau Hutan (Darker)
  static const Color _grassGreen = Color(0xFF4CAF50);  // Hijau Rumput (Brighter)
  static const Color _cardWhite = Colors.white;
  static const Color _textBlack = Colors.black87;

  // Dictionary (Preserved from original)
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

  // Reverse mapping for backspace logic
  static final Map<String, String> alphabetToMorse = {
    for (var entry in morseToAlphabet.entries) entry.value: entry.key,
  };

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    MorseAudioService.initialize();
  }

  @override
  void dispose() {
    _textController.dispose();
    _graphScrollController.dispose();
    MorseAudioService.dispose();
    super.dispose();
  }

  // --- LOGIC SECTION ---

  void _onTextChanged() {
    if (_isEncryptMode) {
      final currentText = _textController.text;
      setState(() {}); // Trigger rebuild for visual
      
      if (currentText.length > _previousText.length) {
        final newChars = currentText.substring(_previousText.length);
        _playFeedbackForText(newChars);
      }
      _previousText = currentText;
    }
  }

  Future<void> _playFeedbackForText(String text) async {
    if (text.isEmpty) return;
    try {
      // Using temporary MorseCipher just for lookup logic, logic preserved.
      for (int i = 0; i < text.length; i++) {
        final char = text[i].toUpperCase();
        if (char == ' ') {
          await Future.delayed(const Duration(milliseconds: 300));
          continue;
        }
        String pattern = '';
        if (MorseCipher.textToMorse.containsKey(char)) {
          pattern = MorseCipher.textToMorse[char]!;
        }
        if (pattern.isNotEmpty) {
          for (int j = 0; j < pattern.length; j++) {
            final symbol = pattern[j];
            if (symbol == '.') {
              await Future.wait([MorseAudioService.playDot(), MorseHapticService.playDot()]);
            } else if (symbol == '-') {
              await Future.wait([MorseAudioService.playDash(), MorseHapticService.playDash()]);
            }
            if (j < pattern.length - 1) await Future.delayed(const Duration(milliseconds: 100));
          }
        }
        if (i < text.length - 1) await Future.delayed(const Duration(milliseconds: 200));
      }
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  void _onClear() {
    setState(() {
      if (_isEncryptMode) {
        _textController.clear();
        _previousText = '';
      } else {
        _rawMorseSequence = '';
        _currentLetterBuffer = '';
        _decodedText = '';
      }
    });
  }

  void _copyToClipboard() {
    String textToCopy = _isEncryptMode ? _textController.text : _decodedText;

    if (textToCopy.isNotEmpty) {
       Clipboard.setData(ClipboardData(text: textToCopy));
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Copied to Clipboard!", style: GoogleFonts.fredoka()),
          backgroundColor: _forestGreen,
          duration: const Duration(milliseconds: 1000),
        ),
      );
    }
  }

  void _toggleMode() {
    setState(() {
      _isEncryptMode = !_isEncryptMode;
      _textController.clear();
      _previousText = '';
      _rawMorseSequence = '';
      _currentLetterBuffer = '';
      _decodedText = '';
    });
  }

  // Logic for Decode Buttons
  void _onShortGrassPressed() { _addSignal('.'); }
  void _onTallGrassPressed() { _addSignal('-'); }
  
  void _addSignal(String signal) {
    setState(() {
      _currentLetterBuffer += signal;
      _rawMorseSequence += signal;
      if (signal == '.') {
         Future.wait([MorseAudioService.playDot(), MorseHapticService.playDot()]);
      } else {
         Future.wait([MorseAudioService.playDash(), MorseHapticService.playDash()]);
      }
      _scrollGraphToEnd();
    });
  }

  void _onSeparatorPressed() {
    setState(() {
      // Logic Spasi Pintar (Smart Space)
      if (_currentLetterBuffer.isNotEmpty) {
        // Jika ada buffer huruf, selesaikan huruf tersebut
        final letter = morseToAlphabet[_currentLetterBuffer] ?? '?';
        _decodedText += letter;
        
        // Reset buffer
        _currentLetterBuffer = '';
        
        // Visual separator di graph
        if (!_rawMorseSequence.endsWith(' ')) _rawMorseSequence += ' '; 
        
      } else {
        // Jika buffer kosong, berarti user menekan spasi lagi -> Spasi Kalimat
        if (_decodedText.isNotEmpty && !_decodedText.endsWith(' ')) {
           _decodedText += ' ';
           
           // Tambah indikator spasi di visual morse (gap)
           // Kita pakai 3 spasi untuk word gap di visual
           if (!_rawMorseSequence.endsWith('   ')) _rawMorseSequence += '   ';
        }
      }
      _scrollGraphToEnd();
    });
  }

  void _onBackspacePressed() {
    setState(() {
      // 1. Jika sedang mengetik huruf (Buffer tidak kosong)
      if (_currentLetterBuffer.isNotEmpty) {
        // Hapus karakter terakhir dari buffer dan sequence
        _currentLetterBuffer = _currentLetterBuffer.substring(0, _currentLetterBuffer.length - 1);
        if (_rawMorseSequence.isNotEmpty) {
          _rawMorseSequence = _rawMorseSequence.substring(0, _rawMorseSequence.length - 1);
        }
      } 
      // 2. Jika buffer kosong, tapi ada teks yang sudah didecode
      else if (_decodedText.isNotEmpty) {
        // Cek karakter terakhir
        final lastChar = _decodedText[_decodedText.length - 1];

        // Hapus karakter terakhir dari teks
        _decodedText = _decodedText.substring(0, _decodedText.length - 1);

        // Hapus visual separator spasi/gap trailing jika ada
        _rawMorseSequence = _rawMorseSequence.trimRight(); // Hapus spasi separator token/word
        
        // Logic "Edit Ulang" (Undo finish letter)
        // Jika karakter yang dihapus adalah huruf (bukan spasi), kembalikan ke buffer
        if (lastChar != ' ') {
           final morseBack = alphabetToMorse[lastChar.toUpperCase()];
           if (morseBack != null) {
              _currentLetterBuffer = morseBack;
              // Note: _rawMorseSequence sudah kita trimRight, jadi huruf yg baru dihapus masih ada di sana (tanpa separator).
              // Kita perlu pastikan sequence match buffer.
              // Karena visual sequence tidak kita hapus hurufnya, hanya separatornya.
              // Jadi logika trimRight harusnya aman.
              // Contoh: ".- " -> Delete -> "A" hilang. Seq ".-" (space gone). Buffer ".-". Correct.
           }
        }
      }
      // 3. Cleanup sequence jika kosong
      if (_decodedText.isEmpty && _currentLetterBuffer.isEmpty) {
        _rawMorseSequence = '';
      }

      _scrollGraphToEnd();
    });
  }

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

  // --- UI SECTION (REDESIGNED) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.grass, color: _grassGreen),
            const SizedBox(width: 8),
            Text("SANDI RUMPUT", style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.bold)),
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: [
                 // MODE TOGGLE
                 Container(
                   margin: const EdgeInsets.only(bottom: 20),
                   padding: const EdgeInsets.all(4),
                   decoration: BoxDecoration(
                     color: Colors.black26, 
                     borderRadius: BorderRadius.circular(16)
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
                    title: _isEncryptMode ? "INPUT PESAN" : "INPUT RUMPUT (VISUAL)",
                    child: _isEncryptMode 
                       ? TextField(
                           controller: _textController,
                           style: GoogleFonts.fredoka(fontSize: 18, color: _textBlack),
                           decoration: InputDecoration(
                             border: InputBorder.none,
                             hintText: "Ketik pesan di sini...",
                             hintStyle: GoogleFonts.fredoka(color: Colors.grey.shade400),
                             contentPadding: EdgeInsets.zero,
                           ),
                           maxLines: 3,
                           minLines: 1,
                         )
                       // FIXED: Use Visual View for Decode Input instead of Text
                       : Container(
                           height: 80,
                           alignment: Alignment.centerLeft,
                           child: _rawMorseSequence.isEmpty 
                             ? Text("Tekan tombol di bawah...", style: GoogleFonts.fredoka(color: Colors.grey.shade400))
                             : SingleChildScrollView(
                                 controller: _graphScrollController,
                                 scrollDirection: Axis.horizontal,
                                 child: SandiRumputView(
                                   morseCode: _rawMorseSequence,
                                   strokeWidth: 3.0,
                                   color: _grassGreen,
                                   unitWidth: 12.0,
                                   shortHeight: 25.0,
                                   tallHeight: 60.0,
                                   spaceWidth: 18.0,
                                 ),
                               ),
                         ),

                 ),

                 const SizedBox(height: 24),

                 // 2. OUTPUT CARD (Lower)
                 _buildUnifiedCard(
                    title: _isEncryptMode ? "HASIL RUMPUT" : "HASIL TERJEMAHAN",
                    child: Container(
                       constraints: const BoxConstraints(minHeight: 120),
                       width: double.infinity,
                       // Output Logic:
                       // Encode Mode: Show SandiRumputView (Visual)
                       // Decode Mode: Show Decoded Text
                       child: _isEncryptMode
                          ? (_textController.text.trim().isEmpty 
                              ? Center(child: Text("Rumput akan tumbuh di sini...", style: GoogleFonts.fredoka(color: Colors.grey)))
                              : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SandiRumputView(
                                    text: _textController.text,
                                    strokeWidth: 4.0, // Thicker
                                    color: _forestGreen, // Darker Green
                                    unitWidth: 20.0,
                                    shortHeight: 40.0,
                                    tallHeight: 90.0,
                                    spaceWidth: 30.0,
                                  ),
                                )
                            )
                          : TextField(
                              controller: TextEditingController(text: _decodedText + (_currentLetterBuffer.isNotEmpty ? '...' : '')), // Show hint if typing
                              readOnly: true,
                              style: GoogleFonts.fredoka(fontSize: 18, color: _textBlack, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Hasil terjemahan...",
                                hintStyle: GoogleFonts.fredoka(color: Colors.grey.shade400),
                                contentPadding: EdgeInsets.zero,
                              ),
                              maxLines: 5,
                              minLines: 3,
                            ),
                    ),
                 ),

                 const SizedBox(height: 30),

                 // ACTION BUTTONS
                 Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       _buildActionButton("SALIN", Icons.copy, Colors.blue, _copyToClipboard),
                       const SizedBox(width: 20),
                       _buildActionButton("HAPUS", Icons.delete_outline, Colors.redAccent, _onClear),
                    ],
                 ),
              ],
            ),
          ),
          
          // DECODE KEYBOARD (Only if Decode Mode)
          if (!_isEncryptMode) _buildDecodeKeyboard(),
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
           child: Text(title, 
             style: GoogleFonts.fredoka(color: Colors.grey.shade400, fontWeight: FontWeight.bold, fontSize: 14)
           ),
         ),
         Container(
           decoration: BoxDecoration(
             color: _cardWhite,
             borderRadius: BorderRadius.circular(20),
             boxShadow: const [
               BoxShadow(
                 color: _grassGreen, // Match Morse vibrancy with Grass Green Accent shadow
                 offset: Offset(0, 6),
                 blurRadius: 0,
               )
             ]
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
             color: isActive ? _forestGreen : Colors.transparent,
             borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
             label,
             style: GoogleFonts.fredoka(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold
             ),
          ),
       ),
     );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
     return GestureDetector(
        onTap: onTap,
        child: Container(
           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
           decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                 BoxShadow(color: color.withValues(alpha: 0.6), offset: const Offset(0, 4), blurRadius: 0)
              ]
           ),
           child: Row(
              children: [
                 Icon(icon, color: Colors.white),
                 const SizedBox(width: 8),
                 Text(label, style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
           ),
        ),
     );
  }

  Widget _buildDecodeKeyboard() {
     return Container(
       padding: const EdgeInsets.all(16),
       color: const Color(0xFF1E293B),
       child: SafeArea(
          top: false,
          child: Column(
             children: [
                // Visual Graph for decoding feedback
                // FIXED: Increased height to avoid clipping (tallHeight 50 + padding 40 = 90 needed)
                SizedBox(
                   height: 100, // Increased from 60 to 100
                   child: SingleChildScrollView(
                      controller: _graphScrollController,
                      scrollDirection: Axis.horizontal,
                      child: SandiRumputView(
                          morseCode: _rawMorseSequence,
                          strokeWidth: 2.0,
                          color: _grassGreen,
                          unitWidth: 10.0,
                          shortHeight: 20.0,
                          tallHeight: 50.0,
                          spaceWidth: 15.0,
                      ),
                   ),
                ),
                const SizedBox(height: 10),
                Row(
                   children: [
                      Expanded(child: _buildGrassKey("PENDEK", Icons.arrow_drop_up, _grassGreen, _onShortGrassPressed)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildGrassKey("TINGGI", Icons.arrow_drop_up, Colors.orange, _onTallGrassPressed)), 
                   ],
                ),
                const SizedBox(height: 8),
                Row(
                   children: [
                      Expanded(child: _buildGrassKey("SPASI", Icons.space_bar, Colors.blue, _onSeparatorPressed)),
                      const SizedBox(width: 8),
                      GestureDetector(
                         onTap: _onBackspacePressed,
                         child: Container(
                            height: 50, width: 60,
                            decoration: BoxDecoration(
                               color: Colors.redAccent, 
                               borderRadius: BorderRadius.circular(12),
                               boxShadow: [BoxShadow(color: Colors.red.shade900, offset: const Offset(0, 3))]
                            ),
                            child: const Icon(Icons.backspace, color: Colors.white),
                         ),
                      )
                   ],
                )
             ],
          ),
       ),
     );
  }

  Widget _buildGrassKey(String label, IconData icon, Color color, VoidCallback onTap) {
     return GestureDetector(
        onTap: onTap,
        child: Container(
           height: 50,
           decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                 BoxShadow(color: color.withValues(alpha: 0.6), offset: const Offset(0, 3), blurRadius: 0)
              ]
           ),
           alignment: Alignment.center,
           child: Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Icon(icon, color: Colors.white, size: label == "PENDEK" ? 16 : 24), // Visual hint
               const SizedBox(width: 4),
               Text(label, style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.bold)),
             ],
           ),
        ),
     );
  }
}
