import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffmpeg_kit_audio_flutter/ffmpeg_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mp3_android_player/helpers/file_helper.dart';
import 'package:mp3_android_player/models/audio_file.dart';
import 'package:mp3_android_player/services/haptic_filter_service_interface.dart';
import 'package:mp3_android_player/services/haptic_audio_player_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mp3_android_player/sources/haptic_stream_audio_source.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

class MockHapticFilterService extends Mock implements HapticFilterService {}

class MockFileHelper extends Mock implements FileHelper {}

class MockAudioFile extends Mock implements AudioFile {}

class MockFFmpegSession extends Mock implements FFmpegSession {}

class MockFile extends Mock implements File {}

class MockAudioSource extends Mock implements AudioSource {}

Future<void> testParameterized(
  String description,
  Future<void> Function(dynamic) testCase,
  List<dynamic> parameters,
) async {
  for (final parameter in parameters) {
    test(description, () async => await testCase(parameter));
  }
}

void main() {
  group('HapticAudioPlayerService', () {
    late HapticAudioPlayerService service;
    late MockAudioPlayer mockPlayer;
    late MockHapticFilterService mockHapticFilter;
    late MockFileHelper mockFileHelper;
    late MockAudioFile mockAudioFile;
    late StreamController<Uint8List> controller;

    setUpAll(() {
      // Register fallback for potential complex types if necessary
      registerFallbackValue(MockFFmpegSession());
      registerFallbackValue(MockAudioFile());
      registerFallbackValue(MockAudioSource());
    });

    setUp(() {
      mockPlayer = MockAudioPlayer();
      mockHapticFilter = MockHapticFilterService();
      mockFileHelper = MockFileHelper();
      mockAudioFile = MockAudioFile();
      controller = StreamController<Uint8List>.broadcast();

      service = HapticAudioPlayerService(
        player: mockPlayer,
        hapticFilterService: mockHapticFilter,
        fileHelper: mockFileHelper,
      );
    });

    tearDown(() {
      controller.close();
    });

    group('play', () {
      testParameterized(
        'should successfully setup and play audio',
        (dynamic params) async {
          final Map<String, dynamic> mapParams = params as Map<String, dynamic>;
          final String inputPath = mapParams['path'];
          final String processedPath = 'processed_path.mp3';
          final String hapticPath = 'haptic_1234.mp3';

          when(() => mockAudioFile.path).thenReturn(inputPath);
          when(
            () => mockHapticFilter.applyHapticFilter(any(), any()),
          ).thenAnswer((_) async => processedPath);
          when(() => mockFileHelper.getFile(any())).thenReturn(MockFile());
          when(
            () => mockPlayer.setAudioSource(any()),
          ).thenAnswer((_) async => null);
          when(() => mockPlayer.play()).thenAnswer((_) async => {});
          when(
            () => mockHapticFilter.outputDataStreamController,
          ).thenReturn(controller);

          service.initialize(mockAudioFile);

          service.play(mockAudioFile);

          final Function(String) captured =
              verify(
                    () => mockHapticFilter.applyHapticFilter(
                      mockAudioFile,
                      captureAny(),
                    ),
                  ).captured.last
                  as Function(String);
          captured.call(hapticPath);

          verify(
            () => mockFileHelper.getFile(any(that: equals(hapticPath))),
          ).called(1);
          verify(
            () => mockPlayer.setAudioSource(
              any(that: isA<HapticStreamAudioSource>()),
            ),
          ).called(1);

          verify(() => mockPlayer.play()).called(1);
        },
        [
          {'path': 'song.mp3'},
          {'path': 'music/track.wav'},
        ],
      );

      test('should rethrow error when setup fails (branch coverage)', () async {
        // Arrange
        when(() => mockAudioFile.path).thenReturn('error.mp3');
        when(
          () => mockHapticFilter.applyHapticFilter(any(), any()),
        ).thenThrow(Exception('Filter Error'));

        expect(
          () => service.initialize(mockAudioFile),
          throwsA(isA<Exception>()),
        );
        verifyNever(() => mockPlayer.play());
      });
    });
  });
}
