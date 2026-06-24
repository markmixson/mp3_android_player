import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mp3_android_player/processors/haptic_pcm_processor.dart';
import 'package:mp3_android_player/services/default_haptic_service.dart';
import 'package:mp3_android_player/services/haptic_service_interface.dart';
import 'package:mp3_android_player/wrappers/advanced_haptics_wrapper.dart';

// coverage:ignore-file
class HapticStreamAudioSourceBackground {
  static final Duration sampleWindowSize = Duration(milliseconds: 20);
  static final HapticService hapticService = DefaultHapticService(
    hapticsWrapper: AdvancedHapticsWrapper(),
    processor: HapticPCMProcessor(
      sampleRate: 44100,
      windowDuration: sampleWindowSize,
    ),
  );

  static void runInBackground(
    final List<int> list,
    final ReceivePort receivePort,
    final RootIsolateToken? rootToken
  ) async {
    Isolate.spawn((mainSendPort) async {
      initialize(rootToken);
      hapticService.playHapticPattern(
        list,
        sampleWindowSize.inMilliseconds,
      );
      mainSendPort.send(list);
    }, receivePort.sendPort);
  }

  static void initialize(final RootIsolateToken? rootToken) {
    if (rootToken == null) {
      debugPrint("can't get root token!");
    } else {
      BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);
    }
  }
}
