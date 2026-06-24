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
  Future<void> playHapticPattern(
    List<int> pattern,
    final Duration sampleWindowDuration,
  ) async {
    if (pattern.isNotEmpty) {
      final amplitudes = _processor.processPcmData(pattern);
      try {
        return _hapticsWrapper.playWaveform(
          List.filled(amplitudes.length, sampleWindowDuration.inMilliseconds),
          amplitudes,
        );
      } catch (e) {
        debugPrint('Error playing haptic pattern: $e');
      }
    }
  }

  @override
  Future<void> stopHaptics() async {
    await _hapticsWrapper.stop();
  }
}
