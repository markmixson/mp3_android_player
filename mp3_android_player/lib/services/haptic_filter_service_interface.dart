import 'dart:async';
import 'dart:typed_data';

import 'package:mp3_android_player/models/audio_file.dart';

// coverage:ignore-file
abstract class HapticFilterService {
  /// Processes the given [audioFile] with a low-pass filter and returns the path to the temporary processed file.
  /// Throws an exception if processing fails.
  Future<String> applyHapticFilter(
    AudioFile audioFile,
    Function(String) sourceSetter,
  ) async => throw UnimplementedError();
  StreamController<Uint8List> get outputDataStreamController =>
      throw UnimplementedError();
}
