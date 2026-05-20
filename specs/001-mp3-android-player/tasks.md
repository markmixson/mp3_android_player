# Tasks: MP3 Android Player

## Phase 0: Research

- [X] T000 Research `flutter_riverpod` patterns for injecting service interfaces and managing complex audio state in `lib/`

## Phase 1: Setup
- [X] T001 Initialize Flutter project for Android with `flutter create --platforms android mp3_android_player`
- [X] T002 Configure Android permissions in `android/app/src/main/AndroidManifest.xml` (READ_EXTERNAL_STORAGE, etc.)
- [X] T003 Add dependencies `just_audio` and `file_picker` to `pubspec.yaml`
- [X] T004 [P] Verify project initialization and dependency loading

## Phase 2: Foundational
- [X] T005 [P] Define `AudioFile` model in `lib/models/audio_file.dart`
- [X] T006 [P] Create `AudioPlayerService` interface in `lib/services/audio_player_service_interface.dart`
- [X] T007 [P] Create `AudioFilePickerService` interface in `lib/services/audio_file_picker_service_interface.dart`

## Phase 3: [US1] Core Playback & File Selection
- [X] T008 [US1] Implement `DefaultAudioFilePickerService` in `lib/services/default_audio_file_picker_service.dart`
- [X] T009 [US1] Implement `DefaultAudioPlayerService` in `lib/services/default_audio_player_service.dart` using `just_audio`
- [X] T010 [US1] Create basic player UI in `lib/ui/player_screen.dart`
- [X] T011 [US1] Integrate `AudioFilePickerService` with UI in `lib/ui/player_screen.dart`
- [X] T012 [US1] Integrate `AudioPlayerService` with UI in `lib/ui/player_screen.dart`
- [X] T013 [US1] Define Riverpod providers for `AudioPlayerService` and `AudioFilePickerService` in `lib/providers.dart`
- [X] T014 [US1] Create `PlayerNotifier` (Riverpod) to manage the current playback state and interaction in `lib/providers/player_notifier.dart`
- [X] T015 [US1] Verify playback control latency (<200ms) and file selection success
- [X] T016 [US1] Verify file load time requirement (< 2s)

## Phase 4: Polish & Cross-Cutting
- [X] T017 Implement error handling for file selection and playback in `lib/services/`
- [X] T018 Add unit tests for `DefaultAudioPlayerService` in `test/services/default_audio_player_service_test.dart`
- [X] T019 Add unit tests for `DefaultAudioFilePickerService` in `test/services/default_audio_file_picker_service_test.dart`
- [X] T020 Add unit tests for `PlayerScreen` in `test/ui/`
- [X] T021 Final UI polish and layout adjustments in `lib/ui/`
- [X] T022 [P] Add unit tests for Riverpod providers in `test/providers/`

## Dependencies
- Phase 2 depends on Phase 1.
- Phase 3 depends on Phase 2.
- Phase 4 depends on Phase 3.

## Parallel Execution Examples
- T007 and T008 can be developed in parallel once interfaces are defined.
- T013 and T014 can be developed in parallel with UI implementation.

## Implementation Strategy
- **MVP**: Focus on single file selection and basic play/pause/seek functionality.
- **Incremental**: Add error handling and advanced UI features in Phase 4.
