import 'dart:isolate';

import 'package:ffmpeg_kit_audio_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_audio_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_audio_flutter/ffmpeg_session.dart';

// coverage:ignore-file
class FFmpegWrapper {
  Future<String?> getPipe() {
    return FFmpegKitConfig.registerNewFFmpegPipe();
  }

  Future<FFmpegSession> executeAsync(
    final String command,
    final Function(FFmpegSession)? callback
  ) async {    
    return Isolate.run(() => FFmpegKit.executeAsync(command, callback));
  }
}