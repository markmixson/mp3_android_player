import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mp3_android_player/models/haptic_mode.dart';
import 'package:mp3_android_player/services/default_haptic_service.dart';
import 'package:mp3_android_player/services/haptic_service_interface.dart';
import 'package:mp3_android_player/backgrounds/haptic_background_context.dart';
import 'package:mp3_android_player/wrappers/advanced_haptics_wrapper.dart';
import 'package:mp3_android_player/wrappers/ensure_initialized_wrapper.dart';

class HapticBackground {
  static final AdvancedHapticsWrapper wrapper = AdvancedHapticsWrapper();

  static final HapticService hapticService = DefaultHapticService(
    hapticsWrapper: wrapper,
  );

  static Future<SendPort> runInBackground(final ReceivePort receivePort) async {
    Isolate.spawn(consumerIsolate, receivePort.sendPort);
    final SendPort sendPort = await receivePort.first;
    return sendPort;
  }

  static void consumerIsolate(final SendPort mainSendPort) async {
    final context = HapticBackgroundContext();
    _doSetup(context, mainSendPort);
    while (await context.isNextHaptics) {
      final amplitudes = context.hapticsIterator!.current;
      await context.getHapticResult(hapticService, amplitudes);
      if (context.isHapticPlayingCanceled) {
        break;
      }
      await context.doDelay(amplitudes.length);
      if (context.isDelayCanceled) {
        break;
      }
    }
  }

  static void _doSetup(
    final HapticBackgroundContext context,
    final SendPort sendPort,
  ) {
    late StreamSubscription<dynamic> inputSubscription;
    inputSubscription = context.receivePort.listen((message) async {
      switch (message) {
        case List<int> pcmData:
          final amplitudes = await context.getAmplitudes(pcmData);
          context.hapticsController.sink.add(amplitudes);
        case HapticMode hapticMode:
          context.hapticMode = hapticMode;
        case RootIsolateToken? token:
          await EnsureInitializedWrapper.ensureInitialized(token, wrapper);
        case 'done':
          await context.dispose(sendPort, inputSubscription);
        default:
          debugPrint("got unknown message: $message");
      }
    });
    context.hapticsIterator = StreamIterator(context.hapticsController.stream);
    sendPort.send(context.receivePort.sendPort);
  }
}
