import 'dart:ui';

import 'package:just_audio/just_audio.dart';
import 'package:mp3_android_player/models/audio_file.dart';
import 'package:mp3_android_player/models/haptic_mode.dart';

// coverage:ignore-file
abstract class AudioPlayerService {
  Future<dynamic> initialize(AudioFile audioFile, [RootIsolateToken? rootToken, HapticMode? hapticMode]) async => throw UnimplementedError();
  Future<void> play(AudioFile audioFile) async => throw UnimplementedError();
  void pause() => throw UnimplementedError();
  void resume() => throw UnimplementedError();
  Future<void> seek(Duration position) async => throw UnimplementedError();
  Stream<Duration> get positionStream;
  Stream<Duration> get durationStream;
  void stop() => throw UnimplementedError();
  bool get hasAudioSource => throw UnimplementedError();
  AudioSource? get audioSource => throw UnimplementedError();
}
