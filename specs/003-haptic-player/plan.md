# Implementation Plan: haptic-player

**Feature Branch**: `003-haptic-player`

**Created**: 2026-06-18

**Status**: Draft

**Input**: User requirement to pipe haptic audio filter data to Android haptics instead of audio speaker. Approach: Output PCM from FFmpeg, chunk the stream (20ms), calculate RMS amplitude, map to 0-255, and use `advanced_haptics`.

## Technical Context

### Architecture Overview
The implementation will involve intercepting the audio data stream from the existing haptic audio filter and routing the calculated amplitude to the Android vibration motor via a haptics service.

### Component Breakdown
- **Audio Filter Interception**: Modify the existing audio filter service to expose a raw PCM stream (44.1kHz, 16-bit) via a Dart Stream for real-time processing.
- **Amplitude Processor**: A new Dart component to process PCM chunks (20ms) and calculate RMS amplitude.
- **Haptics Service**: A service that maps amplitude (0-255) and communicates with the Android Haptics API (via `advanced_haptics`).
- **UI Toggle**: A setting in the user interface to enable/disable haptic feedback.

### Technical Decisions
| Decision | Rationale |
| :--- | :--- |
| **PCM Chunk Size** | 20ms (approx. 882 samples at 44.1kHz) to balance latency and processing overhead. |
| **Amplitude Metric** | Root Mean Square (RMS) for accurate loudness representation. |
| **Haptics API** | Use `advanced_haptics` for custom waveform/amplitude control on Android. |
| **Mapping** | Linear mapping of RMS to 0-255 scale. |

## Constitution Check

### Violations
- None.

---

## Phases

### Phase 0: Research

| Task | Description | Status |
| :--- | :--- | :--- |
| Research `advanced_haptics` package | Verify API for custom waveforms and amplitude control. | NEEDS CLARIFICATION |
| Research Android Haptics Latency | Identify minimum latency achievable for rhythm synchronization. | NEEDS CLARIFICATION |

### Phase 1: Design & Contracts

#### Data Model
- **HapticAmplitudeSample**: A structure containing `amplitude` (int 0-255) and `timestamp` (DateTime).

#### Contracts
- **`HapticService` Interface**:
    - `void playHapticPattern(List<HapticAmplitudeSample> pattern)`
    - `void stopHaptics()`
    - `bool isHapticsEnabled`

#### Quickstart Validation Guide
1. **Setup**: Install `advanced_haptics` in `pubspec.yaml`.
2. **Verify Audio Source**: Ensure FFmpeg output is 16-bit PCM.
3. **Test Synchronization**: Play a song with a strong beat and verify vibration pattern timing.

### Phase 2: Implementation Tasks

- [ ] **T001**: Implement PCM stream processing logic in `lib/helpers/haptic_pcm_processor.dart`.
- [ ] **T002**: Implement `HapticService` using `advanced_haptics`.
- [ ] **T003**: Integrate `HapticService` into the audio playback flow.
- [ ] **T004**: Add UI toggle in `player_screen.dart` to enable/disable haptics.

### Phase 3: Verification Tasks

- [ ] **T005**: Unit test `HapticPCMProcessor` with mock PCM data.
- [ ] **T006**: Integration test audio playback with haptic output enabled.
- [ ] **T007**: Performance test for latency (target <50ms).

## Completion Report

- **Branch**: `003-haptic-player`
- **Plan Path**: `specs/003-haptic-player/plan.md`
- **Artifacts Generated**:
    - `specs/003-haptic-player/spec.md`
    - `specs/003-haptic-player/checklists/requirements.md`
    - `specs/003-haptic-player/plan.md`
