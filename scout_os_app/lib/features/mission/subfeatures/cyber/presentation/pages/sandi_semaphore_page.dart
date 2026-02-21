import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/theme/cyber_theme.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/widgets/cyber_container.dart';

/// Sandi Semaphore Learning Tool
///
/// Interactive tool to learn Semaphore flag positions
/// with animated stickman character
class SandiSemaphorePage extends StatefulWidget {
  final SandiModel sandi;

  const SandiSemaphorePage({super.key, required this.sandi});

  @override
  State<SandiSemaphorePage> createState() => _SandiSemaphorePageState();
}

class _SandiSemaphorePageState extends State<SandiSemaphorePage> {
  final TextEditingController _textController = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  double _speed = 0.5; // 0.0 = slow, 1.0 = fast
  bool _isPlaying = false;
  bool _isMuted = false;
  bool _ttsAvailable = false; // Track if TTS is available
  int _currentIndex = -1;
  String _currentLetter = '';
  Timer? _playTimer;
  Completer<void>? _ttsCompleter; // For TTS synchronization

  // Current angles for animation
  double _currentLeftAngle = 0.0; // Rest position (down)
  double _currentRightAngle = 0.0; // Rest position (down)
  double _targetLeftAngle = 0.0;
  double _targetRightAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _textController.text = 'PRAMUKA';
    _initializeAudio();
    _goToRest();
  }

  Future<void> _initializeAudio() async {
    // Initialize FlutterTts with error handling
    try {
      // Test if TTS is available by trying to get languages
      final languages = await _flutterTts.getLanguages;
      debugPrint('Available TTS languages: $languages');

      if (languages != null) {
        _ttsAvailable = true;

        // Try to set Indonesian language, fallback to English if not available
        bool languageSet = false;
        if (languages.contains('id-ID')) {
          await _flutterTts.setLanguage('id-ID');
          languageSet = true;
          debugPrint('TTS language set to Indonesian (id-ID)');
        } else if (languages.contains('en-US')) {
          await _flutterTts.setLanguage('en-US');
          languageSet = true;
          debugPrint(
            'TTS language set to English (en-US) - Indonesian not available',
          );
        }

        if (!languageSet && languages.isNotEmpty) {
          // Try first available language
          await _flutterTts.setLanguage(languages.first);
          debugPrint('TTS using first available language: ${languages.first}');
        }

        await _flutterTts.setSpeechRate(0.5); // Slow and clear
        await _flutterTts.setVolume(1.0);
        await _flutterTts.setPitch(1.0);

        // Set completion handler for TTS - used for synchronization
        _flutterTts.setCompletionHandler(() {
          debugPrint('TTS completed');
          // Complete the completer if it exists
          _ttsCompleter?.complete();
          _ttsCompleter = null;
        });

        _flutterTts.setErrorHandler((msg) {
          debugPrint('TTS error: $msg');
        });

        // Set start handler
        _flutterTts.setStartHandler(() {
          debugPrint('TTS started');
        });
      } else {
        _ttsAvailable = false;
        debugPrint('TTS not available - languages is null');
      }
    } catch (e) {
      _ttsAvailable = false;
      debugPrint('TTS initialization error: $e - TTS will be disabled');
    }

    // Load flag sound effect
    try {
      await _audioPlayer.setSource(
        AssetSource('audio/semaphore/flag_flap.wav'),
      );
      debugPrint('Flag sound loaded successfully');
    } catch (e) {
      // If asset doesn't exist, we'll handle it gracefully
      debugPrint('Flag sound asset not found: $e');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _playTimer?.cancel();

    // Stop TTS safely
    if (_ttsAvailable) {
      try {
        _flutterTts.stop();
      } catch (e) {
        debugPrint('Error stopping TTS in dispose: $e');
      }
    }

    // Dispose audio safely
    try {
      _audioPlayer.dispose();
    } catch (e) {
      debugPrint('Error disposing audio: $e');
    }

    super.dispose();
  }

  void _goToRest() {
    setState(() {
      _currentLeftAngle = 0.0;
      _currentRightAngle = 0.0;
      _targetLeftAngle = 0.0;
      _targetRightAngle = 0.0;
      _currentLetter = '';
      _currentIndex = -1;
    });
  }

  void _onSpeedChanged(double value) {
    setState(() {
      _speed = value;
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _onPlay() {
    if (_isPlaying) {
      _stopPlaying();
    } else {
      _startPlaying();
    }
  }

  void _stopPlaying() {
    // Stop immediately - real-time stop
    setState(() {
      _isPlaying = false;
      // Keep current position - don't reset _currentIndex and _currentLetter
      // Keep stickman at current pose - don't reset angles
    });
    _playTimer?.cancel();

    // Complete and reset TTS completer if exists
    _ttsCompleter?.complete();
    _ttsCompleter = null;

    // Stop TTS immediately and safely
    if (_ttsAvailable) {
      try {
        _flutterTts.stop();
      } catch (e) {
        debugPrint('Error stopping TTS: $e');
      }
    }

    // Stop audio immediately and safely
    try {
      _audioPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }

    // Don't reset to rest position - keep current pose and state
  }

  Future<void> _startPlaying() async {
    final text = _textController.text.toUpperCase().replaceAll(' ', '');
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter text to play',
            style: CyberTheme.body().copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.black.withOpacity(0.9),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Continue from last position if available, otherwise start from beginning
    int startIndex = 0;
    if (_currentIndex >= 0 && _currentIndex < text.length - 1) {
      // Continue from next letter after last shown
      startIndex = _currentIndex + 1;
    } else {
      // Start from beginning if no previous position or already at end
      startIndex = 0;
      _currentIndex = -1; // Reset untuk mulai dari awal
    }

    setState(() {
      _isPlaying = true;
    });

    // Only go to rest if starting from beginning
    if (startIndex == 0) {
      await _animateToPose(0.0, 0.0, '');
      await Future.delayed(_getDelay());
    }

    // Play each character starting from startIndex
    for (int i = startIndex; i < text.length; i++) {
      // Check if stopped - real-time stop check
      if (!_isPlaying) break;

      final char = text[i];
      if (char == ' ') continue;

      final angles = SemaphoreDictionary.getAngles(char);
      if (angles != null) {
        // Update current index and letter immediately
        setState(() {
          _currentIndex = i;
          _currentLetter = char;
        });

        // Synchronized audio playback - this will handle timing internally
        await _animateToPose(angles['left']!, angles['right']!, char);

        // Small delay between letters (only if still playing)
        if (_isPlaying) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
    }

    // Return to rest only if completed all letters
    if (_isPlaying && startIndex == 0) {
      await _animateToPose(0.0, 0.0, '');
      await Future.delayed(_getDelay());
    }

    _stopPlaying();
  }

  Future<void> _animateToPose(
    double leftAngle,
    double rightAngle,
    String letter,
  ) async {
    // Update animation state first
    setState(() {
      _targetLeftAngle = leftAngle;
      _targetRightAngle = rightAngle;
      _currentLetter = letter;
    });

    // Play synchronized audio (only if not muted and letter is not empty)
    if (!_isMuted && letter.isNotEmpty) {
      try {
        // Create completer for TTS synchronization
        _ttsCompleter = Completer<void>();

        // Start flag sound immediately
        _audioPlayer
            .play(AssetSource('audio/semaphore/flag_flap.wav'))
            .catchError((e) {
              debugPrint('Flag sound error: $e');
            });

        // Start TTS immediately after flag sound (for perfect sync)
        if (_ttsAvailable) {
          try {
            // Small delay to let flag sound start first
            await Future.delayed(const Duration(milliseconds: 50));

            // Start TTS - completion handler will complete the completer
            await _flutterTts.speak(letter).catchError((e) {
              debugPrint('TTS speak error: $e');
              _ttsCompleter?.complete(); // Complete even on error
              _ttsCompleter = null;
              if (e.toString().contains('MissingPluginException')) {
                _ttsAvailable = false;
              }
            });

            // Wait for TTS to complete using completer (with timeout)
            await _ttsCompleter?.future
                .timeout(
                  const Duration(seconds: 2),
                  onTimeout: () {
                    debugPrint('TTS completion timeout for letter: $letter');
                    _ttsCompleter = null;
                  },
                )
                .catchError((e) {
                  debugPrint('TTS completer error: $e');
                  _ttsCompleter = null;
                });
          } catch (e) {
            debugPrint('TTS initialization error: $e');
            _ttsCompleter?.complete();
            _ttsCompleter = null;
          }
        } else {
          // If no TTS, just wait for flag sound
          await Future.delayed(const Duration(milliseconds: 300));
        }
      } catch (e) {
        debugPrint('Audio playback error: $e');
        _ttsCompleter?.complete();
        _ttsCompleter = null;
      }
    } else {
      // If muted or empty letter, just wait for animation
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Duration _getDelay() {
    // Speed: 0.0 = 2000ms, 1.0 = 500ms
    final milliseconds = 2000 - (_speed * 1500).round();
    return Duration(milliseconds: milliseconds);
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
          onPressed: () {
            _stopPlaying();
            Navigator.pop(context);
          },
        ),
        title: Text(
          'SANDI SEMAPHORE',
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
            // Input Section
            CyberContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Text to Display',
                    style: CyberTheme.headline().copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          style: GoogleFonts.courierPrime(
                            fontSize: 16,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter text...',
                            hintStyle: GoogleFonts.courierPrime(
                              fontSize: 14,
                              color: CyberTheme.textSecondary,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          textCapitalization: TextCapitalization.characters,
                          enabled: !_isPlaying,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Mute Toggle Button
                      IconButton(
                        onPressed: _toggleMute,
                        icon: Icon(
                          _isMuted ? Icons.volume_off : Icons.volume_up,
                          color: _isMuted
                              ? CyberTheme.textSecondary
                              : CyberTheme.neonCyan,
                        ),
                        tooltip: _isMuted ? 'Unmute' : 'Mute',
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _onPlay,
                        icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                        label: Text(_isPlaying ? 'STOP' : 'PLAY'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isPlaying
                              ? CyberTheme.error
                              : CyberTheme.neonCyan,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Semaphore Man
            CyberContainer(
              child: Center(
                child: SemaphoreMan(
                  leftAngle: _currentLeftAngle,
                  rightAngle: _currentRightAngle,
                  targetLeftAngle: _targetLeftAngle,
                  targetRightAngle: _targetRightAngle,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Current Letter Display
            CyberContainer(
              child: Column(
                children: [
                  Text(
                    'Current Letter',
                    style: CyberTheme.headline().copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _currentLetter.isEmpty ? '—' : _currentLetter,
                      key: ValueKey(_currentLetter),
                      style: GoogleFonts.orbitron(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: _currentLetter.isEmpty
                            ? CyberTheme.textSecondary
                            : CyberTheme.neonCyan,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                  if (_currentIndex >= 0 &&
                      _textController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${_currentIndex + 1} / ${_textController.text.replaceAll(' ', '').length}',
                      style: GoogleFonts.courierPrime(
                        fontSize: 14,
                        color: CyberTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Speed Slider
            CyberContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Speed',
                        style: CyberTheme.headline().copyWith(fontSize: 16),
                      ),
                      Text(
                        _speed < 0.33
                            ? 'SLOW'
                            : _speed < 0.67
                            ? 'MEDIUM'
                            : 'FAST',
                        style: GoogleFonts.orbitron(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: CyberTheme.neonCyan,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: _speed,
                    min: 0.0,
                    max: 1.0,
                    activeColor: CyberTheme.neonCyan,
                    inactiveColor: CyberTheme.surface,
                    onChanged: _isPlaying ? null : _onSpeedChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Semaphore Man Widget
///
/// Modern stylized Scout character (Pramuka) with semaphore flags
class SemaphoreMan extends StatefulWidget {
  final double leftAngle;
  final double rightAngle;
  final double targetLeftAngle;
  final double targetRightAngle;

  const SemaphoreMan({
    super.key,
    required this.leftAngle,
    required this.rightAngle,
    required this.targetLeftAngle,
    required this.targetRightAngle,
  });

  @override
  State<SemaphoreMan> createState() => _SemaphoreManState();
}

class _SemaphoreManState extends State<SemaphoreMan>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _leftAnimation;
  late Animation<double> _rightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _leftAnimation = Tween<double>(
      begin: widget.leftAngle,
      end: widget.targetLeftAngle,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _rightAnimation = Tween<double>(
      begin: widget.rightAngle,
      end: widget.targetRightAngle,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(SemaphoreMan oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetLeftAngle != widget.targetLeftAngle ||
        oldWidget.targetRightAngle != widget.targetRightAngle) {
      _leftAnimation = Tween<double>(
        begin: oldWidget.targetLeftAngle,
        end: widget.targetLeftAngle,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _rightAnimation = Tween<double>(
        begin: oldWidget.targetRightAngle,
        end: widget.targetRightAngle,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(300, 400),
          painter: SemaphoreManPainter(
            leftAngle: _leftAnimation.value,
            rightAngle: _rightAnimation.value,
          ),
        );
      },
    );
  }
}

/// Custom Painter for Semaphore Man
class SemaphoreManPainter extends CustomPainter {
  final double leftAngle;
  final double rightAngle;

  SemaphoreManPainter({required this.leftAngle, required this.rightAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final headY = 60.0;
    final shoulderY = 120.0;
    final bodyLength = 180.0;
    final armLength = 80.0;
    final headRadius = 25.0;
    final bodyWidth = 8.0;
    final armWidth = 6.0;
    final flagSize = 40.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Head
    paint
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(centerX, headY), headRadius, paint);
    paint.style = PaintingStyle.fill;
    paint.color = Colors.white.withOpacity(0.1);
    canvas.drawCircle(Offset(centerX, headY), headRadius, paint);

    // Body
    paint
      ..color = Colors.white
      ..strokeWidth = bodyWidth
      ..style = PaintingStyle.stroke;
    final bodyEndY = shoulderY + bodyLength;
    canvas.drawLine(
      Offset(centerX, shoulderY),
      Offset(centerX, bodyEndY),
      paint,
    );

    // Legs (2 separate legs for better orientation reference)
    final legLength = 100.0;
    final legWidth = 6.0;
    final legSpread = 20.0; // Distance between legs at hip

    paint
      ..color = Colors.white
      ..strokeWidth = legWidth;

    // Left leg (from body end, going left and down)
    final leftLegEndX = centerX - legSpread / 2;
    final leftLegEndY = bodyEndY + legLength;
    canvas.drawLine(
      Offset(centerX, bodyEndY),
      Offset(leftLegEndX, leftLegEndY),
      paint,
    );

    // Right leg (from body end, going right and down)
    final rightLegEndX = centerX + legSpread / 2;
    final rightLegEndY = bodyEndY + legLength;
    canvas.drawLine(
      Offset(centerX, bodyEndY),
      Offset(rightLegEndX, rightLegEndY),
      paint,
    );

    // Convert angles from degrees to radians
    // Semaphore angles: 0° = down, 90° = horizontal right, 180° = up, 270° = horizontal left
    // But we need: 0° = down, 90° = horizontal right, -90° = horizontal left
    final leftRad =
        math.pi / 180 * (leftAngle - 90); // Adjust for coordinate system
    final rightRad = math.pi / 180 * (rightAngle - 90);

    // Left Arm (from shoulder, going left)
    final leftArmEndX = centerX - math.cos(leftRad) * armLength;
    final leftArmEndY = shoulderY + math.sin(leftRad) * armLength;

    paint
      ..color = Colors.white
      ..strokeWidth = armWidth;
    canvas.drawLine(
      Offset(centerX, shoulderY),
      Offset(leftArmEndX, leftArmEndY),
      paint,
    );

    // Right Arm (from shoulder, going right)
    final rightArmEndX = centerX + math.cos(rightRad) * armLength;
    final rightArmEndY = shoulderY + math.sin(rightRad) * armLength;

    canvas.drawLine(
      Offset(centerX, shoulderY),
      Offset(rightArmEndX, rightArmEndY),
      paint,
    );

    // Flags
    _drawFlag(
      canvas,
      Offset(leftArmEndX, leftArmEndY),
      leftRad,
      flagSize,
      true, // isLeft
    );
    _drawFlag(
      canvas,
      Offset(rightArmEndX, rightArmEndY),
      rightRad,
      flagSize,
      false, // isRight
    );
  }

  void _drawFlag(
    Canvas canvas,
    Offset position,
    double angle,
    double size,
    bool isLeft,
  ) {
    // Flag pole extends from end of arm
    // Tangan memegang di ujung lengan (position), bendera di ujung tongkat yang lain
    final poleLength = 25.0; // Panjang tongkat bendera
    final poleEndX = position.dx + math.cos(angle) * poleLength;
    final poleEndY = position.dy + math.sin(angle) * poleLength;

    // Draw flag pole (tongkat) - tangan memegang di ujung (position), bendera di ujung lain
    final polePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(position, Offset(poleEndX, poleEndY), polePaint);

    // Flag rectangle positioned at the FAR end of the pole (diagonal split: Red & Yellow)
    // Bendera digambar di ujung tongkat yang jauh dari tangan
    // Tangan memegang di ujung yang dekat dengan lengan (position), bendera di ujung lain
    // Bendera digambar sedikit lebih jauh dari ujung tongkat agar jelas terlihat dipegang di ujung
    final flagOffset = 5.0; // Offset untuk memastikan bendera jelas di ujung
    final flagCenterX = poleEndX + math.cos(angle) * flagOffset;
    final flagCenterY = poleEndY + math.sin(angle) * flagOffset;

    final flagRect = Rect.fromLTWH(
      flagCenterX - size / 2,
      flagCenterY - size / 2,
      size,
      size,
    );

    // Rotate flag to align with arm direction
    canvas.save();
    canvas.translate(flagCenterX, flagCenterY);
    canvas.rotate(angle);
    canvas.translate(-flagCenterX, -flagCenterY);

    // Draw flag with diagonal split
    // Top-left triangle (Red)
    final redPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    final redPath = Path()
      ..moveTo(flagRect.left, flagRect.top)
      ..lineTo(flagRect.right, flagRect.top)
      ..lineTo(flagRect.left, flagRect.bottom)
      ..close();
    canvas.drawPath(redPath, redPaint);

    // Bottom-right triangle (Yellow)
    final yellowPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;
    final yellowPath = Path()
      ..moveTo(flagRect.right, flagRect.top)
      ..lineTo(flagRect.right, flagRect.bottom)
      ..lineTo(flagRect.left, flagRect.bottom)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // Flag border
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawRect(flagRect, borderPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(SemaphoreManPainter oldDelegate) {
    return oldDelegate.leftAngle != leftAngle ||
        oldDelegate.rightAngle != rightAngle;
  }
}

/// Semaphore Dictionary
///
/// Maps letters to semaphore flag positions (angles in degrees)
/// Standard Semaphore positions:
/// - 0° = Down
/// - 45° = Low Side
/// - 90° = Horizontal
/// - 135° = High Side
/// - 180° = Up
/// - 225° = High Side (other side)
/// - 270° = Horizontal (other side)
/// - 315° = Low Side (other side)
class SemaphoreDictionary {
  // Standard Semaphore positions (angles in degrees)
  // Left and Right arm positions for each letter
  static final Map<String, Map<String, double>> _positions = {
    'A': {
      'left': 45,
      'right': 225,
    }, // Left: Low Side, Right: High Side (opposite)
    'B': {'left': 90, 'right': 225}, // Left: Horizontal, Right: High Side
    'C': {'left': 135, 'right': 225}, // Left: High Side, Right: High Side
    'D': {
      'left': 45,
      'right': 270,
    }, // Left: Low Side, Right: Horizontal (opposite)
    'E': {
      'left': 90,
      'right': 270,
    }, // Left: Horizontal, Right: Horizontal (opposite)
    'F': {
      'left': 135,
      'right': 270,
    }, // Left: High Side, Right: Horizontal (opposite)
    'G': {
      'left': 45,
      'right': 315,
    }, // Left: Low Side, Right: Low Side (opposite)
    'H': {
      'left': 90,
      'right': 315,
    }, // Left: Horizontal, Right: Low Side (opposite)
    'I': {
      'left': 135,
      'right': 315,
    }, // Left: High Side, Right: Low Side (opposite)
    'J': {'left': 45, 'right': 0}, // Left: Low Side, Right: Down
    'K': {'left': 90, 'right': 0}, // Left: Horizontal, Right: Down
    'L': {'left': 135, 'right': 0}, // Left: High Side, Right: Down
    'M': {'left': 180, 'right': 0}, // Left: Up, Right: Down
    'N': {'left': 225, 'right': 0}, // Left: High Side (opposite), Right: Down
    'O': {'left': 270, 'right': 0}, // Left: Horizontal (opposite), Right: Down
    'P': {'left': 315, 'right': 0}, // Left: Low Side (opposite), Right: Down
    'Q': {'left': 0, 'right': 45}, // Left: Down, Right: Low Side
    'R': {'left': 0, 'right': 90}, // Left: Down, Right: Horizontal
    'S': {'left': 0, 'right': 135}, // Left: Down, Right: High Side
    'T': {'left': 0, 'right': 180}, // Left: Down, Right: Up
    'U': {'left': 0, 'right': 225}, // Left: Down, Right: High Side (opposite)
    'V': {'left': 0, 'right': 270}, // Left: Down, Right: Horizontal (opposite)
    'W': {'left': 0, 'right': 315}, // Left: Down, Right: Low Side (opposite)
    'X': {'left': 45, 'right': 45}, // Both: Low Side
    'Y': {'left': 90, 'right': 90}, // Both: Horizontal
    'Z': {'left': 135, 'right': 135}, // Both: High Side
  };

  static Map<String, double>? getAngles(String letter) {
    return _positions[letter.toUpperCase()];
  }

  static List<String> getAvailableLetters() {
    return _positions.keys.toList()..sort();
  }
}

/// Simple Stickman Widget
///
/// Pure minimalist stick figure with semaphore flags
/// Clean black lines, no shadows or 3D effects
class SimpleStickman extends StatefulWidget {
  final double leftArmAngle; // in degrees
  final double rightArmAngle; // in degrees

  const SimpleStickman({
    super.key,
    required this.leftArmAngle,
    required this.rightArmAngle,
  });

  @override
  State<SimpleStickman> createState() => _SimpleStickmanState();
}

class _SimpleStickmanState extends State<SimpleStickman> {
  late double _previousLeftAngle;
  late double _previousRightAngle;

  @override
  void initState() {
    super.initState();
    _previousLeftAngle = widget.leftArmAngle;
    _previousRightAngle = widget.rightArmAngle;
  }

  @override
  void didUpdateWidget(SimpleStickman oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.leftArmAngle != widget.leftArmAngle) {
      _previousLeftAngle = oldWidget.leftArmAngle;
    }
    if (oldWidget.rightArmAngle != widget.rightArmAngle) {
      _previousRightAngle = oldWidget.rightArmAngle;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Positioning constants
    const centerX = 150.0;
    const headY = 50.0;
    const headRadius = 20.0;
    const shoulderY = 90.0;
    const bodyLength = 140.0;
    const armLength = 70.0;
    const legLength = 80.0;
    const legSpread = 30.0; // Distance between feet
    const lineWidth = 4.0;
    const flagSize = 35.0;

    // Convert angles from degrees to radians
    // Semaphore angles: 0° = down, 90° = horizontal right, 180° = up
    final leftRad = math.pi / 180 * (widget.leftArmAngle - 90);
    final rightRad = math.pi / 180 * (widget.rightArmAngle - 90);
    final previousLeftRad = math.pi / 180 * (_previousLeftAngle - 90);
    final previousRightRad = math.pi / 180 * (_previousRightAngle - 90);

    final bodyEndY = shoulderY + bodyLength;

    return SizedBox(
      width: 300,
      height: 400,
      child: Stack(
        children: [
          // Legs (behind body) - Inverted 'V' shape, starting from body end
          Positioned(
            left: centerX,
            top: bodyEndY,
            child: CustomPaint(
              size: Size(legSpread, legLength),
              painter: LegsPainter(lineWidth: lineWidth),
            ),
          ),

          // Body (vertical line)
          Positioned(
            left: centerX - lineWidth / 2,
            top: shoulderY,
            child: Container(
              width: lineWidth,
              height: bodyLength,
              color: Colors.white,
            ),
          ),

          // Head (white circle)
          Positioned(
            left: centerX - headRadius,
            top: headY - headRadius,
            child: Container(
              width: headRadius * 2,
              height: headRadius * 2,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),

          // Left Arm with animation
          Positioned(
            left: centerX - lineWidth / 2,
            top: shoulderY,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              tween: Tween<double>(begin: previousLeftRad, end: leftRad),
              builder: (context, angle, child) {
                return Transform.rotate(
                  angle: angle,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: armLength + flagSize,
                    height: armLength + flagSize,
                    child: Stack(
                      children: [
                        // Arm line
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            width: lineWidth,
                            height: armLength,
                            color: Colors.white,
                          ),
                        ),
                        // Flag at end of arm
                        Positioned(
                          left: lineWidth / 2 - flagSize / 2,
                          top: armLength - 2,
                          child: _SemaphoreFlag(size: flagSize),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Right Arm with animation
          Positioned(
            left: centerX - lineWidth / 2,
            top: shoulderY,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              tween: Tween<double>(begin: previousRightRad, end: rightRad),
              builder: (context, angle, child) {
                return Transform.rotate(
                  angle: angle,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: armLength + flagSize,
                    height: armLength + flagSize,
                    child: Stack(
                      children: [
                        // Arm line
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            width: lineWidth,
                            height: armLength,
                            color: Colors.white,
                          ),
                        ),
                        // Flag at end of arm
                        Positioned(
                          left: lineWidth / 2 - flagSize / 2,
                          top: armLength - 2,
                          child: _SemaphoreFlag(size: flagSize),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter for legs (inverted 'V' shape)
class LegsPainter extends CustomPainter {
  final double lineWidth;

  LegsPainter({required this.lineWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;

    // Left leg (diagonal down-left)
    canvas.drawLine(Offset(0, 0), Offset(-size.width / 2, size.height), paint);

    // Right leg (diagonal down-right)
    canvas.drawLine(Offset(0, 0), Offset(size.width / 2, size.height), paint);
  }

  @override
  bool shouldRepaint(LegsPainter oldDelegate) => false;
}

/// Semaphore Flag Widget
///
/// Square flag with diagonal Red-Yellow split using LinearGradient
class _SemaphoreFlag extends StatelessWidget {
  final double size;

  const _SemaphoreFlag({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        // Diagonal gradient: Red (top-left) to Yellow (bottom-right)
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [Colors.red, Colors.red, Colors.yellow, Colors.yellow],
          stops: const [
            0.0,
            0.5,
            0.5,
            1.0,
          ], // Hard stop at 50% for sharp diagonal
        ),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
    );
  }
}
