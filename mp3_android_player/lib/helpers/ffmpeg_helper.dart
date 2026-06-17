import 'dart:async';
import 'dart:typed_data';

import 'package:ffmpeg_kit_audio_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_audio_flutter/return_code.dart';
import 'package:mp3_android_player/helpers/ffmpeg_wrapper.dart';

class FFmpegHelper {
  final FFmpegWrapper _wrapper;
  final StreamController<Uint8List> _dataStreamController;
  final Completer<String> _completer;

  FFmpegHelper({
    required FFmpegWrapper wrapper,
    required StreamController<Uint8List> controller,
    required Completer<String> completer,
  }) : _wrapper = wrapper,
       _dataStreamController = controller,
       _completer = completer;

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
        final logs = await session.getAllLogs();
        final joined = logs.map((e) => e.getMessage()).join(',');
        _completer.completeError(
          Exception(
            'FFmpeg failed to apply low-pass filter: $failStackTrace logs: $joined',
          ),
        );
      }
      await _dataStreamController.close();
    });
  }
}
