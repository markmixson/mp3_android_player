import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mp3_android_player/models/audio_file.dart';
import 'package:mp3_android_player/models/haptic_mode.dart';
import 'package:mp3_android_player/providers.dart';
import 'package:mp3_android_player/services/audio_file_picker_service_interface.dart';
import 'package:mp3_android_player/services/audio_player_service_interface.dart';

enum PlaybackStatus { playing, paused, stopped }

class PlayerState {
  final AudioFile? currentFile;
  final PlaybackStatus status;
  final Duration position;
  final Duration duration;
  final HapticMode hapticMode;

  PlayerState({
    this.currentFile,
    this.status = PlaybackStatus.stopped,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.hapticMode = HapticMode.disabled,
  });

  PlayerState copyWith({
    AudioFile? currentFile,
    PlaybackStatus? status,
    Duration? position,
    Duration? duration,
    HapticMode? hapticMode,
  }) {
    return PlayerState(
      currentFile: currentFile ?? this.currentFile,
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      hapticMode: hapticMode ?? this.hapticMode,
    );
  }
}

class PlayerNotifier extends StateNotifier<AsyncValue<PlayerState>> {
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
       super(AsyncValue.data(PlayerState())) {
    _listenToPosition();
  }

  Future<void> toggleHapticMode(HapticMode mode) async {
    if (state.requireValue.status == PlaybackStatus.playing) {
      currentAudioPlayerService.pause();
    }
    final currentPosition = state.requireValue.position;
    state = AsyncValue.data(state.requireValue.copyWith(hapticMode: mode));
    await currentAudioPlayerService.seek(currentPosition);
    if (state.requireValue.status == PlaybackStatus.playing) {
      resumeOrPlay();
    }
  }

  Future<void> pickAndPlayFile() async {
    final file = await _audioFilePickerService.pickFile();
    if (file != null) {
      await currentAudioPlayerService.play(file);
      state = AsyncValue.data(state.requireValue.copyWith(currentFile: file, status: PlaybackStatus.playing));
    }
  }

  Future<void> togglePlayPause() async {
    if (state.requireValue.status == PlaybackStatus.playing) {
      currentAudioPlayerService.pause();
      state = AsyncValue.data(state.requireValue.copyWith(status: PlaybackStatus.paused));
    } else {
      if (state.requireValue.currentFile != null) {
        resumeOrPlay();
        state = AsyncValue.data(state.requireValue.copyWith(status: PlaybackStatus.playing));
      }
    }
  }

  Future<void> resumeOrPlay() async {
    if (currentAudioPlayerService.hasAudioSource) {
      currentAudioPlayerService.resume();
    } else {
      currentAudioPlayerService.play(state.requireValue.currentFile!);
    }
  }

  AudioPlayerService get currentAudioPlayerService {
    return state.requireValue.hapticMode == HapticMode.enabled
        ? _hapticAudioPlayerService
        : _defaultAudioPlayerService;
  }  

  void _listenToPosition() {
    currentAudioPlayerService.positionStream.listen((pos) {
      state = AsyncValue.data(state.requireValue.copyWith(position: pos));
    });
    currentAudioPlayerService.durationStream.listen((dur) {
      state = AsyncValue.data(state.requireValue.copyWith(duration: dur));
    });
  }
}

final playerNotifierProvider =
    StateNotifierProvider<PlayerNotifier, AsyncValue<PlayerState>>((ref) {
      final defaultAudioPlayerService = ref.watch(defaultAudioPlayerServiceProvider);
      final audioFilePickerService = ref.watch(audioFilePickerServiceProvider);
      final hapticAudioPlayerService = ref.watch(hapticAudioPlayerServiceProvider);
      return PlayerNotifier(
        audioPlayerService: defaultAudioPlayerService,
        audioFilePickerService: audioFilePickerService,
        hapticAudioPlayerService: hapticAudioPlayerService,
      );
    });
