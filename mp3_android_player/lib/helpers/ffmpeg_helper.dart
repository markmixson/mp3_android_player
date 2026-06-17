import 'dart:async';
import 'dart:typed_data';

import 'package:ffmpeg_kit_audio_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_audio_flutter/return_code.dart';
import 'package:mp3_android_player/helpers/ffmpeg_wrapper.dart';

class FFmpegHelper {
  final Completer<String> _completer = Completer();
  final StreamController<Uint8List> _dataStreamController =
      StreamController<Uint8List>.broadcast();
  final FFmpegWrapper _wrapper;

  FFmpegHelper({required FFmpegWrapper wrapper}) : _wrapper = wrapper;

  StreamController<Uint8List> get outputDataStreamController =>
      _dataStreamController;

  Future<String> getPipePath() async {
    final pipePath = await _wrapper.getPipe();
    if (pipePath == null) {
      throw StateError("can't generate pipe!");
    }
    return pipePath;
  }

  Future<String> executeAsync(
    final String outputPath,
    final String command,
  ) async {
    _startExecution(outputPath, command);
    return _completer.future;
  }

  Future<FFmpegSession> _startExecution(
    final String outputPath,
    final String command,
  ) {
    return _wrapper.executeAsync(command, (session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        _completer.complete(outputPath);
      } else {
        final failStackTrace = await session.getFailStackTrace();
        _completer.completeError(
          Exception('FFmpeg failed to apply low-pass filter: $failStackTrace'),
        );
      }
      await _dataStreamController.close();
    });
  }
}
