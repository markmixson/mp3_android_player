// coverage:ignore-file
abstract class HapticService {
  /// Plays a pattern of haptic amplitude samples.
  Future<void> playHapticPattern(
    List<int> pattern,
    int sampleWindowDurationMillis,
  ) async => throw UnimplementedError();

  /// Stops any ongoing haptic playback.
  Future<void> stopHaptics() async => throw UnimplementedError();
}
