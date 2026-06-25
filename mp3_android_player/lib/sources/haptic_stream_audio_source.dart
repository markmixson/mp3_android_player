// ignore_for_file: experimental_member_use

import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:just_audio/just_audio.dart';
import 'package:mp3_android_player/models/haptic_mode.dart';
import 'package:rxdart/rxdart.dart';

class HapticStreamAudioSource extends StreamAudioSource {
  late File _file;
  late String _contentType;
  late ReceivePort _receivePort;
  late SendPort _sendPort;

  HapticStreamAudioSource._();

  static Future<HapticStreamAudioSource> create(
    final File file,
    final String contentType,
    final Future<SendPort> Function(ReceivePort, RootIsolateToken?)
    processorFunction,
    final HapticMode initialHapticMode,
    final RootIsolateToken? rootToken,
  ) async {
    final source = HapticStreamAudioSource._();
    source._file = file;
    source._contentType = contentType;
    source._receivePort = ReceivePort();
    source._sendPort = await processorFunction(source._receivePort, rootToken);
    source.setHapticMode(initialHapticMode);
    return source;
  }

  @override
  Future<StreamAudioResponse> request([
    final int? start,
    final int? end,
  ]) async {
    final myStart = start ?? 0;
    final length = await _file.length();
    final myEnd = end ?? length;
    final audioSubject = PublishSubject<List<int>>();
    return StreamAudioResponse(
      sourceLength: length,
      contentLength: myEnd - myStart,
      offset: myStart,
      stream: audioSubject.stream.doOnListen(
        () async => _startRead(start, end, audioSubject),
      ),
      contentType: _contentType,
    );
  }

  void setHapticMode(final HapticMode hapticMode) {
    _sendPort.send(hapticMode);
  }

  void _startRead(
    final int? start,
    final int? end,
    final PublishSubject<List<int>> audioSubject,
  ) async {
    await _file
        .openRead(start, end)
        .doOnDone(() async {
          audioSubject.close();
        })
        .forEach((list) async {
          _sendPort.send(list);
          audioSubject.add(list);
        });
  }

  void dispose() {
    _sendPort.send('done');
    _receivePort.close();
  }
}
