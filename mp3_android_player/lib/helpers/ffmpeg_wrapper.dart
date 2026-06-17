import 'package:ffmpeg_kit_audio_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_audio_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_audio_flutter/ffmpeg_session.dart';
import 'package:flutter/foundation.dart';

// coverage:ignore-file
class FFmpegWrapper {
  Future<String?> getPipe() {
    return FFmpegKitConfig.registerNewFFmpegPipe();
  }

  Future<FFmpegSession> executeAsync(
    final String command,
    final Function(FFmpegSession)? callback,
  ) async {
    return FFmpegKit.executeAsync(command, callback, (log) {
      debugPrint(log.getMessage());
    });
  }
}
