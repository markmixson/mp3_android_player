# Research Report: haptic-player

This document contains research findings related to the implementation of synchronized haptic feedback for the `haptic-player` feature.

## Research Findings

### 1. `advanced_haptics` Package Capabilities
**Task**: Verify API for custom waveforms and amplitude control.

**Findings**:
- The `advanced_haptics` package (and underlying Android APIs) supports `VibrationEffect.createWaveform`.
- This allows providing an array of durations and an array of amplitudes (0-255).
- For continuous feedback, we can send small waveform segments or use a single long waveform if the pattern is pre-calculated. Given our real-time requirement, sending frequent updates to the amplitude/waveform is necessary.

**Decision**: We will use `VibrationEffect` via the package to update haptic intensity based on calculated RMS values.

### 2. Android Haptics Latency
**Task**: Identify minimum latency achievable for rhythm synchronization.

**Findings**:
- End-to-end latency consists of: Audio processing (Dart) + MethodChannel overhead + Android System Service latency + Hardware response time.
- Dart/Flutter processing of 20ms chunks is efficient enough to keep processing latency low (<5-10ms).
- The main bottleneck is the Android system's vibration service and hardware response, which typically ranges from 10ms to 30ms on modern devices.
- Total expected latency should be within the <50ms target required by `SC-001`.

**Decision**: Proceed with 20ms chunks as they provide a good balance between processing frequency and system overhead.

### 3. FFmpeg Raw PCM Output to Dart
**Task**: Determine the best way to pipe FFmpeg raw PCM output into a Dart stream.

**Findings**:
- Using `ffmpeg_kit_flutter`, we can execute an FFmpeg command that outputs to a file or stdout.
- For real-time streaming, writing to a temporary file and reading it in chunks is more stable on Android than trying to capture stdout directly through MethodChannels, which can have overhead.
- Alternatively, if the audio source is already available as a stream (e.g., from `just_audio`), we might be able to intercept the byte buffer directly without an extra FFmpeg process for the haptic path.

**Decision**: Initially, investigate using `ffmpeg_kit_flutter` to output raw PCM to a temporary file that our `HapticPCMProcessor` can read as a stream.

## Summary of Decisions
- **Amplitude Control**: Use `VibrationEffect` via `advanced_haptics`.
- **Chunk Size**: 20ms chunks for processing.
- **Data Flow**: FFmpeg -> Raw PCM File/Stream -> Dart RMS Processor -> Haptic Service.
