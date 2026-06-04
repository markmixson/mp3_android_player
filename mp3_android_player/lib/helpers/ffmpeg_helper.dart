import 'package:ffmpeg_kit_audio_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_audio_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_audio_flutter/return_code.dart';

class FFmpegHelper {
  Future<FFmpegSession> executeAsync(
    final List<String> tempFiles,
    final String outputPath,
    final String command,
  ) async {
    return FFmpegKit.executeAsync(command, (session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        tempFiles.add(outputPath);
      } else {
        final failStackTrace = session.getFailStackTrace();
        throw Exception(
          'FFmpeg failed to apply low-pass filter: $failStackTrace',
        );
      }
    });
  }
}
