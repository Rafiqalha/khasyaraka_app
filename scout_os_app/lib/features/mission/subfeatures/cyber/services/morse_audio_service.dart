import 'package:audioplayers/audioplayers.dart';

/// Morse Audio Service
/// 
/// Handles audio playback for Morse code according to standard:
/// - Dot (.) = 1 unit (short beep ~100ms)
/// - Dash (-) = 3 units (long beep ~300ms)
/// 
/// Uses single audio file playback, NOT multiple beeps
class MorseAudioService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isInitialized = false;

  /// Initialize audio service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      _isInitialized = true;
    } catch (e) {
      // Silent fail for offline/outdoor use
    }
  }

  /// Play dot (.) - Short beep (~100ms)
  /// Single playback, not looped
  static Future<void> playDot() async {
    try {
      await initialize();
      await _player.stop(); // Stop any ongoing playback
      await _player.play(AssetSource('audio/morse/beep_short.wav'));
    } catch (e) {
      // Silent fail - app must work offline
    }
  }

  /// Play dash (-) - Long beep (~300ms)
  /// Single playback, not looped
  static Future<void> playDash() async {
    try {
      await initialize();
      await _player.stop(); // Stop any ongoing playback
      await _player.play(AssetSource('audio/morse/beep_long.wav'));
    } catch (e) {
      // Silent fail - app must work offline
    }
  }

  /// Dispose resources
  static Future<void> dispose() async {
    try {
      await _player.stop();
      await _player.dispose();
    } catch (e) {
      // Silent fail
    }
  }
}
