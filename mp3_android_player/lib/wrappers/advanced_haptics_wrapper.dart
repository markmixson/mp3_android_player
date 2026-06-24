import 'package:advanced_haptics/advanced_haptics.dart';

// coverage:ignore-file
class AdvancedHapticsWrapper {
  Future<void> playWaveform(final List<int> timings, final List<int> amplitudes) async {
    return AdvancedHaptics.playWaveform(timings, amplitudes);
  }

  Future<void> stop() async {
    return AdvancedHaptics.stop();
  }
}
