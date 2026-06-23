import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:mp3_android_player/helpers/ffmpeg_helper.dart';
import 'package:mp3_android_player/wrappers/file_wrapper.dart';
import 'package:mp3_android_player/wrappers/temporary_directory_wrapper.dart';
import 'package:mp3_android_player/models/audio_file.dart';
import 'package:mp3_android_player/services/low_pass_filter_service_interface.dart';

import 'package:path/path.dart' as p;

class DefaultLowPassFilterService implements LowPassFilterService {
  final Clock _clock;
  final List<String> _tempFiles = [];
  final FFmpegHelper _ffmpegHelper;
  final TemporaryDirectoryWrapper _temporaryDirectoryWrapper;
  final FileWrapper _fileWrapper;

  DefaultLowPassFilterService({
    required Clock clock,
    required FFmpegHelper ffmpegHelper,
    required TemporaryDirectoryWrapper temporaryDirectoryWrapper,
    required FileWrapper fileWrapper 
  }) : _ffmpegHelper = ffmpegHelper,
       _temporaryDirectoryWrapper = temporaryDirectoryWrapper,
       _clock = clock,
       _fileWrapper = fileWrapper;

  @override
  Future<String> applyLowPassFilter(final AudioFile audioFile, final Function(String) sourceSetter) async {
    final tempDir = await _temporaryDirectoryWrapper.getTemporaryDirectory();
    final time = _clock.now().millisecondsSinceEpoch;
    final path = audioFile.path;
    // Use .pcm extension for raw PCM data
    final outputPath = p.join(tempDir.path, 'haptic_$time.wav');
    _tempFiles.add(outputPath);
    // -f wav -c:a pcm_s16le: 16-bit little-endian PCM wav
    // -ar 44100: 44.1kHz sample rate
    // -ac 1: Mono
    // -af lowpass=f=250: Low-pass filter at 250Hz to focus on bass/transients for haptics
    final options = '-i "$path" -y -f wav -c:a pcm_s16le -ar 44100 -ac 1 -af lowpass=f=250 "$outputPath"';
    // Apply a low-pass filter at 250Hz and downmix stereo to mono
    return _ffmpegHelper
        .executeAsync(_tempFiles, outputPath, options)
        .then((output) async => sourceSetter.call(output));
  }

  @override
  Future<void> clearTemporaryFiles() async {
    for (final path in _tempFiles) {
      try {
        final file = _fileWrapper.getFile(path);
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
