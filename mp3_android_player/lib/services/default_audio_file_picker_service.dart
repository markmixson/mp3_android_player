import 'package:flutter/foundation.dart';
// ignore: implementation_imports
import 'package:file_picker/src/platform/file_picker_platform_interface.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mp3_android_player/models/audio_file.dart';
import 'package:mp3_android_player/services/audio_file_picker_service_interface.dart';

class DefaultAudioFilePickerService implements AudioFilePickerService {
  final FilePickerPlatform _filePicker;

  DefaultAudioFilePickerService({required FilePickerPlatform filePicker})
    : _filePicker = filePicker;

  @override
  Future<AudioFile?> pickFile() async {
    try {
      final result = await _filePicker.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        return AudioFile(
          path: file.path!,
          name: file.name,
          duration: Duration.zero,
        );
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
    return null;
  }
}
