import 'package:mp3_android_player/models/haptic_mode.dart';
import 'package:mp3_android_player/services/preference_service_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DefaultPreferenceService implements PreferenceService {
  static const String _hapticModeKey = 'haptic_mode';
  final SharedPreferences _sharedPreferences;

  DefaultPreferenceService(this._sharedPreferences);

  @override
  Future<void> setHapticMode(HapticMode mode) async {
    await _sharedPreferences.setString(_hapticModeKey, mode.name);
  }

  @override
  Future<HapticMode> getHapticMode() async {
    final modeName = _sharedPreferences.getString(_hapticModeKey);
    if (modeName != null) {
      return HapticMode.values.firstWhere(
        (m) => m.name == modeName,
        orElse: () => HapticMode.disabled,
      );
    }
    return HapticMode.disabled;
  }
}
