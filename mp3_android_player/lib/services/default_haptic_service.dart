import 'package:flutter/foundation.dart';
import 'package:mp3_android_player/wrappers/advanced_haptics_wrapper.dart';
import 'package:mp3_android_player/services/haptic_service_interface.dart';

class DefaultHapticService implements HapticService {
  final AdvancedHapticsWrapper _hapticsWrapper;

  DefaultHapticService({required AdvancedHapticsWrapper hapticsWrapper})
    : _hapticsWrapper = hapticsWrapper;

  @override
  Future<int> playHapticPattern(
    List<int> pattern,
    final int sampleWindowDurationMillis, [
    final bool skip = false,
  ]) async {
    if (pattern.isNotEmpty && !skip) {
      try {
        await _hapticsWrapper.playWaveform(
          List.filled(pattern.length, sampleWindowDurationMillis),
          pattern,
        );
        return pattern.length;
      } catch (e) {
        debugPrint('Error playing haptic pattern: $e');
      }
    }
    return 0;
  }

  @override
  Future<void> stopHaptics() async {
    return _hapticsWrapper.stop();
  }
}
