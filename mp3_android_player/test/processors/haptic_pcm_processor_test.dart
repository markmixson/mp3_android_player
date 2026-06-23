import 'package:flutter_test/flutter_test.dart';
import 'package:mp3_android_player/processors/haptic_pcm_processor.dart';

void main() {
  group('HapticPCMProcessor', () {
    test('returns empty list when samplesPerWindow is 0 (zero duration)', () {
      final processor = HapticPCMProcessor(
        sampleRate: 44100,
        windowDuration: Duration.zero,
      );
      expect(processor.processPcmData([]), isEmpty);
    });

    test('returns empty list when samplesPerWindow is 0 (zero sample rate)', () {
      final processor = HapticPCMProcessor(
        sampleRate: 0,
        windowDuration: const Duration(milliseconds: 100),
      );
      expect(processor.processPcmData([]), isEmpty);
    });

    test('returns empty list when pcmData is empty', () {
      final processor = HapticPCMProcessor(
        sampleRate: 44100,
        windowDuration: const Duration(milliseconds: 10),
      );
      expect(processor.processPcmData([]), isEmpty);
    });

    group('Parameterized Tests for processPcmData', () {
      final testCases = [
        {
          'name': 'Single positive sample (S=100)',
          'sampleRate': 100,
          'windowDuration': const Duration(milliseconds: 20), // samplesPerWindow = 2
          'pcmData': <int>[100, 0],
          'expected': <int>[100],
        },
        {
          'name': 'Single negative sample (S=-1000)',
          'sampleRate': 100,
          'windowDuration': const Duration(milliseconds: 20), // samplesPerWindow = 2
          'pcmData': <int>[24, 252], // -1000 in little-endian bytes
          'expected': <int>[255], // Clamped from 1000
        },
        {
          'name': 'Multiple samples in one window (S1=100, S2=200)',
          'sampleRate': 100,
          'windowDuration': const Duration(milliseconds: 40), // samplesPerWindow = 4
          'pcmData': <int>[100, 0, 200, 0],
          'expected': <int>[158], // sqrt((100^2 + 200^2) / 2) = sqrt(25000) ≈ 158.11
        },
        {
          'name': 'Odd number of bytes in chunk (S1=100, extra byte)',
          'sampleRate': 100,
          'windowDuration': const Duration(milliseconds: 30), // samplesPerWindow = 3
          'pcmData': <int>[100, 0, 50],
          'expected': <int>[82], // sqrt((100^2) / (3/2)) = sqrt(6666.67) ≈ 81.65 -> 82
        },
        {
          'name': 'Last chunk is smaller than window size',
          'sampleRate': 100,
          'windowDuration': const Duration(milliseconds: 40), // samplesPerWindow = 4
          'pcmData': <int>[100, 0, 200, 0, 50, 0], // S1=100, S2=200, S3=50
          'expected': <int>[158, 50], // Window 1: [100, 0, 200, 0] -> 158; Window 2: [50, 0] -> 50
        },
        {
          'name': 'Clamping amplitude to 255',
          'sampleRate': 100,
          'windowDuration': const Duration(milliseconds: 20), // samplesPerWindow = 2
          'pcmData': <int>[0, 255], // S=65280 -> clamped to 255
          'expected': <int>[255],
        },
      ];

      for (final testCase in testCases) {
        test(testCase['name'] as String, () {
          final processor = HapticPCMProcessor(
            sampleRate: testCase['sampleRate'] as int,
            windowDuration: testCase['windowDuration'] as Duration,
          );
          final result = processor.processPcmData(List<int>.from(testCase['pcmData'] as List));
          expect(result, equals(testCase['expected']));
        });
      }
    });

    group('Edge Cases for _getSumOfSquares logic', () {
      test('Handles very large negative values (S=-32768)', () {
        final processor = HapticPCMProcessor(sampleRate: 100, windowDuration: const Duration(milliseconds: 20));
        // -32768 in hex is 0x8000. Little-endian: [0x00, 0x80] -> [0, 128]
        final result = processor.processPcmData([0, 128]);
        expect(result[0], equals(255)); // sqrt((-32768)^2 / 1) is huge, clamped to 255
      });

      test('Handles very large positive values (S=32767)', () {
        final processor = HapticPCMProcessor(sampleRate: 100, windowDuration: const Duration(milliseconds: 20));
        // 32767 in hex is 0x7FFF. Little-endian: [0xFF, 0x7F] -> [255, 127]
        final result = processor.processPcmData([255, 127]);
        expect(result[0], equals(255)); // sqrt(32767^2 / 1) is huge, clamped to 255
      });
    });
  });
}
