# Feature Specification: haptic-player

**Feature Branch**: `003-haptic-player`

**Created**: 2026-06-18

**Status**: Draft

**Input**: User description: "Create a specification 003-haptic-player which will pipe the haptic audio filter data to android haptics instead of audio speaker"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Pipe haptic data to Android haptics (Priority: P1)

Users should experience haptic feedback that is synchronized with the music, instead of receiving it as audio via the speaker. When in haptic mode, regular audio playback from `just_audio` should be silenced so only haptics are played. Switching back to non-haptic mode must return the user to regular audio playback seamlessly.

**Why this priority**: This is the core requirement of the feature.

**Independent Test**: Can be fully tested by playing audio and observing the device's vibration motor response synchronized with the audio filter output, while ensuring no audio is heard from the speaker when haptics are active.

**Acceptance Scenarios**:

1. **Given** the haptic audio filter is active, **When** audio with haptic metadata is played, **Then** the Android device produces vibration feedback instead of audio output for the filter component.

---

### User Story 2 - Consistent Haptic Feedback (Priority: P2)

Users should experience continuous and well-timed haptic patterns that match the rhythm/intensity of the audio being filtered.

**Why this priority**: Crucial for the user experience of haptic feedback.

**Independent Test**: Can be tested by playing rhythmic music and checking if vibration patterns match the beat.

**Acceptance Scenarios**:

1. **Given** an audio track with clear rhythmic patterns, **When** the filter is active, **Then** the haptic feedback timing is synchronized with the audio beat within an acceptable latency (e.g., <50ms).

---

### Edge Cases

- What happens when the device does not have a vibration motor?
- How does the system handle haptic feedback requests when the app is in the background?
- How does the system handle extremely low-frequency or high-frequency audio signal transients?

### Edge Case Requirements *(mandatory)*

- **ER-001**: If no vibration motor is detected, the system MUST gracefully fallback to regular audio playback without user intervention.
- **ER-002**: Haptic feedback must continue to function correctly when the app is in the background, provided audio playback is active.
- **ER-003**: The haptic engine MUST ignore signal transients that fall outside of the supported frequency range for the device's vibration motor (e.g., 20Hz - 500Hz).

### Error Handling

- **EH-001**: If the Android Haptics API fails to initialize or encounters an error during playback, the system MUST display a non-intrusive error message to the user and automatically revert to regular audio playback.

### Functional Requirements

- **FR-001**: System MUST intercept haptic data stream from the audio filter.
- **FR-002**: System MUST route haptic data stream to the Android Haptics API instead of the audio output stream.
- **FR-003**: System MUST ensure synchronization between the audio playback position and the haptic feedback trigger.
- **FR-004**: System MUST allow users to enable/disable haptic feedback via app settings.
- **FR-005**: The `default_haptic_filter_service.dart` service MUST be updated to produce PCM audio data instead of MP3 for the haptic processing pipeline.

### Non-Functional Requirements

- **NFR-001**: No specific logging or observability requirements are mandated for production environments at this stage, except where required to verify performance metrics (e.g., latency).

### Key Entities *(include if feature involves data)*

- **Haptic Data Stream**: The processed data from the audio filter intended for haptic feedback (44.1kHz, 16-bit PCM).
- **Android Haptics Engine**: The interface/service responsible for communicating with the device's vibration motor.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Latency between audio processing and haptic trigger is consistently under 50ms.
- **SC-002**: 100% of haptic data packets are processed and sent to the haptics API with less than 1% packet loss.
- **SC-003**: Users report that haptic feedback is well-synchronized with the music rhythm.

## Assumptions

- It is assumed that the Android device has a supported vibration motor and Haptics API.
- It is assumed that the existing audio filter can provide a data stream suitable for haptic feedback.
- It is assumed that the user has given necessary permissions for vibration/haptics.
