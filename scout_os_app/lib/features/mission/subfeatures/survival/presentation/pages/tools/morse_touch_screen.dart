import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torch_light/torch_light.dart';

class MorseTouchScreen extends StatefulWidget {
  const MorseTouchScreen({super.key});

  @override
  State<MorseTouchScreen> createState() => _MorseTouchScreenState();
}

class _MorseTouchScreenState extends State<MorseTouchScreen> {
  // Duolingo Colors
  static const Color _duoGreen = Color(0xFF58CC02);
  static const Color _duoGreenShadow = Color(0xFF46A302);
  static const Color _duoBlue = Color(0xFF1CB0F6);
  static const Color _duoBlueShadow = Color(0xFF1899D6);
  static const Color _duoRed = Color(0xFFFF4B4B);
  static const Color _duoRedShadow = Color(0xFFD93A3A);
  static const Color _duoYellow = Color(0xFFFFD600);

  final TextEditingController _textController = TextEditingController();
  final AudioPlayer _dotPlayer = AudioPlayer();
  final AudioPlayer _dashPlayer = AudioPlayer();
  
  bool _isTransmitting = false;
  bool _isFlashOn = false;
  String _currentMorse = "";
  
  // Morse Dictionary
  final Map<String, String> _morseCodeMap = {
    'A': '.-', 'B': '-...', 'C': '-.-.', 'D': '-..', 'E': '.', 'F': '..-.',
    'G': '--.', 'H': '....', 'I': '..', 'J': '.---', 'K': '-.-', 'L': '.-..',
    'M': '--', 'N': '-.', 'O': '---', 'P': '.--.', 'Q': '--.-', 'R': '.-.',
    'S': '...', 'T': '-', 'U': '..-', 'V': '...-', 'W': '.--', 'X': '-..-',
    'Y': '-.--', 'Z': '--..', '1': '.----', '2': '..---', '3': '...--',
    '4': '....-', '5': '.....', '6': '-....', '7': '--...', '8': '---..',
    '9': '----.', '0': '-----', ' ': '/'
  };

