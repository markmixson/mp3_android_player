import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mp3_android_player/sources/haptic_stream_audio_source.dart';

class MockFile extends Mock implements File {}

class MockHapticStreamAudioSourceBackground extends Mock {
  void runInBackground(List<int> list, ReceivePort receivePort);
}

void main() {
  group('LowPassStreamAudioSource', () {
    late MockFile mockFile;
    late MockHapticStreamAudioSourceBackground mockBackground;
    const String testContentType = 'audio/mpeg';

    setUp(() {
      mockFile = MockFile();
      mockBackground = MockHapticStreamAudioSourceBackground();
      registerFallbackValue(Duration(milliseconds: 20));
      registerFallbackValue(ReceivePort());
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
        },
        {
          'start': 0,
          'end': 50,
          'fileLength': 100,
          'expectedContentLength': 50,
          'expectedOffset': 0,
          'description': 'partial file (start=0, end=50)',
        },
        {
          'start': 10,
          'end': 90,
          'fileLength': 100,
          'expectedContentLength': 80,
          'expectedOffset': 10,
          'description': 'middle segment (start=10, end=90)',
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

        test(description, () async {
          when(
            () => mockFile.length(),
          ).thenAnswer((_) async => fileLength.toInt());
          when(() => mockFile.openRead(any(), any())).thenAnswer(
            (_) => Stream.value(List.filled(10, 0)).asBroadcastStream(),
          );
          when(() => mockBackground.runInBackground(any(), any())).thenAnswer((
            invocation,
          ) async {
            final list = invocation.positionalArguments[0] as List<int>;
            final receivePort =
                invocation.positionalArguments[1] as ReceivePort;
            Isolate.spawn((mainSendPort) {
              mainSendPort.send(list);
            }, receivePort.sendPort);
          });
          final source = HapticStreamAudioSource(
            mockFile,
            testContentType,
            mockBackground.runInBackground,
          );

          final response = await source.request(start, end);
          response.stream.listen(
            (data) {
              expect(data, List.filled(10, 0));
            },
            onError: (error) {
              fail('stream value did not return as expected!');
            },
          );

          expect(response.sourceLength, equals(fileLength.toDouble()));
          expect(response.contentLength, equals(expectedContentLength));
          expect(response.offset, equals(expectedOffset));
          expect(response.contentType, equals(testContentType));
          expect(response.stream, isA<Stream<List<int>>>());
          await response.stream.drain();
        });
      }
    });
  });
}
