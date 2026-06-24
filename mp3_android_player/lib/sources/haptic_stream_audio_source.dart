// ignore_for_file: experimental_member_use

import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:just_audio/just_audio.dart';
import 'package:mp3_android_player/models/haptic_mode.dart';
import 'package:rxdart/rxdart.dart';

class HapticStreamAudioSource extends StreamAudioSource {
  final File _file;
  final String _contentType;
  final void Function(
    List<int> list,
    ReceivePort receivePort,
    RootIsolateToken? rootToken,
  )
  _processorFunction;
  HapticMode hapticMode;
  final RootIsolateToken? _rootToken;

  HapticStreamAudioSource(
    this._file,
    this._contentType,
    this._processorFunction,
    this.hapticMode,
    this._rootToken,
  );

  @override
  Future<StreamAudioResponse> request([
    final int? start,
    final int? end,
  ]) async {
    final myStart = start ?? 0;
    final length = await _file.length();
    final myEnd = end ?? length;
    final audioSubject = PublishSubject<List<int>>();
    final receivePort = getReceivePort(audioSubject);
    return StreamAudioResponse(
      sourceLength: length,
      contentLength: myEnd - myStart,
      offset: myStart,
      stream: audioSubject.stream.doOnListen(
        () async => startRead(start, end, receivePort),
      ),
      contentType: _contentType,
    );
  }

  void startRead(
    final int? start,
    final int? end,
    final ReceivePort receivePort,
  ) async {
    await _file
        .openRead(start, end)
        .doOnDone(() async => receivePort.sendPort.send('done'))
        .forEach(
          (list) async => hapticMode == HapticMode.enabled
              ? _processorFunction(list, receivePort, _rootToken)
              : receivePort.sendPort.send(list),
        );
  }

  ReceivePort getReceivePort(final PublishSubject<List<int>> audioSubject) {
    final receivePort = ReceivePort();
    receivePort.listen((message) {
      if (message is List<int>) {
        audioSubject.add(message);
      } else {
        audioSubject.close();
        receivePort.close();
      }
    });
    return receivePort;
  }
}
