import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mp3_android_player/sources/haptic_stream_audio_source.dart';

class MockFile extends Mock implements File {}

void main() {
  group('HapticStreamAudioSource', () {
    late MockFile mockFile;
    const String testContentType = 'audio/mpeg';

    setUp(() {
      mockFile = MockFile();
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
          'streamError': false,
        },
        {
          'start': 0,
          'end': 50,
          'fileLength': 100,
          'expectedContentLength': 50,
          'expectedOffset': 0,
          'description': 'partial file (start=0, end=50)',
          'streamError': false,
        },
        {
          'start': 10,
          'end': 90,
          'fileLength': 100,
          'expectedContentLength': 80,
          'expectedOffset': 10,
          'description': 'middle segment (start=10, end=90)',
          'streamError': false,
        },
        {
          'start': 10,
          'end': 5,
          'fileLength': 100,
          'expectedContentLength': -5,
          'expectedOffset': 10,
          'description': 'bad segment (start=10, end=5)',
          'streamError': true,
        },
      ];

      for (var params in testCases) {
        final int? start = params['start'] as int?;
        final int? end = params['end'] as int?;
        final int fileLength = params['fileLength'] as int;
        final String description = params['description'] as String;
        final bool streamError = params['streamError'] as bool;

        test(description, () async {
          when(
            () => mockFile.length(),
          ).thenAnswer((_) async => fileLength.toInt());
          when(() => mockFile.openRead(any(), any())).thenAnswer(
            (_) => streamError
                ? Stream.error(Exception())
                : Stream.value(List.filled(10, 0)),
          );
          when(() => mockFile.path).thenReturn("file.mp3");
          final source = HapticStreamAudioSource(
            mockFile,
            testContentType,
          );

          final response = await source.request(start, end);

          expect(response.sourceLength, isNull);
          expect(response.contentLength, isNull);
          expect(response.offset, equals(0));
          expect(response.contentType, equals(testContentType));
          expect(response.stream, isA<Stream<List<int>>>());
          response.stream.listen(
            (data) {
              if (streamError) {
                fail('should not get data on a streamError');
              } else {
                expect(data.length, 10);
              }
            },
            onError: (error) {
              if (streamError) {
                expect(error, isA<Exception>());
              } else {
                fail('should not get error');
              }
            },
          );
        });
      }
    });
  });
}
