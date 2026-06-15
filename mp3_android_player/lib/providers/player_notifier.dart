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
  final PreferenceService _preferenceService;

  PlayerNotifier({
    required AudioPlayerService audioPlayerService,
    required AudioFilePickerService audioFilePickerService,
    required AudioPlayerService hapticAudioPlayerService,
    required PreferenceService preferenceService,
  }) : _defaultAudioPlayerService = audioPlayerService,
       _audioFilePickerService = audioFilePickerService,
       _hapticAudioPlayerService = hapticAudioPlayerService,
       _preferenceService = preferenceService,
       super(PlayerState()) {
    _listenToPosition();
    _initializeHapticMode();
  }

  Future<void> _initializeHapticMode() async {
    final hapticMode = await _preferenceService.getHapticMode();
    state = state.copyWith(hapticMode: hapticMode);
  }

  Future<void> toggleHapticMode(HapticMode mode) async {
    if (state.status == PlaybackStatus.playing) {
      currentAudioPlayerService.pause();
    }
    final currentPosition = state.position;
    state = state.copyWith(hapticMode: mode);
    await _preferenceService.setHapticMode(mode);
    await currentAudioPlayerService.seek(currentPosition);
    if (state.status == PlaybackStatus.playing) {
      resumeOrPlay();
    }
  }

  Future<void> pickAndPlayFile() async {
    final file = await _audioFilePickerService.pickFile();
    if (file != null) {
      _hapticAudioPlayerService.initialize(file);
      _defaultAudioPlayerService.initialize(file);
      await currentAudioPlayerService.play(file);
      state = state.copyWith(currentFile: file, status: PlaybackStatus.playing);
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
    _defaultAudioPlayerService.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });
    _defaultAudioPlayerService.durationStream.listen((dur) {
      state = state.copyWith(duration: dur);
    });
    _hapticAudioPlayerService.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });
    _hapticAudioPlayerService.durationStream.listen((dur) {
      state = state.copyWith(duration: dur);
    });
  }
}

final playerNotifierProvider =
    StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
      final defaultAudioPlayerService = ref.watch(
        defaultAudioPlayerServiceProvider,
      );
      final audioFilePickerService = ref.watch(audioFilePickerServiceProvider);
      final hapticAudioPlayerService = ref.watch(
        hapticAudioPlayerServiceProvider,
      );
      final preferenceService = ref.watch(preferenceServiceProvider);
      return PlayerNotifier(
        audioPlayerService: defaultAudioPlayerService,
        audioFilePickerService: audioFilePickerService,
        hapticAudioPlayerService: hapticAudioPlayerService,
        preferenceService: preferenceService,
      );
    });
