# Tasks: haptic-player

## Phase 1: Setup
**Goal**: Initialize project dependencies for haptic support.
**Independent Test Criteria**: `pubspec.yaml` contains the `advanced_haptics` dependency.

- [X] T001 [P] Add `advanced_haptics` dependency to `pubspec.yaml`

## Phase 2: Foundational
**Goal**: Establish core data models and services for PCM processing and haptics.
**Independent Test Criteria**: Services can be instantiated and PCM data is correctly produced by the filter service.

- [X] T002 [P] Update `lib/services/default_low_pass_filter_service.dart` to produce PCM audio data instead of MP3 (FR-005)
- [X] T003 [P] Create `HapticAmplitudeSample` model in `lib/models/haptic_amplitude_sample.dart`
- [x] T004 [P] Define `HapticService` interface in `lib/services/haptic_service_interface.dart`
- [X] T005 [P] Implement `HapticPCMProcessor` in `lib/helpers/haptic_pcm_processor.dart` to calculate RMS amplitude from 20ms PCM chunks and filter signal transients (ER-003)
- [X] T006 [P] Implement `DefaultHapticService` in `lib/services/default_haptic_service.dart` using the `advanced_haptics` package.

## Phase 3: User Story 1 - Pipe haptic data to Android haptics (P1)
**Goal**: Route haptic data from the audio stream to the device's vibration motor while silencing regular audio.
**Independent Test Criteria**: Vibration occurs in sync with music and speaker is silent when haptics are active.

- [ ] T007 [US1] Integrate `HapticService` into `lib/providers/player_notifier.dart` to route processed PCM data to the service
- [ ] T008 [US1] Make toggle switch give Haptic Feedback instead of low pass audio in `lib/ui/player_screen.dart`
- [ ] T009 [US1] Implement error handling in `lib/services/default_haptic_service.dart` to revert to regular audio if the haptics API fails (EH-001)

## Phase 4: User Story 2 - Consistent Haptic Feedback (P2)
**Goal**: Ensure high-fidelity, low-latency haptic feedback that matches the rhythm of the music.
**Independent Test Criteria**: Latency between audio processing and vibration is <50ms.

- [ ] T010 [US2] Optimize `lib/helpers/haptic_pcm_processor.dart` for minimal latency (<50ms)
- [ ] T011 [US2] Implement integration test in `test/services/default_audio_player_service_test.dart` to verify haptic synchronization

## Phase 5: Polish & Cross-Cutting Concerns
**Goal**: Ensure code quality through comprehensive testing and error handling.
**Independent Test Criteria**: All unit and integration tests pass.

- [ ] T012 [P] Add integration tests for haptic playback flow in `test/services/default_audio_player_service_test.dart`

## Dependencies & Execution Order

### Phase Dependencies
T001 -> (T002, T003, T004) -> (T005, T006) -> (T007, T008, T009) -> (T010, T011) -> (T012)

### Parallel Opportunities
- All Setup tasks marked [P] can run in parallel.
- All Foundational tasks marked [P] can run in parallel once Setup is complete.
- Once Foundational phase completes, all user stories can start in parallel.
- All tests for a user story marked [P] can run in parallel.
- Models within a story marked [P] can run in parallel.
- Different user stories can be worked on in parallel by different team members.

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
