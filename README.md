# mp3_android_player

A Flutter-based mobile application for Android designed to play MP3 files from local storage.

## Functionality

The `mp3_android_player` provides a simple and intuitive interface for audio playback. Key features include:

- **File Selection**: Browse and select MP3 files directly from your device's local storage using a file picker.
- **Playback Controls**: 
  - **Play/Pause/Resume**: Easily control the audio playback.
  - **Seek**: Jump to different parts of the audio track using a seek bar.
- **Progress Tracking**: View real-time playback progress through a visual indicator.

## Getting Started

### Prerequisites

Before building and running the application, ensure you have the following installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (configured in your PATH)
- [Android SDK](https://developer.android.com/studio#install)
- An Android emulator or a physical Android device connected via USB.

### Build and Run

1. **Clone the repository** (if applicable):
   ```bash
   git clone <repository-url>
   cd mp3_android_player
   ```

2. **Get dependencies**:
   Install the required Flutter packages by running:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   Connect your device or start an emulator, then run:
   ```bash
   flutter run
   ```

## Development

To run tests, use:
```bash
flutter test
```

To build an APK for distribution:
```bash
flutter build apk
```

