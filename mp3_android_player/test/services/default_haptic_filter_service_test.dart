import 'package:ffmpeg_kit_audio_flutter/ffmpeg_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mp3_android_player/helpers/ffmpeg_helper.dart';
import 'package:mp3_android_player/models/audio_file.dart';
import 'package:mp3_android_player/services/default_haptic_filter_service.dart';
import 'package:mocktail/mocktail.dart';

class MockFFmpegSession extends Mock implements FFmpegSession {}

class MockFFmpegHelper extends Mock implements FFmpegHelper {}

class MockAudioFile extends Mock implements AudioFile {}

void main() {
  group('DefaultHapticFilterService', () {
    late DefaultHapticFilterService service;
    late MockFFmpegHelper mockHelper;
    late MockAudioFile mockAudioFile;

    setUp(() {
      mockHelper = MockFFmpegHelper();
      mockAudioFile = MockAudioFile();

      service = DefaultHapticFilterService(ffmpegHelper: mockHelper);
    });

    group('applyHapticFilter', () {
      final testCases = [
        {'path': 'audio1.mp3', 'ext': '.mp3'},
        {'path': 'music/track.wav', 'ext': '.wav'},
        {'path': 'audio.ogg', 'ext': '.ogg'},
      ];

      for (var params in testCases) {
        final String inputPath = params['path'] as String;
        final String expectedExt = params['ext'] as String;

        test('should return correct path for $inputPath', () async {
          when(() => mockAudioFile.path).thenReturn(inputPath);
          when(
            () => mockHelper.getPipePath(),
          ).thenAnswer((_) async => "haptic_test.mp3");
          when(
            () => mockHelper.executeAsync(any(), any()),
          ).thenAnswer((_) async => 'haptic_123.mp3');

          final result = await service.applyHapticFilter(
            mockAudioFile, 0,
            (session) async => 'haptic_123$expectedExt',
          );

          expect(result, contains(expectedExt));
          expect(result, contains('haptic_'));
          verify(() => mockHelper.executeAsync(any(), any())).called(1);
        });
      }
    });
  });
}
