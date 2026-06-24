// ignore_for_file: experimental_member_use

import 'dart:io';
import 'dart:isolate';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class HapticStreamAudioSource extends StreamAudioSource {
  final File _file;
  final String _contentType;
  final void Function(List<int> list, ReceivePort receivePort)
  _processorFunction;

  HapticStreamAudioSource(
    this._file,
    this._contentType,
    this._processorFunction,
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
    await _file
        .openRead(start, end)
        .doOnDone(() async => receivePort.sendPort.send('done'))
        .forEach((list) async => _processorFunction(list, receivePort));
    return StreamAudioResponse(
      sourceLength: length,
      contentLength: myEnd - myStart,
      offset: myStart,
      stream: audioSubject.stream,
      contentType: _contentType,
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
