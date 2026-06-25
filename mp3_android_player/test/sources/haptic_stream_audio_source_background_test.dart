import 'dart:async';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mp3_android_player/models/haptic_mode.dart';
import 'package:mp3_android_player/services/haptic_service_interface.dart';
import 'package:mp3_android_player/sources/haptic_stream_audio_source_background.dart';

class MockHapticService extends Mock implements HapticService {}

class MockRootIsolateToken extends Mock implements RootIsolateToken {}

void main() {
  late MockHapticService mockHapticService;

  setUp(() {
    mockHapticService = MockHapticService();
    HapticStreamAudioSourceBackground.hapticService = mockHapticService;
  });

  group('HapticStreamAudioSourceBackground', () {
    test('applyHapticsAndSleep calls playHapticPattern when enabled', () async {
      final list = [1, 2, 3];
      when(
        () => mockHapticService.playHapticPattern(any(), any(), any()),
      ).thenAnswer((_) async => 0);

      // Act
      await HapticStreamAudioSourceBackground.applyHapticsAndSleep(
        list,
        HapticMode.enabled,
        false,
      );

      // Assert
      verify(
        () => mockHapticService.playHapticPattern(list, 20, false),
      ).called(1);
    });

    test(
      'applyHapticsAndSleep does not call playHapticPattern when disabled',
      () async {
        // Arrange
        final list = [1, 2, 3];

        // Act
        await HapticStreamAudioSourceBackground.applyHapticsAndSleep(
          list,
          HapticMode.disabled,
          false,
        );

        // Assert
        verifyNever(() => mockHapticService.playHapticPattern(any(), any()));
      },
    );

    test('consumerIsolate handles messages correctly', () async {
      final receivePort = ReceivePort();
      final Completer completer = Completer();

      Isolate.spawn(
        HapticStreamAudioSourceBackground.consumerIsolate,
        receivePort.sendPort,
      );
      final subscription = receivePort.listen((data) {
        if (data is SendPort) {
          final sendPort = data;
          sendPort.send(HapticMode.enabled);
          sendPort.send(true);
          sendPort.send([1, 2]);
          sendPort.send(123456);
          sendPort.send('done');
        } else if (data is String) {
          completer.complete();
        }
      });

      await completer.future;
      subscription.cancel();
    });

    test('runInBackground handles null rootToken', () async {
      final receivePort = ReceivePort();

      final sendPort = await HapticStreamAudioSourceBackground.runInBackground(
        receivePort,
        null,
      );

      sendPort.send('done');
      receivePort.close();
    });
  });
}
