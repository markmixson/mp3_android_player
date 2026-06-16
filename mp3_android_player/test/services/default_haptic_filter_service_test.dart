import 'dart:io';
import 'package:clock/clock.dart';
import 'package:ffmpeg_kit_audio_flutter/ffmpeg_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mp3_android_player/helpers/ffmpeg_helper.dart';
import 'package:mp3_android_player/helpers/file_helper.dart';
import 'package:mp3_android_player/helpers/temporary_directory_helper.dart';
import 'package:mp3_android_player/models/audio_file.dart';
import 'package:mp3_android_player/services/default_haptic_filter_service.dart';
import 'package:mocktail/mocktail.dart';

class MockFFmpegSession extends Mock implements FFmpegSession {}

class MockFFmpegHelper extends Mock implements FFmpegHelper {}

class MockAudioFile extends Mock implements AudioFile {}

class MockTemporaryDirectoryHelper extends Mock
    implements TemporaryDirectoryHelper {}

class MockFileHelper extends Mock implements FileHelper {}

class MockClock extends Mock implements Clock {}

class MockFile extends Mock implements File {}

class MockFileSystemEntity extends Mock implements FileSystemEntity {}

void main() {
  group('DefaultHapticFilterService', () {
    late DefaultHapticFilterService service;
    late MockFFmpegHelper mockHelper;
    late MockAudioFile mockAudioFile;
    late MockTemporaryDirectoryHelper mockTempDirHelper;
    late MockFileHelper mockFileHelper;
    late MockClock mockClock;
    late MockFileSystemEntity mockFileSystemEntity;

    setUp(() {
      mockHelper = MockFFmpegHelper();
      mockAudioFile = MockAudioFile();
      mockTempDirHelper = MockTemporaryDirectoryHelper();
      mockFileHelper = MockFileHelper();
      mockClock = MockClock();
      mockFileSystemEntity = MockFileSystemEntity();

      service = DefaultHapticFilterService(
        clock: mockClock,
        ffmpegHelper: mockHelper,
        temporaryDirectoryHelper: mockTempDirHelper,
        fileHelper: mockFileHelper,
      );
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
            () => mockTempDirHelper.getTemporaryDirectory(),
          ).thenAnswer((_) async => Directory('/tmp'));
          when(
            () => mockHelper.executeAsync(any(), any(), any()),
          ).thenAnswer((_) async => 'haptic_123.mp3');
          when(() => mockClock.now()).thenReturn(DateTime(2026, 6, 11));

          final result = await service.applyHapticFilter(mockAudioFile, (session) async => 'haptic_123$expectedExt');

          expect(result, contains(expectedExt));
          expect(result, contains('haptic_'));
          verify(() => mockHelper.executeAsync(any(), any(), any())).called(1);
        });
      }
    });

    group('clearTemporaryFiles', () {
      test(
        'should delete all files in the temp list when they exist',
        () async {
          final hapticFile = 'haptic_123.mp3';
          final mockFile = MockFile();
          when(() => mockAudioFile.path).thenReturn('test.mp3');
          when(
            () => mockTempDirHelper.getTemporaryDirectory(),
          ).thenAnswer((_) async => Directory('/tmp'));
          when(
            () => mockHelper.executeAsync(any(), any(), any()),
          ).thenAnswer((_) async => 'haptic_123.mp3');
          when(() => mockClock.now()).thenReturn(DateTime(2026, 6, 11));

          final result = await service.applyHapticFilter(mockAudioFile, (session) async => hapticFile);
          expect(result, equals(hapticFile));

          when(() => mockFileHelper.getFile(any())).thenReturn(mockFile);
          when(() => mockFile.exists()).thenAnswer((_) async => true);
          when(() => mockFile.delete()).thenAnswer((_) async => mockFileSystemEntity);

          await service.clearTemporaryFiles();
          verify(() => mockFileHelper.getFile(any())).called(1);
          verify(() => mockFile.delete()).called(1);
        },
      );

      test(
        'should handle file deletion errors gracefully (branch coverage)',
        () async {
          final mockFile = MockFile();
          when(() => mockAudioFile.path).thenReturn('test.mp3');
          when(
            () => mockTempDirHelper.getTemporaryDirectory(),
          ).thenAnswer((_) async => Directory('/tmp'));
          when(
            () => mockHelper.executeAsync(any(), any(), any()),
          ).thenAnswer((_) async => 'haptic_123.mp3');
          when(() => mockClock.now()).thenReturn(DateTime(2026, 6, 11));

          await service.applyHapticFilter(mockAudioFile, (session) async => 'haptic_123.mp3');

          when(() => mockFileHelper.getFile(any())).thenReturn(mockFile);
          when(() => mockFile.exists()).thenAnswer((_) async => true);
          when(() => mockFile.delete()).thenThrow(Exception('Disk error'));

          await expectLater(service.clearTemporaryFiles(), completes);
        },
      );

      test(
        'should not attempt to delete if file does not exist (branch coverage)',
        () async {
          final mockFile = MockFile();
          when(() => mockAudioFile.path).thenReturn('test.mp3');
          when(
            () => mockTempDirHelper.getTemporaryDirectory(),
          ).thenAnswer((_) async => Directory('/tmp'));
          when(
            () => mockHelper.executeAsync(any(), any(), any()),
          ).thenAnswer((_) async => 'haptic_123.mp3');
          when(() => mockClock.now()).thenReturn(DateTime(2026, 6, 11));

          await service.applyHapticFilter(mockAudioFile, (session) async => 'haptic_123.mp3');

          when(() => mockFileHelper.getFile(any())).thenReturn(mockFile);
          when(() => mockFile.exists()).thenAnswer((_) async => false);

          await service.clearTemporaryFiles();

          verifyNever(() => mockFile.delete());
        },
      );
    });
  });
}
