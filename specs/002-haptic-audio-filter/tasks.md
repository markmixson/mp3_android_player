# Tasks: haptic-audio-filter

**Feature**: haptic-audio-filter
**Status**: Generated from Plan

## Phase 1: Design & Contracts

### User Story 1 - Enable Haptic Filter [US1]
Goal: Enable toggling a low-pass filter via UI.

- [X] T001 [P] Define `HapticMode` state in `lib/models/audio_file.dart` or a new model file
- [X] T002 [P] Create `HapticFilterService` interface in `lib/services/haptic_filter_service_interface.dart`
- [X] T003 [P] Implement `HapticFilterService` using `ffmpeg_kit_audio_flutter` in `lib/services/default_haptic_filter_service.dart`
- [X] T004 [P] Implement custom `StreamAudioSource` in `lib/services/haptic_stream_audio_source.dart`
- [X] T005 [P] Update `AudioPlayerService` to incorporate `HapticFilterService` and handle source switching

### User Story 2 - Persistence of Haptic Setting [US2]
Goal: Remember haptic mode preference.

- [X] T006 [P] Update `PlayerNotifier` to manage and persist `HapticMode` state
- [X] T007 [P] Implement preference persistence (e.g., using `shared_preferences`)

### Phase: UI Implementation
Goal: Add the toggle to the player interface.

- [ ] T008 [P] [US1] Add "Haptic Mode" toggle switch to `lib/ui/player_screen.dart`
- [ ] T009 [P] [US2] Connect toggle switch to `PlayerNotifier`

### Phase: Polish & Cross-Cutting Concerns
Goal: Cleanup and robustness.

- [ ] T010 [P] Implement temporary file cleanup logic in `HapticFilterService`
- [ ] T011 [P] Add unit tests for `HapticFilterService` and `HapticStreamAudioSource`
- [ ] T012 [P] Add widget tests for the new UI toggle in `lib/ui/player_screen_test.dart`
