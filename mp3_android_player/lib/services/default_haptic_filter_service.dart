import 'dart:async';

import 'package:mp3_android_player/helpers/ffmpeg_helper.dart';
import 'package:mp3_android_player/models/audio_file.dart';
import 'package:mp3_android_player/services/haptic_filter_service_interface.dart';

class DefaultHapticFilterService implements HapticFilterService {
  final FFmpegHelper _ffmpegHelper;

  DefaultHapticFilterService({
    required FFmpegHelper ffmpegHelper,
  }) : _ffmpegHelper = ffmpegHelper;

  @override
  Future<String> applyHapticFilter(
    final AudioFile audioFile,
    final Function(String) sourceSetter,
  ) async {
    final path = audioFile.path;
    final outputPath = await _ffmpegHelper.getPipePath();
    final options = '-i $path -y -af "lowpass=f=250" -f adts -c:a aac $outputPath';
    // Apply a low-pass filter at 250Hz
    _ffmpegHelper.executeAsync(outputPath, options);
    return sourceSetter.call(outputPath);
  }

  @override
  StreamController<List<int>> get outputDataStreamController =>
      _ffmpegHelper.outputDataStreamController;
}
