// ignore_for_file: experimental_member_use

import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mp3_android_player/models/haptic_mode.dart';
import 'package:rxdart/rxdart.dart';

class HapticStreamAudioSource extends StreamAudioSource {
  late File _file;
  late String _contentType;
  late ReceivePort _receivePort;
  late SendPort _sendPort;
  late Future<SendPort> Function(ReceivePort) _processorFunction;
  late RootIsolateToken? _rootToken;
  late HapticMode _hapticMode;

  HapticStreamAudioSource._();

  static Future<HapticStreamAudioSource> create(
    final File file,
    final String contentType,
    final Future<SendPort> Function(ReceivePort) processorFunction,
    final HapticMode initialHapticMode,
    final RootIsolateToken? rootToken,
  ) async {
    final source = HapticStreamAudioSource._();
    source._file = file;
    source._contentType = contentType;
    source._processorFunction = processorFunction;
    source._rootToken = rootToken;
    source._hapticMode = initialHapticMode;
    await source.go();
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

  Future<void> setHapticMode(final HapticMode hapticMode) async {
    _hapticMode = hapticMode;
    stop();
    await go();
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

  void stop() {
    _sendPort.send('done');
    _receivePort.close();
  }

  Future<void> go() async {
    debugPrint("calling go on haptic stream audio source");
    _receivePort = ReceivePort();
    _sendPort = await _processorFunction(_receivePort);
    _sendPort.send(_hapticMode);
    _sendPort.send(_rootToken);
  }
}
