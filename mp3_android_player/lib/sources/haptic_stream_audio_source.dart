// ignore_for_file: experimental_member_use

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class HapticStreamAudioSource extends StreamAudioSource {
  final File _file;
  final String _contentType;
  final StreamController<Uint8List> _controller;

  HapticStreamAudioSource(this._file, this._contentType, this._controller);

  @override
  Future<StreamAudioResponse> request([
    final int? start,
    final int? end,
  ]) async {
    final myStart = start ?? 0;
    final length = await _file.length();
    final myEnd = end ?? length;
    _setupPipe(myStart, myEnd);
    return StreamAudioResponse(
      sourceLength: length,
      contentLength: myEnd - myStart,
      offset: myStart,
      stream: _controller.stream,
      contentType: _contentType,
    );
  }

  void _setupPipe(final int start, final int end) {
    _file
        .openRead(start, end)
        .listen(
          (List<int> chunk) {
            _controller.add(Uint8List.fromList(chunk));
          },
          onError: (error) {
            debugPrint('Error reading pipe: $error');
            _controller.addError(error);
          },
          onDone: () {
            debugPrint('Pipe reading finished for ${_file.path}.');
          },
        );
  }
}
