import 'package:mp3_android_player/models/haptic_mode.dart';

// coverage:ignore-file
abstract class PreferenceService {
  Future<void> setHapticMode(HapticMode mode) async =>
      throw UnimplementedError();
  Future<HapticMode> getHapticMode() async => throw UnimplementedError();
}
