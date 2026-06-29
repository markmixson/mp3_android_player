// ignore_for_file: experimental_member_use

import 'dart:io';
import 'dart:typed_data';
import 'package:just_audio/just_audio.dart';
import 'package:mp3_android_player/pipes/haptic_audio_pipe.dart';

class HapticStreamAudioSource extends StreamAudioSource {
  final File _file;
  final String _contentType;
  late HapticAudioPipe hapticPipe = HapticAudioPipe();

  HapticStreamAudioSource(this._file, this._contentType);

  @override
  Future<StreamAudioResponse> request([
    final int? start,
    final int? end,
  ]) async {
    final length = await _file.length();
    hapticPipe = HapticAudioPipe();
    hapticPipe.init();
    return StreamAudioResponse(
      sourceLength: length,
      contentLength: (end ?? length) - (start ?? 0),
      offset: start ?? 0,
      stream: _file.openRead(start, end).map((pcmData) {
        hapticPipe.writeBytes(Uint8List.fromList(pcmData));
        return pcmData;
      }),
      contentType: _contentType,
    );
  }
}
