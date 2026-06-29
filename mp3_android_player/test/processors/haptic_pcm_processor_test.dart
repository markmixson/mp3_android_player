import 'package:flutter_test/flutter_test.dart';
import 'package:mp3_android_player/processors/haptic_pcm_processor.dart';

void main() {
  group('HapticPCMProcessor', () {
    test(
      'returns empty list when samplesPerWindow is 0 (zero duration)',
      () async {
        final processor = HapticPCMProcessor(
          sampleRate: 44100,
          windowDuration: Duration.zero,
        );
        expect(await processor.processPcmData([]), isEmpty);
      },
    );

    test(
      'returns empty list when samplesPerWindow is 0 (zero sample rate)',
      () async {
        final processor = HapticPCMProcessor(
          sampleRate: 0,
          windowDuration: const Duration(milliseconds: 100),
        );
        expect(await processor.processPcmData([]), isEmpty);
      },
    );

    test('returns empty list when pcmData is empty', () async {
      final processor = HapticPCMProcessor(
        sampleRate: 44100,
        windowDuration: const Duration(milliseconds: 10),
      );
      expect(await processor.processPcmData([]), isEmpty);
    });

    group('Parameterized Tests for processPcmData', () {
      final testCases = [
        {
          'name': 'Single positive sample (S=16384, 50% max volume)',
          'sampleRate': 100,
          'windowDuration': const Duration(
            milliseconds: 20,
          ), // samplesPerWindow = 2 -> 4 bytes
          'pcmData': <int>[0, 64], // 16384 in little-endian bytes (0x4000)
          'expected': <int>[
            128,
          ], // (16384 / 32768) * 255 = 127.5 -> rounded to 128
        },
        {
          'name': 'Single negative sample (S=-16384)',
          'sampleRate': 100,
          'windowDuration': const Duration(
            milliseconds: 20,
          ), // samplesPerWindow = 2 -> 4 bytes
          'pcmData': <int>[0, 192], // -16384 in little-endian bytes (0xC000)
          'expected': <int>[128], // RMS is 16384 -> Amplitude is 128
        },
        {
          'name': 'Multiple samples in one window (S1=16384, S2=32767)',
          'sampleRate': 100,
          'windowDuration': const Duration(
            milliseconds: 20,
          ), // samplesPerWindow = 2 -> 4 bytes
          'pcmData': <int>[0, 64, 255, 127], // 16384 and 32767
          'expected': <int>[
            202,
          ], // sqrt((16384^2 + 32767^2) / 2) ≈ 25904.7. (25904.7 / 32768) * 255 ≈ 202
        },
        {
          'name': 'Odd number of bytes in chunk (S1=16384, extra byte)',
          'sampleRate': 100,
          'windowDuration': const Duration(
            milliseconds: 20,
          ), // samplesPerWindow = 2 -> 4 bytes
          'pcmData': <int>[0, 64, 50], // Extra byte '50' gets ignored
          'expected': <int>[128], // Only processes the first complete sample
        },
        {
          'name': 'Last chunk is smaller than window size',
          'sampleRate': 100,
          'windowDuration': const Duration(
            milliseconds: 20,
          ), // samplesPerWindow = 2 -> 4 bytes
          'pcmData': <int>[
            0,
            64,
            255,
            127,
            0,
            192,
          ], // 3 samples total, split across 2 chunks
          'expected': <int>[
            202,
            128,
          ], // Chunk 1: [0, 64, 255, 127] -> 202; Chunk 2: [0, 192] -> 128
        },
        {
          'name': 'Very low volume gets scaled down near zero',
          'sampleRate': 100,
          'windowDuration': const Duration(
            milliseconds: 20,
          ), // samplesPerWindow = 2 -> 4 bytes
          'pcmData': <int>[100, 0], // S=100.
          'expected': <int>[1], // (100 / 32768) * 255 ≈ 0.77 -> rounded to 1
        },
      ];

      for (final testCase in testCases) {
        test(testCase['name'] as String, () async {
          final processor = HapticPCMProcessor(
            sampleRate: testCase['sampleRate'] as int,
            windowDuration: testCase['windowDuration'] as Duration,
          );
          final result = await processor.processPcmData(
            List<int>.from(testCase['pcmData'] as List),
          );
          expect(result, equals(testCase['expected']));
        });
      }
    });

    group('Edge Cases for _getSumOfSquares logic', () {
      test('Handles absolute minimum negative value (S=-32768)', () async {
        final processor = HapticPCMProcessor(
          sampleRate: 100,
          windowDuration: const Duration(milliseconds: 20),
        );
        // -32768 in hex is 0x8000. Little-endian: [0x00, 0x80] -> [0, 128]
        final result = await processor.processPcmData([0, 128]);
        expect(result[0], equals(255)); // (32768 / 32768) * 255 = 255
      });

      test('Handles absolute maximum positive value (S=32767)', () async {
        final processor = HapticPCMProcessor(
          sampleRate: 100,
          windowDuration: const Duration(milliseconds: 20),
        );
        // 32767 in hex is 0x7FFF. Little-endian: [0xFF, 0x7F] -> [255, 127]
        final result = await processor.processPcmData([255, 127]);
        expect(
          result[0],
          equals(255),
        ); // (32767 / 32768) * 255 ≈ 254.99 -> rounded to 255
      });
    });
  });
}
