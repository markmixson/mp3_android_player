# Implementation Plan: haptic-audio-filter

**Branch**: `002-haptic-audio-filter` | **Date**: June 1, 2026 | **Spec**: [/Users/markmixson/Library/CloudStorage/OneDrive-BOOZALLENHAMILTON/Documents/mp3_android_player/specs/002-haptic-audio-filter/spec.md](/Users/markmixson/Library/CloudStorage/OneDrive-BOOZALLENHAMILTON/Documents/mp3_android_player/specs/002-haptic-audio-filter/spec.md)

**Input**: Feature specification from `/specs/002-haptic-audio-filter/spec.md`

## Summary

The user wants to implement a "Haptic Mode" that applies a 500Hz low-pass filter to the audio being played. This allows the audio to be used as a driver for haptic device output. 
**Technical Approach**: When activated, `ffmpeg_kit_audio_flutter` will be used to read the current audio file and write a filtered version (500Hz low-pass) to a temporary folder. A custom `just_audio` `StreamAudioSource` will then read this temporary file and render the output.

## Technical Context

**Language/Version**: Dart (Flutter)

**Primary Dependencies**: 
- `just_audio` (Audio playback)
- `ffmpeg_kit_audio_flutter` (Audio processing)
- `path_provider` (Temporary folder access)
- `flutter_riverpod` (State management/DI)

**Storage**: Temporary directory for filtered audio files.

**Testing**: Unit tests for the filtering logic wrapper and widget tests for the UI toggle.

**Target Platform**: Android

**Project Type**: Mobile App (Flutter)

**Performance Goals**: 
- Low latency between toggling "Haptic Mode" and playback of the filtered file.
- Minimal impact on system resources during FFmpeg processing.

**Constraints**: 
- Low-pass cutoff must be exactly 500Hz.
- Temporary files must be cleaned up to avoid storage bloat.

**Scale/Scope**: Addition of a single toggle to the existing player UI and a new audio processing service.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [X] **Comprehensive Test Coverage**: New service and custom `StreamAudioSource` must have tests.
- [X] **Abstraction-First Design**: Filtering logic should be abstracted behind the `AudioPlayerService`.
- [X] **Final Method Parameters**: All new methods will use `final`.
- [X] **Parameterized Testing**: Test different audio file formats for FFmpeg compatibility.
- [X] **Stream-Oriented Processing**: Use streams for playback state and file processing progress.
- [X] **Asynchronous Preference**: All FFmpeg and file I/O operations will be `async`.

## Project Structure

### Documentation (this feature)

```text
specs/002-haptic-audio-filter/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
lib/
├── models/              # Updated with HapticMode state if necessary
├── providers/           # New/Updated providers for HapticMode and Filtered Audio
├── services/            # New HapticFilterService and updated AudioPlayerService
└── ui/                  # Updated PlayerScreen with Haptic toggle
```

**Structure Decision**: Extending existing `lib/` structure by adding a new service and updating existing providers/UI.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A       | N/A        | N/A                                 |
