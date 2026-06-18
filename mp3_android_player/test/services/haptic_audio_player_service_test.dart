import 'dart:io';

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
    late MockFile mockFile;

    setUpAll(() {
      // Register fallback for potential complex types if necessary
      registerFallbackValue(MockFFmpegSession());
      registerFallbackValue(MockAudioFile());
      registerFallbackValue(MockAudioSource());
      registerFallbackValue(Duration(seconds: 0));
    });

    setUp(() {
      mockPlayer = MockAudioPlayer();
      mockHapticFilter = MockHapticFilterService();
      mockFileHelper = MockFileHelper();
      mockAudioFile = MockAudioFile();
      mockFile = MockFile();

      service = HapticAudioPlayerService(
        player: mockPlayer,
        hapticFilterService: mockHapticFilter,
        fileHelper: mockFileHelper,
      );
    });

    group('getPositionStream', () {
      test('get', () async {
        final duration = Duration(minutes: 5);
        final position = 5000;
        final positionDuration = Duration(milliseconds: position);
        when(
          () => mockPlayer.createPositionStream(
            steps: duration.inSeconds - positionDuration.inSeconds,
            minPeriod: Duration(milliseconds: position),
            maxPeriod: duration,
          ),
        ).thenAnswer((_) => Stream<Duration>.empty());
        service.getPositionStream(
          AudioFile(path: '', name: '', duration: duration),
          position,
        );
        verify(
          () => mockPlayer.createPositionStream(
            steps: any(named: 'steps'),
            minPeriod: any(named: 'minPeriod'),
            maxPeriod: any(named: 'maxPeriod'),
          ),
        ).called(1);
      });
    });

    group('getDurationStream', () {
      test('get', () async {
        final duration = Duration(minutes: 5);
        when(
          () => mockPlayer.createPositionStream(
            steps: 1,
            minPeriod: duration,
            maxPeriod: duration,
          ),
        ).thenAnswer((_) => Stream<Duration>.empty());
        service.getDurationStream(
          AudioFile(path: '', name: '', duration: duration),
        );
        verify(
          () => mockPlayer.createPositionStream(
            steps: any(named: 'steps'),
            minPeriod: any(named: 'minPeriod'),
            maxPeriod: any(named: 'maxPeriod'),
          ),
        ).called(1);
      });
    });

    group('seek', () {
      test('does nothing', () async {
        await service.seek(Duration(days: 1));
      });
    });

    group('play', () {
      testParameterized(
        'should successfully setup and play audio',
        (dynamic params) async {
          final Map<String, dynamic> mapParams = params as Map<String, dynamic>;
          final String inputPath = mapParams['path'];
          final bool useResume = mapParams['useResume'];
          final String processedPath = 'processed_path.mp3';
          final String hapticPath = 'haptic_1234.mp3';

          when(() => mockAudioFile.path).thenReturn(inputPath);
          when(
            () => mockHapticFilter.applyHapticFilter(any(), any(), any()),
          ).thenAnswer((_) async => processedPath);
          when(() => mockFileHelper.getFile(any())).thenReturn(mockFile);
          when(
            () => mockPlayer.setAudioSource(any()),
          ).thenAnswer((_) async => null);
          when(() => mockPlayer.play()).thenAnswer((_) async => {});

          await service.initialize(mockAudioFile);
          if (useResume) {
            await service.resume(mockAudioFile);
          } else {
            await service.play(mockAudioFile);
          }

          final Function(String) captured =
              verify(
                    () => mockHapticFilter.applyHapticFilter(
                      mockAudioFile,
                      0,
                      captureAny(),
                    ),
                  ).captured.last
                  as Function(String);
          await captured.call(hapticPath);

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
          {'path': 'song.mp3', 'useResume': false},
          {'path': 'music/track.wav', 'useResume': true},
        ],
      );
    });
  });
}
