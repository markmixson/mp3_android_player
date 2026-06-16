import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mp3_android_player/models/haptic_mode.dart';
import 'package:mp3_android_player/models/player_state.dart';
import 'package:mp3_android_player/models/player_status.dart';
import 'package:mp3_android_player/providers.dart';
import 'package:mp3_android_player/services/audio_file_picker_service_interface.dart';
import 'package:mp3_android_player/services/audio_player_service_interface.dart';
import 'package:mp3_android_player/services/preference_service_interface.dart';

class PlayerNotifier extends StateNotifier<PlayerState> {
  final AudioPlayerService _defaultAudioPlayerService;
  final AudioPlayerService _hapticAudioPlayerService;
  final AudioFilePickerService _audioFilePickerService;

  PlayerNotifier({
    required AudioPlayerService audioPlayerService,
    required AudioFilePickerService audioFilePickerService,
    required AudioPlayerService hapticAudioPlayerService,
  }) : _defaultAudioPlayerService = audioPlayerService,
       _audioFilePickerService = audioFilePickerService,
       _hapticAudioPlayerService = hapticAudioPlayerService,
       super(PlayerState());

  Future<void> toggleHapticMode(
    final HapticMode mode,
    final PreferenceService preferenceService,
  ) async {
    if (state.status == PlaybackStatus.playing) {
      currentAudioPlayerService.pause();
    }
    final currentPosition = state.position;
    state = state.copyWith(hapticMode: mode);
    await preferenceService.setHapticMode(mode);
    await currentAudioPlayerService.seek(currentPosition);
    if (state.status == PlaybackStatus.playing) {
      resumeOrPlay();
    }
  }

  Future<void> pickAndPlayFile(final PreferenceService prefs) async {
    final file = await _audioFilePickerService.pickFile();
    if (file != null) {
      state = state.copyWith(
        currentFile: file,
        isLoading: true,
        hapticMode: prefs.getHapticMode(),
      );
      final myCurrentService = currentAudioPlayerService;
      await _hapticAudioPlayerService.initialize(file);
      await _defaultAudioPlayerService.initialize(file);
      _listenToPosition();
      await myCurrentService.play(file);
      state = state.copyWith(
        currentFile: file,
        status: PlaybackStatus.playing,
        isLoading: false,
      );
    }
  }

  Future<void> togglePlayPause() async {
    if (state.status == PlaybackStatus.playing) {
      currentAudioPlayerService.pause();
      state = state.copyWith(status: PlaybackStatus.paused);
    } else {
      if (state.currentFile != null) {
        resumeOrPlay();
        state = state.copyWith(status: PlaybackStatus.playing);
      }
    }
  }

  Future<void> resumeOrPlay() async {
    _listenToPosition();
    if (currentAudioPlayerService.hasAudioSource) {
      currentAudioPlayerService.resume();
    } else {
      currentAudioPlayerService.play(state.currentFile!);
    }
  }

  AudioPlayerService get currentAudioPlayerService {
    return state.hapticMode == HapticMode.enabled
        ? _hapticAudioPlayerService
        : _defaultAudioPlayerService;
  }

  void _listenToPosition() {
    currentAudioPlayerService.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });
    currentAudioPlayerService.durationStream.listen((dur) {
      state = state.copyWith(duration: dur);
    });
  }
}

final playerNotifierProvider =
    StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
      final defaultAudioPlayerService = ref.read(
        defaultAudioPlayerServiceProvider,
      );
      final audioFilePickerService = ref.read(audioFilePickerServiceProvider);
      final hapticAudioPlayerService = ref.read(
        hapticAudioPlayerServiceProvider,
      );
      return PlayerNotifier(
        audioPlayerService: defaultAudioPlayerService,
        audioFilePickerService: audioFilePickerService,
        hapticAudioPlayerService: hapticAudioPlayerService,
      );
    });
