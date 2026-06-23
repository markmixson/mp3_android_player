import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mp3_android_player/processors/haptic_pcm_processor.dart';
import 'package:mp3_android_player/wrappers/advanced_haptics_wrapper.dart';
import 'package:mp3_android_player/helpers/ffmpeg_helper.dart';
import 'package:mp3_android_player/wrappers/ffmpeg_wrapper.dart';
import 'package:mp3_android_player/wrappers/file_wrapper.dart';
import 'package:mp3_android_player/wrappers/temporary_directory_wrapper.dart';
import 'package:mp3_android_player/services/audio_file_picker_service_interface.dart';
import 'package:mp3_android_player/services/audio_player_service_interface.dart';
// ignore: implementation_imports
import 'package:file_picker/src/platform/file_picker_platform_interface.dart';
import 'package:mp3_android_player/services/default_audio_file_picker_service.dart';
import 'package:mp3_android_player/services/default_audio_player_service.dart';
import 'package:mp3_android_player/services/default_haptic_service.dart';
import 'package:mp3_android_player/services/default_low_pass_filter_service.dart';
import 'package:mp3_android_player/services/default_preference_service.dart';
import 'package:mp3_android_player/services/haptic_service_interface.dart';
import 'package:mp3_android_player/services/haptic_audio_player_service.dart';
import 'package:mp3_android_player/services/low_pass_filter_service_interface.dart';
import 'package:mp3_android_player/services/preference_service_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

// coverage:ignore-file
/// Provider for the [AudioFilePickerService].
final audioFilePickerServiceProvider = Provider<AudioFilePickerService>((ref) {
  return DefaultAudioFilePickerService(filePicker: FilePickerPlatform.instance);
});

/// Provider for the [FFmpegHelper]
final ffmpegHelperProvider = Provider<FFmpegHelper>((ref) {
  return FFmpegHelper(wrapper: FFmpegWrapper());
});

/// Provider for the [LowPassFilterService]
final lowPassFilterServiceProvider = Provider<LowPassFilterService>((ref) {
  final ffmpegWrapper = ref.read(ffmpegHelperProvider);
  final lowPassFilterService = DefaultLowPassFilterService(
    clock: Clock(),
    ffmpegHelper: ffmpegWrapper,
    temporaryDirectoryWrapper: TemporaryDirectoryWrapper(),
    fileWrapper: FileWrapper(),
  );
  ref.onDispose(() {
    lowPassFilterService.clearTemporaryFiles();
  });
  return lowPassFilterService;
});

/// Default Provider for the [AudioPlayerService].
final defaultAudioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final audioPlayer = AudioPlayer();
  ref.onDispose(() {
    audioPlayer.dispose();
  });
  return DefaultAudioPlayerService(player: audioPlayer);
});

/// Default Provider for the [HapticService].
final hapticServiceProvider = Provider<HapticService>((ref) {
  final hapticService = DefaultHapticService(
    hapticsWrapper: AdvancedHapticsWrapper(),
    processor: HapticPCMProcessor(
      sampleRate: 44100,
      windowDuration: Duration(milliseconds: 20),
    ),
  );
  ref.onDispose(() {
    hapticService.stopHaptics();
  });
  return hapticService;
});

/// Haptic Audio Provider for the [AudioPlayerService].
final hapticAudioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final lowPassFilterService = ref.read(lowPassFilterServiceProvider);
  final hapticService = ref.read(hapticServiceProvider);
  final audioPlayer = AudioPlayer();
  ref.onDispose(() {
    audioPlayer.dispose();
  });
  return HapticAudioPlayerService(
    player: audioPlayer,
    lowPassFilterService: lowPassFilterService,
    fileWrapper: FileWrapper(),
    hapticService: hapticService,
  );
});

/// Default provider for the [PreferenceService]
final preferenceServiceProvider = FutureProvider<PreferenceService?>((
  ref,
) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  return DefaultPreferenceService(sharedPreferences);
});
