import 'dart:async';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mp3_android_player/backgrounds/haptic_background.dart';
import 'package:mp3_android_player/models/haptic_mode.dart';

void main() {

  group('HapticBackground', () {
    test('consumerIsolate handles messages correctly', () async {
      final receivePort = ReceivePort();
      final Completer completer = Completer();
      const RootIsolateToken? token = null;

      Isolate.spawn(
        HapticBackground.consumerIsolate,
        receivePort.sendPort,
      );
      final subscription = receivePort.listen((data) {
        if (data is SendPort) {
          final sendPort = data;
          sendPort.send(HapticMode.disabled);
          sendPort.send([1, 2]);
          sendPort.send(123456);
          sendPort.send('pause');
          sendPort.send('go');
          sendPort.send(token);
          sendPort.send('done');
        } else if (data is String) {
          completer.complete();
        }
      });

      await completer.future;
      subscription.cancel();
    });

    test('do runInBackground', () async {
      final receivePort = ReceivePort();

      final sendPort = await HapticBackground.runInBackground(
        receivePort,
      );

      sendPort.send('done');
      receivePort.close();
    });
  });
}
