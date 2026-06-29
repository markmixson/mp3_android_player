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

  final ReceivePort receivePort = ReceivePort();
  final StreamController<List<int>> hapticsController =
      StreamController<List<int>>();

  HapticMode hapticMode = HapticMode.disabled;
  CancelableOperation? pcmProcessing;
  CancelableOperation? hapticPlaying;
  CancelableOperation? delay;
  StreamIterator<List<int>>? hapticsIterator;

  Future<void> dispose(
    final SendPort sendPort,
    final StreamSubscription<dynamic> subscription,
  ) async {
    receivePort.close();
    await hapticsController.close();
    await hapticsIterator?.cancel();
    await pcmProcessing?.cancel();
    await hapticPlaying?.cancel();
    await delay?.cancel();
    sendPort.send('done');
    await subscription.cancel();
  }

  bool get isHapticPlayingCanceled => hapticPlaying?.isCanceled ?? true;
  bool get isDelayCanceled => delay?.isCanceled ?? true;
  Future<bool> get isNextHaptics async =>
      await hapticsIterator?.moveNext() ?? false;

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
      "haptics running $count amplitudes over ${sampleWindowSize.inMilliseconds * amplitudes.length} ms (haptic mode skip: ${hapticMode == HapticMode.disabled})",
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
