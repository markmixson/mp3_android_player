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
          _generateFlattenedList(pattern.length, sampleWindowDurationMillis),
          _prependZeros(pattern),
        );
        return pattern.length;
      } catch (e) {
        debugPrint('Error playing haptic pattern: $e');
      }
    }
    return 0;
  }

  List<int> _prependZeros(final List<int> input) {
    return input.expand((element) => [0, element]).toList();
  }

  List<int> _generateFlattenedList(
    final int n,
    final int sampleWindowDurationMillis,
  ) {
    return List<int>.generate(
      n * 2,
      (index) => index % 2 == 0 ? 0 : sampleWindowDurationMillis,
    );
  }

  @override
  Future<void> stopHaptics() async {
    return _hapticsWrapper.stop();
  }
}
