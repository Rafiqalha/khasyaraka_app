#!/bin/bash

# Generate Morse Code Audio Files
# Requires: FFmpeg installed
# Usage: ./generate_audio.sh

echo "Generating Morse Code audio files..."

# Check if FFmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: FFmpeg is not installed."
    echo "Install FFmpeg: sudo apt-get install ffmpeg (Linux) or brew install ffmpeg (Mac)"
    exit 1
fi

# Create directory if it doesn't exist
mkdir -p "$(dirname "$0")"

# Generate short beep for Dot (.) - 100ms at 800Hz
echo "Generating beep_short.wav (Dot - 100ms)..."
ffmpeg -f lavfi -i "sine=frequency=800:duration=0.1" \
    -ar 44100 \
    -ac 1 \
    -sample_fmt s16 \
    "$(dirname "$0")/beep_short.wav" \
    -y -loglevel error

# Generate long beep for Dash (-) - 300ms at 800Hz
echo "Generating beep_long.wav (Dash - 300ms)..."
ffmpeg -f lavfi -i "sine=frequency=800:duration=0.3" \
    -ar 44100 \
    -ac 1 \
    -sample_fmt s16 \
    "$(dirname "$0")/beep_long.wav" \
    -y -loglevel error

echo "Done! Audio files generated:"
echo "  - beep_short.wav (100ms)"
echo "  - beep_long.wav (300ms)"
