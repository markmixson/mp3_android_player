import 'package:mp3_android_player/models/audio_file.dart';

// coverage:ignore-file
abstract class AudioPlayerService {
  Future<void> play(AudioFile audioFile) async => throw UnimplementedError();
  void pause() => throw UnimplementedError();
  void resume() => throw UnimplementedError();
  Future<void> seek(Duration position) async => throw UnimplementedError();
  Stream<Duration> get positionStream;
  Stream<Duration> get durationStream;
  void stop() => throw UnimplementedError();
}
