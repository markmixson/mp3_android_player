import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mp3_android_player/models/audio_file.dart';
import 'package:mp3_android_player/providers.dart';
import 'package:mp3_android_player/services/audio_file_picker_service_interface.dart';
import 'package:mp3_android_player/services/audio_player_service_interface.dart';

enum PlaybackStatus { playing, paused, stopped }

class PlayerState {
  final AudioFile? currentFile;
  final PlaybackStatus status;
  final Duration position;
  final Duration duration;

  PlayerState({
    this.currentFile,
    this.status = PlaybackStatus.stopped,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  PlayerState copyWith({
    AudioFile? currentFile,
    PlaybackStatus? status,
    Duration? position,
    Duration? duration,
  }) {
    return PlayerState(
      currentFile: currentFile ?? this.currentFile,
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

class PlayerNotifier extends StateNotifier<PlayerState> {
  final AudioPlayerService _audioPlayerService;
  final AudioFilePickerService _audioFilePickerService;

  PlayerNotifier({
    required AudioPlayerService audioPlayerService,
    required AudioFilePickerService audioFilePickerService,
  }) : _audioPlayerService = audioPlayerService,
       _audioFilePickerService = audioFilePickerService,
       super(PlayerState()) {
    _listenToPosition();
  }

  Future<void> pickAndPlayFile() async {
    final file = await _audioFilePickerService.pickFile();
    if (file != null) {
      await _audioPlayerService.play(file);
      state = state.copyWith(currentFile: file, status: PlaybackStatus.playing);
    }
  }

  Future<void> togglePlayPause() async {
    if (state.status == PlaybackStatus.playing) {
      _audioPlayerService.pause();
      state = state.copyWith(status: PlaybackStatus.paused);
    } else {
      if (state.currentFile != null) {
        _audioPlayerService.resume();
        state = state.copyWith(status: PlaybackStatus.playing);
      }
    }
  }

  void _listenToPosition() {
    _audioPlayerService.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });
    _audioPlayerService.durationStream.listen((dur) {
      state = state.copyWith(duration: dur);
    });
  }
}

final playerNotifierProvider =
    StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
      final audioPlayerService = ref.watch(audioPlayerServiceProvider);
      final audioFilePickerService = ref.watch(audioFilePickerServiceProvider);
      return PlayerNotifier(
        audioPlayerService: audioPlayerService,
        audioFilePickerService: audioFilePickerService,
      );
    });
