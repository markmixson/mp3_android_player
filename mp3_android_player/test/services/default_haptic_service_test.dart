import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mp3_android_player/processors/haptic_pcm_processor.dart';
import 'package:mp3_android_player/services/default_haptic_service.dart';
import 'package:mp3_android_player/wrappers/advanced_haptics_wrapper.dart';

class MockAdvancedHapticsWrapper extends Mock implements AdvancedHapticsWrapper {}
class MockHapticPCMProcessor extends Mock implements HapticPCMProcessor {}

void main() {
  late DefaultHapticService defaultHapticService;
  late MockAdvancedHapticsWrapper mockHapticsWrapper;
  late MockHapticPCMProcessor mockProcessor;

  setUpAll(() {
    registerFallbackValue(List<int>.from([0]));
    registerFallbackValue(List<int>.from([]));
  });

  setUp(() {
    mockHapticsWrapper = MockAdvancedHapticsWrapper();
    mockProcessor = MockHapticPCMProcessor();
    defaultHapticService = DefaultHapticService(
      hapticsWrapper: mockHapticsWrapper,
      processor: mockProcessor,
    );
  });

  group('playHapticPattern', () {
    final testCases = [
      {
        'name': 'empty pattern',
        'pattern': <int>[],
        'duration': const Duration(milliseconds: 10),
        'shouldCallProcessor': false,
        'shouldCallWrapper': false,
      },
      {
        'name': 'non-empty pattern',
        'pattern': <int>[1, 2, 3],
        'duration': const Duration(milliseconds: 50),
        'shouldCallProcessor': true,
        'shouldCallWrapper': true,
      },
    ];

    for (final testCase in testCases) {
      test('playHapticPattern - ${testCase['name']}', () async {
        final pattern = testCase['pattern'] as List<int>;
        final duration = testCase['duration'] as Duration;
        final shouldCallProcessor = testCase['shouldCallProcessor'] as bool;

        if (shouldCallProcessor) {
          final amplitudes = [10, 20];
          when(() => mockProcessor.processPcmData(pattern)).thenReturn(amplitudes);
          when(() => mockHapticsWrapper.playWaveform(any(), any())).thenAnswer((_) async => {});

          await defaultHapticService.playHapticPattern(pattern, duration);

          final expectedTimings = List<int>.filled(amplitudes.length, duration.inMilliseconds);
          verify(() => mockProcessor.processPcmData(pattern)).called(1);
          verify(() => mockHapticsWrapper.playWaveform([0, ...expectedTimings], [0, ...amplitudes])).called(1);
        } else {
          await defaultHapticService.playHapticPattern(pattern, duration);

          verifyNever(() => mockProcessor.processPcmData(any()));
          verifyNever(() => mockHapticsWrapper.playWaveform(any(), any()));
        }
      });
    }

    test('playHapticPattern handles exceptions from playWaveform gracefully', () async {
      final pattern = <int>[1, 2];
      final duration = const Duration(milliseconds: 50);
      final amplitudes = [10, 20];

      when(() => mockProcessor.processPcmData(pattern)).thenReturn(amplitudes);
      when(() => mockHapticsWrapper.playWaveform(any(), any())).thenThrow(Exception('Test error'));

      // Should not throw exception
      await defaultHapticService.playHapticPattern(pattern, duration);

      verify(() => mockProcessor.processPcmData(pattern)).called(1);
      verify(() => mockHapticsWrapper.playWaveform(any(), any())).called(1);
    });
  });

  group('stopHaptics', () {
    test('stopHaptics calls stop on hapticsWrapper', () async {
      when(() => mockHapticsWrapper.stop()).thenAnswer((_) async => {});

      await defaultHapticService.stopHaptics();

      verify(() => mockHapticsWrapper.stop()).called(1);
    });
  });
}