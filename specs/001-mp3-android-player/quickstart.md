# MP3 Android Player: Quickstart

## Prerequisites
- Flutter SDK installed and configured.
- Android Studio / Android SDK installed.
- An Android emulator or physical device.

## Setup Instructions

1. **Initialize Flutter Project**:
   ```bash
   flutter create --platforms android mp3_android_player
   cd mp3_android_player
   ```

2. **Add Dependencies**:
   Add the following to your `pubspec.yaml`:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     just_audio: ^0.9.36
     file_picker: ^11.0.2
     # Recommended for background playback
     audio_service: ^0.18.12 
   ```

3. **Android Configuration**:
   - Update `android/app/src/main/AndroidManifest.xml` to include necessary permissions:
     ```xml
     <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
     <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
     <!-- If using audio_service -->
     <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
     ```

4. **Run the App**:
   ```bash
   flutter run
   ```
