import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mp3_android_player/helpers/file_helper.dart';
import 'package:mp3_android_player/models/audio_file.dart';
import 'package:mp3_android_player/services/default_audio_player_service.dart';
import 'package:mp3_android_player/services/haptic_filter_service_interface.dart';
import 'package:mp3_android_player/sources/haptic_stream_audio_source.dart';

class HapticAudioPlayerService extends DefaultAudioPlayerService {
  final AudioPlayer _player;
  final HapticFilterService _hapticFilterService;
  final FileHelper _fileHelper;
  static const String defaultType = 'audio/mpeg';

  HapticAudioPlayerService({
    required super.player,
    required HapticFilterService hapticFilterService,
    required FileHelper fileHelper,
  }) : _player = player,
       _hapticFilterService = hapticFilterService,
       _fileHelper = fileHelper;

  @override
  Future<void> play(final AudioFile audioFile, [int position = 0]) async {
    await _applyHapticFilter(audioFile, position);
    return _player.play();
  }

  @override
  Future<void> resume(final AudioFile audioFile, [int position = 0]) async {
    return play(audioFile, position);
  }

  @override
  Future<void> seek(final Duration position) async {
    // does nothing
  }

  @override
  Future<dynamic> initialize(final AudioFile audioFile) async {
    // nothing to initialize
  }

  @override
  Stream<Duration> getPositionStream(
    final AudioFile audioFile, [
    int position = 0,
  ]) {
    final positionDuration = Duration(milliseconds: position);
    return _player
        .createPositionStream(
          steps: audioFile.duration.inSeconds - positionDuration.inSeconds,
          minPeriod: positionDuration,
          maxPeriod: audioFile.duration,
        )
        .cast<Duration>();
  }

  @override
  Stream<Duration> getDurationStream(final AudioFile audioFile) {
    return _player
        .createPositionStream(
          steps: 1,
          minPeriod: audioFile.duration,
          maxPeriod: audioFile.duration,
        )
        .cast<Duration>();
  }

  Future<String> _applyHapticFilter(
    final AudioFile audioFile,
    int position,
  ) async {
    return _hapticFilterService.applyHapticFilter(audioFile, position, ((
      processedPath,
    ) async {
      final file = _fileHelper.getFile(processedPath);
      final source = HapticStreamAudioSource(file, defaultType);
      await _player.setAudioSource(source);
      debugPrint(
        "player source initialized for $processedPath, $file of type $defaultType",
      );
      return processedPath;
    }));
  }
}
