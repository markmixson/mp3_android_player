import 'package:flutter/foundation.dart';
import 'package:mp3_android_player/processors/haptic_pcm_processor.dart';
import 'package:mp3_android_player/wrappers/advanced_haptics_wrapper.dart';
import 'package:mp3_android_player/services/haptic_service_interface.dart';

class DefaultHapticService implements HapticService {
  final AdvancedHapticsWrapper _hapticsWrapper;
  final HapticPCMProcessor _processor;

  DefaultHapticService({
    required AdvancedHapticsWrapper hapticsWrapper,
    required HapticPCMProcessor processor,
  }) : _hapticsWrapper = hapticsWrapper,
       _processor = processor;

  @override
  Future<int> playHapticPattern(
    List<int> pattern,
    final int sampleWindowDurationMillis,
    [final bool skip = false]
  ) async {
    if (pattern.isNotEmpty && !skip) {
      final amplitudes = _processor.processPcmData(pattern);
      try {
        await _hapticsWrapper.playWaveform(
          List.filled(amplitudes.length, sampleWindowDurationMillis),
          amplitudes,
        );
        return amplitudes.length;
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
