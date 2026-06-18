// coverage:ignore-file
import 'package:mp3_android_player/models/audio_file.dart';

abstract class AudioPlayerService {
  Future<dynamic> initialize(AudioFile audioFile) async => throw UnimplementedError();
  Future<void> play(AudioFile audioFile, [int position = 0]) async => throw UnimplementedError();
  void pause() => throw UnimplementedError();
  Future<void> resume(AudioFile audioFile, [int position = 0]) => throw UnimplementedError();
  Future<void> seek(Duration position) async => throw UnimplementedError();
  Stream<Duration> getPositionStream(AudioFile audioFile, [int position = 0]) => throw UnimplementedError();
  Stream<Duration> getDurationStream(AudioFile audioFile) => throw UnimplementedError();
  void stop() => throw UnimplementedError();
  bool get hasAudioSource => throw UnimplementedError();
}
