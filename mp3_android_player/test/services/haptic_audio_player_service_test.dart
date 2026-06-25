import 'dart:io';
import 'dart:isolate';

import 'package:ffmpeg_kit_audio_flutter/ffmpeg_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mp3_android_player/wrappers/file_wrapper.dart';
import 'package:mp3_android_player/models/audio_file.dart';
import 'package:mp3_android_player/services/haptic_service_interface.dart';
import 'package:mp3_android_player/services/low_pass_filter_service_interface.dart';
import 'package:mp3_android_player/services/haptic_audio_player_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mp3_android_player/sources/haptic_stream_audio_source.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

class MockLowPassFilterService extends Mock implements LowPassFilterService {}

class MockFileWrapper extends Mock implements FileWrapper {}

class MockAudioFile extends Mock implements AudioFile {}

class MockFFmpegSession extends Mock implements FFmpegSession {}

class MockFile extends Mock implements File {}

class MockAudioSource extends Mock implements AudioSource {}

class MockHapticService extends Mock implements HapticService {}

class MockHapticStreamAudioSourceBackground extends Mock {
  Future<SendPort> runInBackground(ReceivePort receivePort);
}

class MockHapticStreamAudioSource extends Mock implements HapticStreamAudioSource {}

class MockSendPort extends Mock implements SendPort {}

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
    late MockLowPassFilterService mockHapticFilter;
    late MockFileWrapper mockFileWrapper;
    late MockAudioFile mockAudioFile;
    late MockHapticService mockHapticService;
    late MockHapticStreamAudioSourceBackground mockBackground;
    late MockHapticStreamAudioSource mockHapticStreamAudioSource;

    setUpAll(() {
      // Register fallback for potential complex types if necessary
      registerFallbackValue(MockFFmpegSession());
      registerFallbackValue(MockAudioFile());
      registerFallbackValue(MockAudioSource());
      registerFallbackValue(List.empty());
      registerFallbackValue(Duration(milliseconds: 0));
      registerFallbackValue(ReceivePort());
    });

    setUp(() {
      mockPlayer = MockAudioPlayer();
      mockHapticFilter = MockLowPassFilterService();
      mockFileWrapper = MockFileWrapper();
      mockAudioFile = MockAudioFile();
      mockHapticService = MockHapticService();
      mockBackground = MockHapticStreamAudioSourceBackground();
      mockHapticStreamAudioSource = MockHapticStreamAudioSource();

      service = HapticAudioPlayerService(
        player: mockPlayer,
        lowPassFilterService: mockHapticFilter,
        fileWrapper: mockFileWrapper,
        hapticService: mockHapticService,
        processorFunction: mockBackground.runInBackground
      );
    });

    group('play', () {
      testParameterized(
        'should successfully setup and play haptic pattern',
        (dynamic params) async {
          final Map<String, dynamic> mapParams = params as Map<String, dynamic>;
          final String inputPath = mapParams['path'];
          final String processedPath = 'processed_path.mp3';
          final String hapticPath = 'haptic_1234.mp3';

          when(() => mockAudioFile.path).thenReturn(inputPath);
          when(
            () => mockHapticFilter.applyLowPassFilter(any(), any()),
          ).thenAnswer((_) async => processedPath);
          when(() => mockFileWrapper.getFile(any())).thenReturn(MockFile());
          when(
            () => mockPlayer.setAudioSource(any()),
          ).thenAnswer((_) async => null);
          when(() => mockPlayer.audioSource).thenReturn(mockHapticStreamAudioSource);
          when(() => mockPlayer.play()).thenAnswer((_) async => {});
          when(
            () => mockHapticService.playHapticPattern(any(), any()),
          ).thenAnswer((_) async => 12345);
          when(() => mockPlayer.stop()).thenAnswer((_) async => {});
          when(() => mockPlayer.pause()).thenAnswer((_) async => {});
          when(
            () => mockHapticService.stopHaptics(),
          ).thenAnswer((_) async => {});
          when(() => mockBackground.runInBackground(any())).thenAnswer((_) async => MockSendPort());

          await service.initialize(mockAudioFile);
          await service.play(mockAudioFile);
          service.pause();
          service.stop();

          final Function(String) captured =
              verify(
                    () => mockHapticFilter.applyLowPassFilter(
                      mockAudioFile,
                      captureAny(),
                    ),
                  ).captured.last
                  as Function(String);
          await captured.call(hapticPath);

          verify(
            () => mockFileWrapper.getFile(any(that: equals(hapticPath))),
          ).called(1);
          verify(
            () => mockPlayer.setAudioSource(
              any(that: isA<HapticStreamAudioSource>()),
            ),
          ).called(1);

          verify(() => mockPlayer.play()).called(1);
          verify(() => mockPlayer.stop()).called(1);
          verify(() => mockPlayer.pause()).called(1);
          verify(() => mockHapticService.stopHaptics()).called(2);
          verify(() => mockHapticStreamAudioSource.dispose()).called(1);
        },
        [
          {'path': 'song.mp3'},
          {'path': 'music/track.wav'},
        ],
      );

      test('should rethrow error when setup fails', () async {
        // Arrange
        when(() => mockAudioFile.path).thenReturn('error.mp3');
        when(
          () => mockHapticFilter.applyLowPassFilter(any(), any()),
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
