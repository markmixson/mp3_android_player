import 'dart:async';

import 'package:mp3_android_player/helpers/ffmpeg_helper.dart';
import 'package:mp3_android_player/models/audio_file.dart';
import 'package:mp3_android_player/services/haptic_filter_service_interface.dart';

class DefaultHapticFilterService implements HapticFilterService {
  final FFmpegHelper _ffmpegHelper;

  DefaultHapticFilterService({required FFmpegHelper ffmpegHelper})
    : _ffmpegHelper = ffmpegHelper;

  @override
  Future<String> applyHapticFilter(
    final AudioFile audioFile, final int position,
    final Function(String) sourceSetter,
  ) async {
    final path = audioFile.path;
    final outputPath = await _ffmpegHelper.getPipePath();
    final timestamp = _formatMilliseconds(position);
    final options =
        '-ss $timestamp -i $path -y -af "lowpass=f=250" -f mp3 -c:a libmp3lame $outputPath';
    // Apply a low-pass filter at 250Hz
    _ffmpegHelper.executeAsync(outputPath, options);
    return sourceSetter.call(outputPath);
  }

  String _formatMilliseconds(int totalMilliseconds) {
    final duration = Duration(milliseconds: totalMilliseconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final milliseconds = duration.inMilliseconds
        .remainder(1000)
        .toString()
        .padLeft(3, '0');

    return '$hours:$minutes:$seconds.$milliseconds';
  }
}
