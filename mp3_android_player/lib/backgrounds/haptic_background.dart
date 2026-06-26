import 'dart:async';
import 'dart:isolate';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mp3_android_player/models/haptic_mode.dart';
import 'package:mp3_android_player/processors/haptic_pcm_processor.dart';
import 'package:mp3_android_player/services/default_haptic_service.dart';
import 'package:mp3_android_player/services/haptic_service_interface.dart';
import 'package:mp3_android_player/backgrounds/haptic_background_context.dart';
import 'package:mp3_android_player/wrappers/advanced_haptics_wrapper.dart';
import 'package:mp3_android_player/wrappers/ensure_initialized_wrapper.dart';

class HapticBackground {
  static const Duration sampleWindowSize = Duration(milliseconds: 20);
  static final processor = HapticPCMProcessor(
    sampleRate: 44100,
    windowDuration: sampleWindowSize,
  );

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
    await for (final pcmData in context.controller.stream) {
      context.cancelableOperation = CancelableOperation.fromFuture(
        Future.forEach(processor.processPcmData(pcmData), (amplitude) async {
          await hapticService.playHapticPattern(
            [amplitude],
            sampleWindowSize.inMilliseconds,
            context.hapticMode == HapticMode.disabled,
          );
          await Future.delayed(sampleWindowSize);
        }),
      );
      await context.cancelableOperation?.value;
    }
  }

  static void _doSetup(
    final HapticBackgroundContext context,
    final SendPort sendPort,
  ) {
    late StreamSubscription<dynamic> subscription;
    subscription = context.receivePort.listen((message) async {
      switch (message) {
        case List<int> pcmData:
          context.controller.sink.add(pcmData);
        case HapticMode hapticMode:
          context.hapticMode = hapticMode;
        case RootIsolateToken? token:
          await EnsureInitializedWrapper.ensureInitialized(token, wrapper);
        case 'done':
          await context.dispose(sendPort, subscription);
        default:
          debugPrint("got unknown message: $message");
      }
    });
    sendPort.send(context.receivePort.sendPort);
  }
}
