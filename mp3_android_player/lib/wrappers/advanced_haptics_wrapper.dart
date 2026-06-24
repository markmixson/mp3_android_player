import 'package:advanced_haptics/advanced_haptics.dart';
import 'package:flutter/rendering.dart';

// coverage:ignore-file
class AdvancedHapticsWrapper {
  Future<void> playWaveform(final List<int> timings, final List<int> amplitudes) async {
    debugPrint("playing waveForms with ${timings.length} timings and ${amplitudes.length} amplitudes");
    final output = await AdvancedHaptics.playWaveform(timings, amplitudes);
    debugPrint("Finished playing waveForms with ${timings.length} timings and ${amplitudes.length} amplitudes");
    return output;
  }

  Future<void> stop() async {
    return await AdvancedHaptics.stop();
  }
}
