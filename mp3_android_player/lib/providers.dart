import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mp3_android_player/services/audio_file_picker_service_interface.dart';
import 'package:mp3_android_player/services/audio_player_service_interface.dart';
// ignore: implementation_imports
import 'package:file_picker/src/platform/file_picker_platform_interface.dart';
import 'package:mp3_android_player/services/default_audio_file_picker_service.dart';
import 'package:mp3_android_player/services/default_audio_player_service.dart';

// coverage:ignore-file
/// Provider for the [AudioFilePickerService].
final audioFilePickerServiceProvider = Provider<AudioFilePickerService>((ref) {
  return DefaultAudioFilePickerService(filePicker: FilePickerPlatform.instance);
});

/// Provider for the [AudioPlayerService].
final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  return DefaultAudioPlayerService(player: AudioPlayer());
});
