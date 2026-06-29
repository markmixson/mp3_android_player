import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:mp3_android_player/helpers/ffmpeg_helper.dart';
import 'package:mp3_android_player/helpers/file_helper.dart';
import 'package:mp3_android_player/helpers/temporary_directory_helper.dart';
import 'package:mp3_android_player/models/audio_file.dart';
import 'package:mp3_android_player/services/haptic_filter_service_interface.dart';

import 'package:path/path.dart' as p;

class DefaultHapticFilterService implements HapticFilterService {
  final Clock _clock;
  final List<String> _tempFiles = [];
  final FFmpegHelper _ffmpegHelper;
  final TemporaryDirectoryHelper _temporaryDirectoryHelper;
  final FileHelper _fileHelper;

  DefaultHapticFilterService({
    required Clock clock,
    required FFmpegHelper ffmpegHelper,
    required TemporaryDirectoryHelper temporaryDirectoryHelper,
    required FileHelper fileHelper 
  }) : _ffmpegHelper = ffmpegHelper,
       _temporaryDirectoryHelper = temporaryDirectoryHelper,
       _clock = clock,
       _fileHelper = fileHelper;

  @override
  Future<String> applyHapticFilter(final AudioFile audioFile, final Function(String) sourceSetter) async {
    final tempDir = await _temporaryDirectoryHelper.getTemporaryDirectory();
    final time = _clock.now().millisecondsSinceEpoch;
    final path = audioFile.path;
    final outputPath = p.join(tempDir.path, 'haptic_$time.wav');
    _tempFiles.add(outputPath);
    final options = "-i $path -y -f wav -ar 44100 -ac 2 -af lowpass=f=250 $outputPath";
    // Apply a low-pass filter at 250Hz
    return _ffmpegHelper
        .executeAsync(_tempFiles, outputPath, options)
        .then((output) async => sourceSetter.call(output));
  }

  @override
  Future<void> clearTemporaryFiles() async {
    for (final path in _tempFiles) {
      try {
        final file = _fileHelper.getFile(path);
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
