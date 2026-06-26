import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mp3_android_player/models/haptic_mode.dart';
import 'package:mp3_android_player/wrappers/file_wrapper.dart';
import 'package:mp3_android_player/models/audio_file.dart';
import 'package:mp3_android_player/services/default_audio_player_service.dart';
import 'package:mp3_android_player/services/haptic_service_interface.dart';
import 'package:mp3_android_player/services/low_pass_filter_service_interface.dart';
import 'package:mp3_android_player/sources/haptic_stream_audio_source.dart';

class HapticAudioPlayerService extends DefaultAudioPlayerService {
  final AudioPlayer _player;
  final LowPassFilterService _lowPassFilterService;
  final FileWrapper _fileWrapper;
  final HapticService _hapticService;
  static const String defaultType = 'audio/matroska';
  final Future<SendPort> Function(ReceivePort receivePort) _processorFunction;

  HapticAudioPlayerService({
    required super.player,
    required LowPassFilterService lowPassFilterService,
    required FileWrapper fileWrapper,
    required HapticService hapticService,
    required Future<SendPort> Function(ReceivePort receivePort)
    processorFunction,
  }) : _player = player,
       _lowPassFilterService = lowPassFilterService,
       _fileWrapper = fileWrapper,
       _hapticService = hapticService,
       _processorFunction = processorFunction;

  @override
  void pause() {
    _hapticService.stopHaptics();
    super.pause();
  }

  @override
  void stop() async {
    _hapticService.stopHaptics();
    super.stop();
  }

  @override
  Future<dynamic> initialize(
    final AudioFile audioFile, [
    final RootIsolateToken? rootToken,
    final HapticMode? hapticMode,
  ]) async {
    return _lowPassFilterService.applyLowPassFilter(audioFile, ((
      processedPath,
    ) async {
      final file = _fileWrapper.getFile(processedPath);
      if (_player.audioSource is HapticStreamAudioSource) {
        final source = _player.audioSource! as HapticStreamAudioSource;
        source.dispose();
      }
      debugPrint(
        "creating hapticStreamAudioSource with file ${file.path}, type $defaultType, hapticMode $hapticMode, and token $rootToken",
      );
      final source = await HapticStreamAudioSource.create(
        file,
        defaultType,
        _processorFunction,
        hapticMode ?? HapticMode.disabled,
        rootToken,
      );
      debugPrint("setting audio source");
      await _player.setAudioSource(source);
      debugPrint(
        "player source initialized for $processedPath, $file of type $defaultType",
      );
      return processedPath;
    }));
  }
}
