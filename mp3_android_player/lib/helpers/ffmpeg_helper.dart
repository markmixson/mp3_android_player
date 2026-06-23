import 'dart:async';

import 'package:ffmpeg_kit_audio_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_audio_flutter/return_code.dart';
import 'package:mp3_android_player/wrappers/ffmpeg_wrapper.dart';

class FFmpegHelper {
  final Completer<String> _completer = Completer();
  final FFmpegWrapper _wrapper;

  FFmpegHelper({required FFmpegWrapper wrapper}) : _wrapper = wrapper;

  Future<String> executeAsync(
    final List<String> tempFiles,
    final String outputPath,
    final String command,
  ) async {
    _startExecution(tempFiles, outputPath, command);
    return _completer.future;
  }

  Future<FFmpegSession> _startExecution(
    final List<String> tempFiles,
    final String outputPath,
    final String command,
  ) {
    return _wrapper.executeAsync(command, (session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        tempFiles.add(outputPath);
        _completer.complete(outputPath);
      } else {
        final failStackTrace = await session.getFailStackTrace();
        _completer.completeError(
          Exception('FFmpeg failed to apply low-pass filter: $failStackTrace'),
        );
      }
    });
  }
}
