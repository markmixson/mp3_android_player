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
  static const String defaultType = 'raw/audio';

  HapticAudioPlayerService({
    required super.player,
    required HapticFilterService hapticFilterService,
    required FileHelper fileHelper,
  }) : _player = player,
       _hapticFilterService = hapticFilterService,
       _fileHelper = fileHelper;

  @override
  Future<dynamic> initialize(final AudioFile audioFile) async {
    return _hapticFilterService.applyHapticFilter(audioFile, ((
      processedPath,
    ) async {
      final file = _fileHelper.getFile(processedPath);
      final source = HapticStreamAudioSource(file, defaultType, _hapticFilterService.outputDataStreamController);
      await _player.setAudioSource(source);
      debugPrint("player source initialized for $processedPath, $file of type $defaultType");
      return processedPath;
    }));
  }
}
