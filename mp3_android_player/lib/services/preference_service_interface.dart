import 'package:mp3_android_player/models/haptic_mode.dart';

abstract class PreferenceService {
  Future<void> setHapticMode(HapticMode mode);
  Future<HapticMode> getHapticMode();
}
