import 'dart:io';
import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:mp3_android_player/helpers/ffmpeg_helper.dart';
import 'package:mp3_android_player/models/audio_file.dart';
import 'package:mp3_android_player/services/haptic_filter_service_interface.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class DefaultHapticFilterService implements HapticFilterService {
  final Clock _clock;
  final List<String> _tempFiles = [];
  final FFmpegHelper _helper;

  DefaultHapticFilterService({
    required Clock clock,
    required FFmpegHelper helper,
  }) : _helper = helper,
       _clock = clock;

  @override
  Future<String> applyHapticFilter(final AudioFile audioFile) async {
    final tempDir = await getTemporaryDirectory();
    final time = _clock.now().millisecondsSinceEpoch;
    final ext = p.extension(audioFile.path);
    final outputPath = p.join(tempDir.path, 'haptic_$time.$ext');

    _tempFiles.add(outputPath);

    // Apply a low-pass filter at 500Hz
    return _helper
        .executeAsync(_tempFiles, outputPath, '''
        -i "${audioFile.path}"
        -af lowpass=f=500 
        -y "$outputPath"
        ''')
        .then((session) => outputPath);
  }

  @override
  Future<void> clearTemporaryFiles() async {
    for (final path in _tempFiles) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Error deleting temporary file $path: $e');
      }
    }
    _tempFiles.clear();
  }
}
