import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mp3_android_player/helpers/ffmpeg_helper.dart';
import 'package:mp3_android_player/helpers/ffmpeg_wrapper.dart';
import 'package:mp3_android_player/helpers/file_helper.dart';
import 'package:mp3_android_player/helpers/mime_helper.dart';
import 'package:mp3_android_player/helpers/temporary_directory_helper.dart';
import 'package:mp3_android_player/pipes/haptic_audio_pipe.dart';
import 'package:mp3_android_player/services/audio_file_picker_service_interface.dart';
import 'package:mp3_android_player/services/audio_player_service_interface.dart';
// ignore: implementation_imports
import 'package:file_picker/src/platform/file_picker_platform_interface.dart';
import 'package:mp3_android_player/services/default_audio_file_picker_service.dart';
import 'package:mp3_android_player/services/default_audio_player_service.dart';
import 'package:mp3_android_player/services/default_haptic_filter_service.dart';
import 'package:mp3_android_player/services/default_preference_service.dart';
import 'package:mp3_android_player/services/haptic_audio_player_service.dart';
import 'package:mp3_android_player/services/haptic_filter_service_interface.dart';
import 'package:mp3_android_player/services/preference_service_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

// coverage:ignore-file
/// Provider for the [AudioFilePickerService].
final audioFilePickerServiceProvider = Provider<AudioFilePickerService>((ref) {
  return DefaultAudioFilePickerService(filePicker: FilePickerPlatform.instance);
});

/// Provider for the [HapticFilterService]
final hapticFilterServiceProvider = Provider<HapticFilterService>((ref) {
  final ffmpegWrapper = FFmpegWrapper();
  final hapticFilterService = DefaultHapticFilterService(
    clock: Clock(),
    ffmpegHelper: FFmpegHelper(wrapper: ffmpegWrapper),
    temporaryDirectoryHelper: TemporaryDirectoryHelper(),
    fileHelper: FileHelper(),
  );
  ref.onDispose(() {
    hapticFilterService.clearTemporaryFiles();
  });
  return hapticFilterService;
});

/// Default Provider for the [AudioPlayerService].
final defaultAudioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final player = DefaultAudioPlayerService(player: AudioPlayer());
  ref.onDispose(() {
    player.dispose();
  });
  return player;
});

/// Haptic Audio Provider for the [AudioPlayerService].
final hapticAudioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final hapticFilterService = ref.read(hapticFilterServiceProvider);
  final audioPlayer = AudioPlayer();
  final hapticPipe = HapticAudioPipe(audioPlayer);

  final player = HapticAudioPlayerService(
    player: audioPlayer,
    hapticFilterService: hapticFilterService,
    mimeHelper: MimeHelper(),
    fileHelper: FileHelper(),
  );
  ref.onDispose(() {
    hapticPipe.dispose();
    player.dispose();
  });
  return player;
});

final preferenceServiceProvider = FutureProvider<PreferenceService?>((
  ref,
) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  return DefaultPreferenceService(sharedPreferences);
});
