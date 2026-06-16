import 'package:mp3_android_player/models/audio_file.dart';
import 'package:mp3_android_player/models/haptic_mode.dart';
import 'package:mp3_android_player/models/player_status.dart';

class PlayerState {
  final AudioFile? currentFile;
  final PlaybackStatus status;
  final Duration position;
  final Duration duration;
  final HapticMode hapticMode;
  final bool isLoading;

  PlayerState({
    this.currentFile,
    this.status = PlaybackStatus.stopped,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.hapticMode = HapticMode.disabled,
    this.isLoading = false,
  });

  PlayerState copyWith({
    AudioFile? currentFile,
    PlaybackStatus? status,
    Duration? position,
    Duration? duration,
    HapticMode? hapticMode,
    bool? isLoading,
  }) {
    return PlayerState(
      currentFile: currentFile ?? this.currentFile,
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      hapticMode: hapticMode ?? this.hapticMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
