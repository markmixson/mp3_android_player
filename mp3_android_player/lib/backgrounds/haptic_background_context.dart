import 'dart:async';
import 'dart:isolate';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:mp3_android_player/models/haptic_mode.dart';
import 'package:mp3_android_player/processors/haptic_pcm_processor.dart';
import 'package:mp3_android_player/services/haptic_service_interface.dart';

class HapticBackgroundContext {
  static const Duration sampleWindowSize = Duration(milliseconds: 20);

  static final processor = HapticPCMProcessor(
    sampleRate: 44100,
    windowDuration: sampleWindowSize,
  );

  HapticBackgroundContext({
    HapticMode hapticMode = HapticMode.disabled,
    CancelableOperation? cancelableDelay,
  });

  late ReceivePort receivePort = ReceivePort();
  final StreamController<List<int>> hapticsController =
      StreamController<List<int>>();

  HapticMode hapticMode = HapticMode.disabled;
  CancelableOperation? pcmProcessing;
  CancelableOperation? hapticPlaying;
  CancelableOperation? delay;
  StreamIterator<List<int>>? hapticsIterator;

  bool _paused = false;
  bool get paused => _paused;
  set setPaused(final bool isPaused) {
    _paused = isPaused;
  }

  Future<void> dispose(
    final SendPort sendPort,
    final StreamSubscription<dynamic> subscription,
  ) async {
    setPaused = true;
    receivePort.close();
    await hapticsIterator?.cancel();
    await hapticsController.close();
    await pcmProcessing?.cancel();
    await hapticPlaying?.cancel();
    await delay?.cancel();
    await subscription.cancel();
    sendPort.send('done');
  }

  Future<void> pause() async {
    setPaused = true;
    await hapticPlaying?.cancel();
    await delay?.cancel();
  }

  bool get isHapticPlayingCanceled =>
      (hapticPlaying?.isCanceled ?? true) || hapticsController.isClosed;

  // coverage:ignore-start

  bool get isDelayCanceled =>
      (delay?.isCanceled ?? true) || hapticsController.isClosed;

  // coverage:ignore-end

  Future<bool> get isNextHaptics async {
    if (paused) {
      return false;
    }
    return await hapticsIterator?.moveNext() ?? false;
  }
      

  Future<List<int>> getAmplitudes(final List<int> pcmData) async {
    pcmProcessing = CancelableOperation.fromFuture(
      processor.processPcmData(pcmData),
    );
    final amplitudes = await pcmProcessing?.value ?? [];
    debugPrint(
      "processed ${pcmData.length / 2} pcm 16-bit samples and generated ${amplitudes.length} amplitudes",
    );
    return amplitudes;
  }

  Future<void> getHapticResult(
    final HapticService hapticService,
    final List<int> amplitudes,
  ) async {
    hapticPlaying = CancelableOperation.fromFuture(
      hapticService.playHapticPattern(
        amplitudes,
        sampleWindowSize.inMilliseconds,
        hapticMode == HapticMode.disabled,
      ),
    );
    final count = await hapticPlaying?.value ?? 0;
    debugPrint(
      "haptics running $count amplitudes over ${sampleWindowSize.inMilliseconds * amplitudes.length} ms (haptic mode skip: ${hapticMode == HapticMode.disabled}) - $amplitudes",
    );
  }

  Future<void> doDelay(final int count) async {
    delay = CancelableOperation.fromFuture(
      Future.delayed(
        Duration(milliseconds: count * sampleWindowSize.inMilliseconds),
      ),
    );
    await delay?.value;
  }
}
