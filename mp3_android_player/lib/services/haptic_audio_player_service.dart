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
  final MimeHelper _mimeHelper;
  final FileHelper _fileHelper;
  static const String defaultType = 'audio/mpeg';

  HapticAudioPlayerService({
    required super.player,
    required HapticFilterService hapticFilterService,
    required MimeHelper mimeHelper,
    required FileHelper fileHelper,
  }) : _player = player,
       _hapticFilterService = hapticFilterService,
       _mimeHelper = mimeHelper,
       _fileHelper = fileHelper;

  @override
  void initialize(final AudioFile audioFile) async {
    await _hapticFilterService.applyHapticFilter(audioFile, ((
      processedPath,
    ) async {
      final file = _fileHelper.getFile(processedPath);
      final contentType = _mimeHelper.getMimeType(processedPath, defaultType);
      final source = HapticStreamAudioSource(file, contentType);
      await _player.setAudioSource(source);
      debugPrint("player source initialized for $processedPath, $file of type $contentType");
      return processedPath;
    }));
  }
}