  // Timings (ms)
  final int _dotDuration = 200; 
  final int _dashDuration = 600; 
  final int _gapDuration = 200;
  final int _letterGap = 600;
  final int _wordGap = 1400;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }
  
  Future<void> _initAudio() async {
    // Audio Ducking Configuration (Preserved Fix: Media/Music)
    final AudioContext audioContext = AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {
          AVAudioSessionOptions.duckOthers,
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
      android: AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gainTransientMayDuck,
      ),
    );

    await AudioPlayer.global.setAudioContext(audioContext);
    
    // Preload sounds
    await _dotPlayer.setSource(AssetSource('audio/morse/sos/dot.wav'));
    await _dotPlayer.setReleaseMode(ReleaseMode.stop);
    await _dotPlayer.setVolume(1.0);
    
    await _dashPlayer.setSource(AssetSource('audio/morse/sos/dash.wav'));
    await _dashPlayer.setReleaseMode(ReleaseMode.stop);
    await _dashPlayer.setVolume(1.0);
  }

  void _onTextChanged(String text) {
    setState(() {
      _currentMorse = text.toUpperCase().split('').map((char) {
        return _morseCodeMap[char] ?? '';
      }).join(' ');
    });
  }

  // Play a specific signal type (Dot or Dash)
  Future<void> _playSignal(String type) async {
    if (!mounted) return;
    
    debugPrint("Playing Signal: $type"); 

    // 1. Visual & Flash ON
    setState(() => _isFlashOn = true);
    try {
      await TorchLight.enableTorch();
    } catch (_) {}

    // 2. Play Audio (Preserved Fix: Error Handling & Resume)
    try {
      if (type == '.') {
        await _dotPlayer.stop(); 
        await _dotPlayer.resume(); 
        await Future.delayed(Duration(milliseconds: _dotDuration));
      } else if (type == '-') {
        await _dashPlayer.stop();
        await _dashPlayer.resume();
        await Future.delayed(Duration(milliseconds: _dashDuration));
      }
    } catch (_) {}

    // 3. Visual & Flash OFF
    if (mounted) setState(() => _isFlashOn = false);
    try {
      await TorchLight.disableTorch();
    } catch (_) {}
    
    // Reset players
    if (type == '.') await _dotPlayer.stop();
    if (type == '-') await _dashPlayer.stop();
  }

  Future<void> _transmitMorseSequence(String text, {bool loop = false}) async {
    if (_isTransmitting) return;

    setState(() => _isTransmitting = true);
    final upperText = text.toUpperCase();
    
    do {
      for (int i = 0; i < upperText.length; i++) {
        if (!_isTransmitting) break; 

        String char = upperText[i];
        String? code = _morseCodeMap[char];

        if (code != null) {
          for (int j = 0; j < code.length; j++) {
             if (!_isTransmitting) break;
             String signal = code[j];
             await _playSignal(signal);
             await Future.delayed(Duration(milliseconds: _gapDuration));
          }
          await Future.delayed(Duration(milliseconds: _letterGap - _gapDuration)); 
        } else if (char == ' ') {
           await Future.delayed(Duration(milliseconds: _wordGap)); 
        }
      }
      if (loop && _isTransmitting) {
        await Future.delayed(Duration(milliseconds: _wordGap)); 
      }
    } while (loop && _isTransmitting);

    _stopTransmission();
  }
  
  void _stopTransmission() async {
    if (mounted) {
      setState(() {
        _isTransmitting = false;
        _isFlashOn = false;
      });
    }
    try {
      await TorchLight.disableTorch();
    } catch (_) {}
    await _dotPlayer.stop();
    await _dashPlayer.stop();
  }

  @override
  void dispose() {
    _stopTransmission();
    _textController.dispose();
    _dotPlayer.dispose();
    _dashPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Morse Touch Data", style: GoogleFonts.fredoka(color: Colors.grey.shade800, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Text Input
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _textController,
                onChanged: _onTextChanged,
                enabled: !_isTransmitting,
                style: GoogleFonts.fredoka(fontSize: 18, color: Colors.black87),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Ketik pesan (e.g. SOS)...",
                  hintStyle: GoogleFonts.fredoka(color: Colors.grey),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 2. Real-time Morse Preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _duoBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _currentMorse.isEmpty ? "..." : _currentMorse,
                textAlign: TextAlign.center,
                style: GoogleFonts.sourceCodePro(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: _duoBlue,
                  letterSpacing: 2.0
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // 3. Visualizer (Giant Bulb)
            AnimatedContainer(
              duration: const Duration(milliseconds: 50),
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isFlashOn ? _duoYellow : Colors.grey.shade300,
                boxShadow: _isFlashOn ? [
                   BoxShadow(color: _duoYellow.withValues(alpha: 0.6), blurRadius: 40, spreadRadius: 10),
                   BoxShadow(color: _duoYellow.withValues(alpha: 0.4), blurRadius: 80, spreadRadius: 20),
                ] : [
                   BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))
                ],
                border: Border.all(
                  color: _isFlashOn ? Colors.white : Colors.grey.shade400,
                  width: 4
                )
              ),
              child: Icon(
                _isFlashOn ? Icons.light_mode : Icons.light_mode_outlined,
                size: 80,
                color: _isFlashOn ? Colors.white : Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            
            // 4. Action Buttons (3D)
            Row(
              children: [
                Expanded(
                  child: _build3DButton(
                    label: _isTransmitting ? "STOP" : "KIRIM",
                    color: _isTransmitting ? Colors.grey : _duoGreen,
                    shadowColor: _isTransmitting ? Colors.grey.shade700 : _duoGreenShadow,
                    onTap: () {
                      if (_isTransmitting) {
                        _stopTransmission();
                      } else {
                        if (_textController.text.isNotEmpty) {
                          FocusScope.of(context).unfocus();
                          _transmitMorseSequence(_textController.text);
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _build3DButton(
                    label: "SOS LOOP",
                    color: _duoRed,
                    shadowColor: _duoRedShadow,
                    onTap: () {
                       if (_isTransmitting) {
                         _stopTransmission();
                       } else {
                         _textController.text = "SOS";
                         _onTextChanged("SOS");
                         FocusScope.of(context).unfocus();
                         _transmitMorseSequence("SOS", loop: true);
                       }
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 5. Manual Touch
            GestureDetector(
              onTapDown: (_) async {
                 await _playSignal('.'); 
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: _duoBlue,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                     BoxShadow(color: _duoBlueShadow, offset: Offset(0, 6), blurRadius: 0)
                  ]
                ),
                child: Column(
                  children: [
                    const Icon(Icons.touch_app, color: Colors.white, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      "MANUAL TOUCH (DOT)", 
                      style: GoogleFonts.fredoka(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _build3DButton({
    required String label, 
    required Color color, 
    required Color shadowColor, 
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: shadowColor, offset: const Offset(0, 4), blurRadius: 0)
          ]
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.fredoka(
             fontSize: 16,
             fontWeight: FontWeight.bold,
             color: Colors.white
          ),
        ),
      ),
    );
  }
}
