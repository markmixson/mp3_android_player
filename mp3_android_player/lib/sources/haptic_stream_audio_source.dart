// ignore_for_file: experimental_member_use

import 'dart:io';
import 'dart:isolate';
import 'package:just_audio/just_audio.dart';
import 'package:mp3_android_player/services/haptic_service_interface.dart';

class HapticStreamAudioSource extends StreamAudioSource {
  final File _file;
  final String _contentType;
  final HapticService _hapticService;
  final Duration _sampleWindowDuration;

  HapticStreamAudioSource(
    this._file,
    this._contentType,
    this._hapticService,
    this._sampleWindowDuration,
  );

  @override
  Future<StreamAudioResponse> request([
    final int? start,
    final int? end,
  ]) async {
    final myStart = start ?? 0;
    final length = await _file.length();
    final myEnd = end ?? length;
    final List<Future<dynamic>> futures = [];
    return StreamAudioResponse(
      sourceLength: length,
      contentLength: myEnd - myStart,
      offset: myStart,
      stream: _file.openRead(start, end).asyncMap((list) async {
        futures.add(Isolate.run(() async => _hapticService.playHapticPattern(list, _sampleWindowDuration)));
        return list;
      }),
      contentType: _contentType,
    );
  }
}
