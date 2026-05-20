import 'package:mp3_android_player/models/audio_file.dart';

// coverage:ignore-file
abstract class AudioFilePickerService {
  Future<AudioFile?> pickFile() async => throw UnimplementedError();
}
