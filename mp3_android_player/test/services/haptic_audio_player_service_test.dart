import 'dart:io';

import 'package:ffmpeg_kit_audio_flutter/ffmpeg_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mp3_android_player/helpers/file_helper.dart';
import 'package:mp3_android_player/helpers/mime_helper.dart';
import 'package:mp3_android_player/models/audio_file.dart';
import 'package:mp3_android_player/services/haptic_filter_service_interface.dart';
import 'package:mp3_android_player/services/haptic_audio_player_service.dart';
import 'package:mocktail/mocktail.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

class MockHapticFilterService extends Mock implements HapticFilterService {}

class MockMimeHelper extends Mock implements MimeHelper {}

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
    late MockMimeHelper mockMime;
    late MockFileHelper mockFileHelper;
    late MockAudioFile mockAudioFile;

    setUpAll(() {
      // Register fallback for potential complex types if necessary
      registerFallbackValue(MockFFmpegSession());
      registerFallbackValue(MockAudioFile());
      registerFallbackValue(MockAudioSource());
    });

    setUp(() {
      mockPlayer = MockAudioPlayer();
      mockHapticFilter = MockHapticFilterService();
      mockMime = MockMimeHelper();
      mockFileHelper = MockFileHelper();
      mockAudioFile = MockAudioFile();

      service = HapticAudioPlayerService(
        player: mockPlayer,
        hapticFilterService: mockHapticFilter,
        mimeHelper: mockMime,
        fileHelper: mockFileHelper,
      );
    });

    group('play', () {
      testParameterized(
        'should successfully setup and play audio',
        (dynamic params) async {
          final Map<String, dynamic> mapParams = params as Map<String, dynamic>;
          final String inputPath = mapParams['path'];
          final String processedPath = 'processed_path.mp3';

          when(() => mockAudioFile.path).thenReturn(inputPath);
          when(
            () => mockHapticFilter.applyHapticFilter(any()),
          ).thenAnswer((_) async => processedPath);
          when(() => mockFileHelper.getFile(any())).thenReturn(MockFile());
          when(
            () => mockMime.getMimeType(any(), any()),
          ).thenReturn('audio/mpeg');
          when(
            () => mockPlayer.setAudioSource(any()),
          ).thenAnswer((_) async => null);
          when(() => mockPlayer.play()).thenAnswer((_) async => {});

          await service.play(mockAudioFile);

          verify(
            () => mockHapticFilter.applyHapticFilter(mockAudioFile),
          ).called(1);
          verify(() => mockPlayer.setAudioSource(any())).called(1);
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
          () => mockHapticFilter.applyHapticFilter(any()),
        ).thenThrow(Exception('Filter Error'));

        expect(() => service.play(mockAudioFile), throwsA(isA<Exception>()));
        verifyNever(() => mockPlayer.play());
      });
    });
  });
}
