import 'package:advanced_haptics/advanced_haptics.dart';
import 'package:flutter/rendering.dart';

// coverage:ignore-file
class AdvancedHapticsWrapper {
  Future<bool> hasCustomHapticsSupport() {
    return AdvancedHaptics.hasCustomHapticsSupport();
  }

  Future<void> playWaveform(
    final List<int> timings,
    final List<int> amplitudes,
  ) async {
    try {
      await AdvancedHaptics.playWaveform(timings, amplitudes);
    } catch (e) {
      debugPrint("can't play haptics due to error! $e");
    }
    
  }

  Future<void> stop() async {
    debugPrint("stopped haptics");
    return await AdvancedHaptics.stop();
  }
}
