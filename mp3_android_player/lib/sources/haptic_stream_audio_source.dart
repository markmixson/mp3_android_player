// ignore_for_file: experimental_member_use

import 'dart:async';
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
    return StreamAudioResponse(
      sourceLength: null,
      contentLength: null,
      offset: 0,
      stream: _file.openRead(),
      contentType: _contentType,
    );
  }
}
