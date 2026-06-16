# Research: Haptic Audio Filter

**Feature**: haptic-audio-filter
**Status**: In-Progress

## Phase 0: Research Tasks

### 1. FFmpeg & Low-Pass Filter
- **Task**: Research the exact `ffmpeg_kit_audio_flutter` command for applying a 500Hz low-pass filter.
- **Objective**: Identify the correct filter string (e.g., `lowpass=f=500`) and ensure it works for common audio formats (mp3, wav).
- **Decision**: [PENDING]
- **Rationale**: [PENDING]
- **Alternatives considered**: [PENDING]

### 2. Temporary File Management
- **Task**: Research best practices for managing temporary audio files in Flutter (using `path_provider`).
- **Objective**: Ensure files are stored in a directory that is cleaned up properly and doesn't leak storage.
- **Decision**: [PENDING]
- **Rationale**: [PENDING]
- **Alternatives considered**: [PENDING]

### 3. `just_audio` Custom `StreamAudioSource`
- **Task**: Research how to implement a custom `StreamAudioSource` in `just_audio` that reads from a file on disk.
- **Objective**: Ensure the source can efficiently handle the output from FFmpeg and provide a seamless playback experience.
- **Decision**: [PENDING]
- **Rationale**: [PENDING]
- **Alternatives considered**: [PENDING]

### 4. Latency and UX
- **Task**: Evaluate the latency introduced by FFmpeg processing on Android devices.
- **Objective**: Confirm if the processing time meets the performance goal of minimal latency for the user.
- **Decision**: [PENDING]
- **Rationale**: [PENDING]
- **Alternatives considered**: [PENDING]

## Unresolved Clarifications (from Spec)

- [ ] **FR-003**: Is 500Hz optimal for all haptic devices, or should this be a range? (User specified 500Hz in prompt, prioritizing this).
- [ ] **SC-002**: Maximum acceptable latency for switching modes.
- [ ] **SC-003**: Maximum allowed time for setting retrieval/application during startup.
