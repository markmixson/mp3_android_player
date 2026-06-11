import 'package:ffmpeg_kit_audio_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_audio_flutter/return_code.dart';
import 'package:mp3_android_player/helpers/ffmpeg_wrapper.dart';

class FFmpegHelper {
  final FFmpegWrapper _wrapper;

  FFmpegHelper({required FFmpegWrapper wrapper}) : _wrapper = wrapper;

  Future<FFmpegSession> executeAsync(
    final List<String> tempFiles,
    final String outputPath,
    final String command,
  ) async {
    return _wrapper.executeAsync(command, (session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        tempFiles.add(outputPath);
      } else {
        final failStackTrace = await session.getFailStackTrace();
        throw Exception(
          'FFmpeg failed to apply low-pass filter: $failStackTrace',
        );
      }
    });
  }
}
