import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mp3_android_player/helpers/file_helper.dart';
import 'package:mp3_android_player/helpers/mime_helper.dart';
import 'package:mp3_android_player/models/audio_file.dart';
import 'package:mp3_android_player/services/default_audio_player_service.dart';
import 'package:mp3_android_player/services/haptic_filter_service_interface.dart';
import 'package:mp3_android_player/sources/haptic_stream_audio_source.dart';

class HapticAudioPlayerService extends DefaultAudioPlayerService {
  final AudioPlayer _player;
  final HapticFilterService _hapticFilterService;
  final FileHelper _fileHelper;
  final MimeHelper _mimeHelper;
  static const String defaultType = 'audio/mp3';

  HapticAudioPlayerService({
    required super.player,
    required HapticFilterService hapticFilterService,
    required FileHelper fileHelper,
    required MimeHelper mimeHelper,
  }) : _player = player,
       _hapticFilterService = hapticFilterService,
       _fileHelper = fileHelper,
       _mimeHelper = mimeHelper;

  @override
  Future<dynamic> initialize(final AudioFile audioFile) async {
    return _hapticFilterService.applyHapticFilter(audioFile, ((
      processedPath,
    ) async {
      final file = _fileHelper.getFile(processedPath);
      final contentType = _mimeHelper.getMimeType(audioFile.path, defaultType);
      final source = HapticStreamAudioSource(file, contentType, _hapticFilterService.outputDataStreamController);
      await _player.setAudioSource(source);
      debugPrint("player source initialized for $processedPath, $file of type $contentType");
      return processedPath;
    }));
  }
}
