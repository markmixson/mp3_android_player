import 'dart:math';

/// Processes PCM audio data to extract haptic amplitude samples.
class HapticPCMProcessor {
  final int sampleRate;
  final Duration windowDuration;

  /// Creates a [HapticPCMProcessor] with the specified [sampleRate] and [windowDuration].
  HapticPCMProcessor({required this.sampleRate, required this.windowDuration});

  /// Each sample represents the RMS amplitude for one [windowDuration] chunk.
  Future<List<int>> processPcmData(final List<int> pcmData) async {
    final samplesPerWindow = (sampleRate * windowDuration.inMilliseconds / 1000)
        .round();

    if (samplesPerWindow <= 0) {
      return [];
    } else {
      return _getHapticAmplitudeSamples(pcmData, samplesPerWindow);
    }
  }

  List<int> _getHapticAmplitudeSamples(
    final List<int> pcmData,
    final int samplesPerWindow,
  ) {
    final List<int> pattern = [];

    // Fix: 1 sample = 2 bytes, so our window chunk size must be doubled
    final int bytesPerWindow = samplesPerWindow * 2;

    for (int i = 0; i < pcmData.length; i += bytesPerWindow) {
      final end = (i + bytesPerWindow < pcmData.length)
          ? i + bytesPerWindow
          : pcmData.length;
      final chunk = pcmData.sublist(i, end);

      final sumSquares = _getSumOfSquares(chunk);

      // Calculate RMS amplitude for the chunk
      final int numberOfSamples = chunk.length ~/ 2;
      if (numberOfSamples == 0) continue;

      final double rms = sqrt(sumSquares / numberOfSamples);

      // Fix: Normalize the 16-bit RMS (0 - 32768) to an 8-bit scale (0 - 255)
      final int amplitude = ((rms / 32768.0) * 255).round().clamp(0, 255);
      pattern.add(amplitude);
    }
    return pattern;
  }

  double _getSumOfSquares(final List<int> chunk) {
    double sumSquares = 0;
    for (int j = 0; j < chunk.length; j += 2) {
      if (j + 1 >= chunk.length) break;

      // Convert two bytes to a signed 16-bit integer (little-endian)
      // Added defensive bitwise ANDs on both bytes to guarantee no sign-extension issues
      final int byte1 = chunk[j] & 0xFF;
      final int byte2 = chunk[j + 1] & 0xFF;
      int sample = (byte2 << 8) | byte1;

      if (sample > 32767) {
        sample -= 65536;
      }

      sumSquares += (sample * sample);
    }
    return sumSquares;
  }
}
