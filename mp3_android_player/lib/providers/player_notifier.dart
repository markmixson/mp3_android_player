import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:mp3_android_player/models/haptic_mode.dart';
import 'package:mp3_android_player/models/player_state.dart';
import 'package:mp3_android_player/models/player_status.dart';
import 'package:mp3_android_player/providers.dart';
import 'package:mp3_android_player/services/audio_file_picker_service_interface.dart';
import 'package:mp3_android_player/services/audio_player_service_interface.dart';
import 'package:mp3_android_player/services/preference_service_interface.dart';
import 'package:mp3_android_player/sources/haptic_stream_audio_source.dart';

class PlayerNotifier extends StateNotifier<PlayerState> {
  final AudioPlayerService _defaultAudioPlayerService;
  final AudioPlayerService _lowPassAudioPlayerService;
  final AudioFilePickerService _audioFilePickerService;

  PlayerNotifier({
    required AudioPlayerService audioPlayerService,
    required AudioFilePickerService audioFilePickerService,
    required AudioPlayerService lowPassAudioPlayerService,
  }) : _defaultAudioPlayerService = audioPlayerService,
       _audioFilePickerService = audioFilePickerService,
       _lowPassAudioPlayerService = lowPassAudioPlayerService,
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
    updateLowPassAudioSource(_lowPassAudioPlayerService.audioSource, mode);
    if (state.status == PlaybackStatus.playing) {
      resumeOrPlay();
    }
  }

  static void updateLowPassAudioSource(final ja.AudioSource? audioSource, final HapticMode mode) {
    if (audioSource is HapticStreamAudioSource) {
      audioSource.setHapticMode(mode);
    }
  }

  Future<void> pickAndPlayFile(
    final PreferenceService prefs,
    [final RootIsolateToken? rootToken]
  ) async {
    final file = await _audioFilePickerService.pickFile();
    if (file != null) {
      state = state.copyWith(
        currentFile: file,
        isLoading: true,
        hapticMode: prefs.getHapticMode(),
      );
      final myCurrentService = currentAudioPlayerService;
      await _lowPassAudioPlayerService.initialize(
        file,
        rootToken,
        state.hapticMode,
      );
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
        ? _lowPassAudioPlayerService
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
      final lowPassAudioPlayerService = ref.read(
        hapticAudioPlayerServiceProvider,
      );
      return PlayerNotifier(
        audioPlayerService: defaultAudioPlayerService,
        audioFilePickerService: audioFilePickerService,
        lowPassAudioPlayerService: lowPassAudioPlayerService,
      );
    });
