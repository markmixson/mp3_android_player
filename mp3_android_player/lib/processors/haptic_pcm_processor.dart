import 'dart:math';

/// Processes PCM audio data to extract haptic amplitude samples.
class HapticPCMProcessor {
  final int sampleRate;
  final Duration windowDuration;

  /// Creates a [HapticPCMProcessor] with the specified [sampleRate] and [windowDuration].
  HapticPCMProcessor({required this.sampleRate, required this.windowDuration});

  /// Each sample represents the RMS amplitude for one [windowDuration] chunk.
  List<int> processPcmData(final List<int> pcmData) {
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
    for (int i = 0; i < pcmData.length; i += samplesPerWindow) {
      final end = (i + samplesPerWindow < pcmData.length)
          ? i + samplesPerWindow
          : pcmData.length;
      final chunk = pcmData.sublist(i, end);

      // Calculate RMS amplitude for the chunk
      final sumSquares = _getSumOfSquares(chunk);
      final rms = sqrt(sumSquares / (chunk.length / 2));
      final amplitude = rms.round().clamp(0, 255);
      pattern.add(amplitude);
    }
    return pattern;
  }

  double _getSumOfSquares(final List<int> chunk) {
    // Calculate RMS amplitude for the chunk
    double sumSquares = 0;
    for (int j = 0; j < chunk.length; j += 2) {
      if (j + 1 >= chunk.length) break;

      // Convert two bytes to a signed 16-bit integer (little-endian)
      final byte1 = chunk[j];
      final byte2 = chunk[j + 1];
      int sample = (byte2 << 8) | (byte1 & 0xFF);
      if (sample > 32767) {
        sample -= 65536;
      }

      sumSquares += sample * sample;
    }
    return sumSquares;
  }
}
