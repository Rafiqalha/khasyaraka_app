# Morse Audio Files

## Required Files

This directory should contain two audio files for Morse code:

1. **beep_short.wav** (~100ms)
   - For Dot (.) character
   - Single short beep tone
   - Frequency: ~800-1000 Hz recommended
   - Duration: ~100ms

2. **beep_long.wav** (~300ms)
   - For Dash (-) character
   - Single long beep tone (3x duration of dot)
   - Frequency: ~800-1000 Hz recommended
   - Duration: ~300ms

## Generating Audio Files

You can generate these files using:

1. **Online tools**: 
   - https://www.onlinetonegenerator.com/
   - Generate 800-1000 Hz sine wave
   - Export as WAV

2. **Audacity**:
   - Generate → Tone
   - Frequency: 800-1000 Hz
   - Duration: 0.1s (dot) or 0.3s (dash)
   - Export as WAV

3. **FFmpeg**:
   ```bash
   # Short beep (dot)
   ffmpeg -f lavfi -i "sine=frequency=800:duration=0.1" beep_short.wav
   
   # Long beep (dash)
   ffmpeg -f lavfi -i "sine=frequency=800:duration=0.3" beep_long.wav
   ```

## File Format

- Format: WAV (uncompressed recommended for low latency)
- Sample Rate: 44100 Hz or 48000 Hz
- Bit Depth: 16-bit
- Channels: Mono

## Notes

- Files must be placed in `assets/audio/morse/` directory
- Update `pubspec.yaml` to include these assets
- Run `flutter pub get` after adding files
