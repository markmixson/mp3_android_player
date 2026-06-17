import 'dart:async';
import 'dart:typed_data';

import 'package:ffmpeg_kit_audio_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_audio_flutter/log.dart';
import 'package:ffmpeg_kit_audio_flutter/return_code.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mp3_android_player/helpers/ffmpeg_helper.dart';
import 'package:mp3_android_player/helpers/ffmpeg_wrapper.dart';

// Mock the wrapper to bypass actual FFmpeg calls
class MockFFmpegWrapper extends Mock implements FFmpegWrapper {}

// Mock the session to control return codes and stack traces
class MockFFmpegSession extends Mock implements FFmpegSession {}

void main() {
  late FFmpegHelper ffmpegHelper;
  late MockFFmpegWrapper mockWrapper;
  late MockFFmpegSession mockSession;

  setUp(() {
    mockWrapper = MockFFmpegWrapper();
    ffmpegHelper = FFmpegHelper(
      wrapper: mockWrapper,
      completer: Completer(),
      controller: StreamController<Uint8List>.broadcast(),
    );
    mockSession = MockFFmpegSession();
  });

  tearDown(() {
    ffmpegHelper.outputDataStreamController.close();
  });

  group('FFmpegHelper.outputDataStreamController', () {
    test('get controller', () async {
      final controller = ffmpegHelper.outputDataStreamController;
      expect(controller, isA<StreamController<Uint8List>>());
    });
  });

  group('FFmpegHelper.getPipePath', () {
    const String fileName = "test.mp3";
    test('get file', () async {
      when(() => mockWrapper.getPipe()).thenAnswer((_) async => fileName);
      final result = await ffmpegHelper.getPipePath();
      expect(result, fileName);
    });
    test('get null file', () async {
      when(() => mockWrapper.getPipe()).thenAnswer((_) async => null);
      expect(ffmpegHelper.getPipePath(), throwsA(isA<StateError>()));
    });
  });

  group('FFmpegHelper.executeAsync', () {
    const outputPath = 'output.mp3';
    const command = '-i input.mp3 output.mp3';

    test('check for success', () async {
      // Arrange
      when(() => mockWrapper.executeAsync(any(), any())).thenAnswer((
        invocation,
      ) async {
        // Extract the callback passed to executeAsync
        final callback =
            invocation.positionalArguments[1] as Function(FFmpegSession);
        // Simulate the callback being executed with a successful session
        await callback(mockSession);
        return mockSession;
      });
      when(
        () => mockSession.getReturnCode(),
      ).thenAnswer((_) async => ReturnCode(0));

      await ffmpegHelper.executeAsync(outputPath, command);

      verify(() => mockSession.getReturnCode()).called(1);
    });

    test('should throw exception when FFmpeg fails', () async {
      // Arrange
      when(() => mockWrapper.executeAsync(any(), any())).thenAnswer((
        invocation,
      ) async {
        final callback =
            invocation.positionalArguments[1] as Function(FFmpegSession);
        await callback(mockSession);
        return mockSession;
      });
      when(
        () => mockSession.getReturnCode(),
      ).thenAnswer((_) async => ReturnCode(255));
      when(
        () => mockSession.getFailStackTrace(),
      ).thenAnswer((_) async => 'Error details');

      expect(
        ffmpegHelper.executeAsync(outputPath, command),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('FFmpeg failed to apply low-pass filter: Error details'),
          ),
        ),
      );
    });
  });
}
