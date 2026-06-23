import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mp3_android_player/models/audio_file.dart';
import 'package:mp3_android_player/services/audio_player_service_interface.dart';

class DefaultAudioPlayerService implements AudioPlayerService {
  final AudioPlayer _player;

  DefaultAudioPlayerService({required AudioPlayer player}) : _player = player;

  @override
  Future<void> play(final AudioFile audioFile) async {
    try {
      _player.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
      rethrow;
    }
  }

  @override
  void pause() {
    _player.pause();
  }

  @override
  void resume() {
    _player.play();
  }

  @override
  Future<void> seek(final Duration position) async {
    await _player.seek(position);
  }

  @override
  Stream<Duration> get positionStream =>
      _player.positionStream.cast<Duration>();

  @override
  Stream<Duration> get durationStream =>
      _player.durationStream.cast<Duration>();

  @override
  void stop() async {
    _player.stop();
  }

  @override
  bool get hasAudioSource => _player.audioSource != null;

  @override
  Future<dynamic> initialize(final AudioFile audioFile) async {
    return _player.setFilePath(audioFile.path);
  }
}
