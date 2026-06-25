import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mp3_android_player/models/haptic_mode.dart';
import 'package:mp3_android_player/processors/haptic_pcm_processor.dart';
import 'package:mp3_android_player/services/default_haptic_service.dart';
import 'package:mp3_android_player/services/haptic_service_interface.dart';
import 'package:mp3_android_player/wrappers/advanced_haptics_wrapper.dart';

class HapticStreamAudioSourceBackground {
  static const Duration sampleWindowSize = Duration(milliseconds: 20);

  // coverage:ignore-start
  static HapticService hapticService = DefaultHapticService(
    hapticsWrapper: AdvancedHapticsWrapper(),
    processor: HapticPCMProcessor(
      sampleRate: 44100,
      windowDuration: sampleWindowSize,
    ),
  );

  static void Function(RootIsolateToken) ensureInitialized = (rootToken) {
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);
  };

  static Future<void> Function(int, bool) doSleep = (millis, skip) async {
    if (!skip) {
      Future.delayed(Duration(milliseconds: millis));
    }
  };
  // coverage:ignore-end

  static void consumerIsolate(final SendPort mainSendPort) async {
    final workerReceivePort = ReceivePort();
    HapticMode hapticMode = HapticMode.disabled;
    bool skip = false;
    late StreamSubscription<dynamic> subscription;
    subscription = workerReceivePort.listen((message) async {
      if (message is List<int>) {
        applyHapticsAndSleep(message, hapticMode, skip);
      } else if (message is HapticMode) {
        hapticMode = message;
      } else if (message is String && message == 'done') {
        workerReceivePort.close();
        mainSendPort.send('done');
        await subscription.cancel();
      } else if (message is bool) {
        skip = message;
      } else {
        debugPrint("got unknown message: $message");
      }
    });
    mainSendPort.send(workerReceivePort.sendPort);
  }

  static Future<void> applyHapticsAndSleep(
    final List<int> list,
    final HapticMode hapticMode,
    final bool skip,
  ) async {
    if (hapticMode == HapticMode.enabled) {
      await hapticService.playHapticPattern(
        list,
        sampleWindowSize.inMilliseconds,
        skip,
      );
    }
    final int millis = list.length * sampleWindowSize.inMilliseconds;
    await doSleep(millis, skip);
    debugPrint("played ${list.length} amplitudes over $millis ms");
  }

  static Future<SendPort> runInBackground(
    final ReceivePort receivePort,
    final RootIsolateToken? rootToken,
  ) async {
    if (rootToken == null) {
      debugPrint("can't get root token!");
    } else {
      ensureInitialized(rootToken);
    }
    Isolate.spawn(consumerIsolate, receivePort.sendPort);
    final SendPort sendPort = await receivePort.first;
    return sendPort;
  }
}
