import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mp3_android_player/models/haptic_mode.dart';
import 'package:mp3_android_player/sources/haptic_stream_audio_source.dart';

class MockFile extends Mock implements File {}

class MockHapticStreamAudioSourceBackground extends Mock {
  Future<SendPort> runInBackground(ReceivePort receivePort);
}

class MockRootIsolateToken extends Mock implements RootIsolateToken {}

class MockSendPort extends Mock implements SendPort {}

void main() {
  group('LowPassStreamAudioSource', () {
    late MockFile mockFile;
    late MockHapticStreamAudioSourceBackground mockBackground;
    late MockRootIsolateToken mockRootIsolateToken;
    const String testContentType = 'audio/mpeg';

    setUp(() {
      mockFile = MockFile();
      mockBackground = MockHapticStreamAudioSourceBackground();
      mockRootIsolateToken = MockRootIsolateToken();
      registerFallbackValue(Duration(milliseconds: 20));
      registerFallbackValue(ReceivePort());
    });

    group('dispose', () {
      test('called', () async {
        final sendPort = MockSendPort();
        when(
          () => mockBackground.runInBackground(any()),
        ).thenAnswer((_) async => sendPort);
        final source = await HapticStreamAudioSource.create(
          mockFile,
          testContentType,
          mockBackground.runInBackground,
          HapticMode.enabled,
          mockRootIsolateToken,
        );
        source.stop();
        verify(() => sendPort.send("done")).called(1);
      });
    });

    group('request', () {
      final testCases = [
        {
          'start': null,
          'end': null,
          'fileLength': 100,
          'expectedContentLength': 100,
          'expectedOffset': 0,
          'description': 'full file (start and end are null)',
          'hapticModeEnabled': true,
          'rootTokenAvailable': true,
          'toggleHapticMode': false,
        },
        {
          'start': 0,
          'end': 50,
          'fileLength': 100,
          'expectedContentLength': 50,
          'expectedOffset': 0,
          'description': 'haptic mode disabled',
          'hapticModeEnabled': false,
          'rootTokenAvailable': true,
          'toggleHapticMode': false,
        },
        {
          'start': 0,
          'end': 50,
          'fileLength': 100,
          'expectedContentLength': 50,
          'expectedOffset': 0,
          'description': 'haptic mode toggled',
          'hapticModeEnabled': false,
          'rootTokenAvailable': true,
          'toggleHapticMode': true,
        },
        {
          'start': 0,
          'end': 50,
          'fileLength': 100,
          'expectedContentLength': 50,
          'expectedOffset': 0,
          'description': 'partial file (start=0, end=50)',
          'hapticModeEnabled': true,
          'rootTokenAvailable': true,
          'toggleHapticMode': false,
        },
        {
          'start': 0,
          'end': 50,
          'fileLength': 100,
          'expectedContentLength': 50,
          'expectedOffset': 0,
          'description':
              'no root token available',
          'hapticModeEnabled': true,
          'rootTokenAvailable': false,
          'toggleHapticMode': false,
        },
        {
          'start': 10,
          'end': 90,
          'fileLength': 100,
          'expectedContentLength': 80,
          'expectedOffset': 10,
          'description': 'middle segment (start=10, end=90)',
          'hapticModeEnabled': true,
          'rootTokenAvailable': true,
          'toggleHapticMode': false,
        },
      ];

      for (var params in testCases) {
        final int? start = params['start'] as int?;
        final int? end = params['end'] as int?;
        final int fileLength = params['fileLength'] as int;
        final int expectedContentLength =
            params['expectedContentLength'] as int;
        final int expectedOffset = params['expectedOffset'] as int;
        final String description = params['description'] as String;
        final bool hapticModeEnabled = params['hapticModeEnabled'] as bool;
        final bool rootTokenAvailable = params['rootTokenAvailable'] as bool;
        final bool toggleHapticMode = params['toggleHapticMode'] as bool;

        test(description, () async {
          final mockSendPort = MockSendPort();
          when(
            () => mockFile.length(),
          ).thenAnswer((_) async => fileLength.toInt());
          when(() => mockFile.openRead(any(), any())).thenAnswer(
            (_) => Stream.value(List.filled(10, 0)).asBroadcastStream(),
          );
          when(
            () => mockBackground.runInBackground(any()),
          ).thenAnswer((_) async => mockSendPort);
          final initialHapticMode = hapticModeEnabled ? HapticMode.enabled : HapticMode.disabled;
          final source = await HapticStreamAudioSource.create(
            mockFile,
            testContentType,
            mockBackground.runInBackground,
            initialHapticMode,
            rootTokenAvailable ? mockRootIsolateToken : null,
          );

          if (toggleHapticMode) {
            final expectedToggle = hapticModeEnabled ? HapticMode.disabled : HapticMode.enabled;
            await source.setHapticMode(expectedToggle);
            verify(() => mockSendPort.send(initialHapticMode)).called(1);
            verify(() => mockSendPort.send(expectedToggle)).called(1);
          } else {
            verify(() => mockSendPort.send(anyOf(isA<HapticMode>()))).called(1);
          }

          final response = await source.request(start, end);
          response.stream.listen(
            (data) {
              expect(data, List.filled(10, 0));
            },
            onError: (error) {
              fail('stream value did not return as expected!');
            },
          );
          await response.stream.drain();

          expect(response.sourceLength, equals(fileLength.toDouble()));
          expect(response.contentLength, equals(expectedContentLength));
          expect(response.offset, equals(expectedOffset));
          expect(response.contentType, equals(testContentType));
          expect(response.stream, isA<Stream<List<int>>>());
        });
      }
    });
  });
}
