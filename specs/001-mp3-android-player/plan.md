# IMPL_PLAN: MP3 Android Player (Flutter)

## Technical Context

### Technology Stack
- **Framework**: Flutter
- **Platform Target**: Android only
- **Core Audio Library**: `just_audio`
- **File Selection Library**: `file_picker`
- **State Management & DI**: `flutter_riverpod`
- **Language**: Dart

### Implementation Details
- Android sdk 36.1.0 supported.
- Application does not need to handle audio focus (e.g., when receiving a phone call).
- Persistence of playback position if the app is backgrounded/killed is not important.
- **DI Strategy**: Use `Riverpod` providers to inject `AudioPlayerService` and `AudioFilePickerService` into the UI and other parts of the application.
- **State Management Strategy**: Use `StateNotifier` or `AsyncNotifier` (via Riverpod) to manage `PlaybackState` and current `AudioFile`.

## Constitution Check
- [X] **Comprehensive Test Coverage**: All logic (player controller, file selection) must have unit and widget tests.
- [X] **Abstraction-First Design**: Audio playback logic will be abstracted behind an `AudioPlayerService` interface.
- [X] **Final Method Parameters**: All methods will use `final` parameters when possible.
- [X] **Parameterized Testing**: Audio playback and file validation tests will be parameterized.
- [X] **Stream-Oriented Processing**: `just_audio` streams will be used for position and duration updates.
- [X] **Asynchronous Preference**: All file I/O and audio operations will be `async` when possible or practical.

## Phase 0: Research
- [X] Research `just_audio` best practices for Android audio focus.
- [X] Research `file_picker` permissions for Android (Scoped Storage).
- [X] Research Flutter background execution for audio playback.
- [X] Research `flutter_riverpod` patterns for injecting service interfaces and managing complex audio state.

## Phase 1: Design & Contracts

### Data Model (`data-model.md`)
- `AudioFile`: `String path`, `String name`, `Duration duration`.
- `PlaybackState`: `Playing | Paused | Stopped`.

### Contracts (`/contracts/`)
- `AudioPlayerService`: `play(AudioFile)`, `pause()`, `seek(Duration)`, `streamPosition`.
- `AudioFilePickerService`: `pickFile() -> Future<AudioFile?>`.

### Quickstart (`quickstart.md`)
- Instructions on setting up the Flutter environment and adding dependencies (including `flutter_riverpod`).

## Phase 2: Implementation Plan
- [X] **Setup**: Initialize Flutter project, configure Android permissions, add dependencies (`just_audio`, `file_picker`, `flutter_riverpod`).
- [X] **Core Implementation**: Implement `AudioPlayerService` and `AudioFilePickerService`.
- [X] **Riverpod Integration**:
    - Define providers for `AudioPlayerService` and `AudioFilePickerService`.
    - Create a `PlayerNotifier` (Riverpod) to manage the current playback state and interaction.
- [X] **UI Implementation**: Build the main player interface and progress bar using `ConsumerWidget` or `ConsumerStatefulWidget`.
- [X] **Integration**: Wire Riverpod providers to the UI.
- [X] **Testing**: Implement unit and widget tests for all core logic and Riverpod providers.
