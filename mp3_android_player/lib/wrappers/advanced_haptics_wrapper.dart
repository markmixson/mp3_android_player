import 'package:advanced_haptics/advanced_haptics.dart';
import 'package:flutter/rendering.dart';

// coverage:ignore-file
class AdvancedHapticsWrapper {
  Future<void> playWaveform(
    final List<int> timings,
    final List<int> amplitudes,
  ) async {
    await AdvancedHaptics.playWaveform(timings, amplitudes);
  }

  Future<void> stop() async {
    debugPrint("stopped haptics");
    return await AdvancedHaptics.stop();
  }
}
