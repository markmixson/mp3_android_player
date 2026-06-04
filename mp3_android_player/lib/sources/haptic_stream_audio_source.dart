// ignore_for_file: experimental_member_use

import 'dart:io';
import 'package:just_audio/just_audio.dart';

class HapticStreamAudioSource extends StreamAudioSource {
  final File _file;
  final String _contentType;

  HapticStreamAudioSource(this._file, this._contentType);

  @override
  Future<StreamAudioResponse> request([
    final int? start,
    final int? end,
  ]) async {
    final length = await _file.length();
    return StreamAudioResponse(
      sourceLength: length,
      contentLength: (end ?? length) - (start ?? 0),
      offset: start ?? 0,
      stream: _file.openRead(),
      contentType: _contentType,
    );
  }
}
