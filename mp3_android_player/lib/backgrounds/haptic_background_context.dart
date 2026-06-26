import 'dart:async';
import 'dart:isolate';

import 'package:async/async.dart';
import 'package:mp3_android_player/models/haptic_mode.dart';

class HapticBackgroundContext {
  HapticBackgroundContext({
    HapticMode hapticMode = HapticMode.disabled,
    CancelableOperation? cancelableDelay,
  });

  final ReceivePort receivePort = ReceivePort();
  final StreamController<List<int>> controller = StreamController<List<int>>();
  HapticMode hapticMode = HapticMode.disabled;
  CancelableOperation? pcmProcessing;
  CancelableOperation? hapticPlaying;
  CancelableOperation? delay;

  Future<void> dispose(
    final SendPort sendPort,
    final StreamSubscription<dynamic> subscription,
  ) async {
    receivePort.close();
    await controller.close();
    await pcmProcessing?.cancel();
    await hapticPlaying?.cancel();
    await delay?.cancel();
    sendPort.send('done');
    await subscription.cancel();
  }
}
