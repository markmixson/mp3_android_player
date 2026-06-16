import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mp3_android_player/models/haptic_mode.dart';
import 'package:mp3_android_player/services/default_preference_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('DefaultPreferenceService', () {
    late MockSharedPreferences mockSharedPreferences;
    late DefaultPreferenceService preferenceService;

    const String hapticModeKey = 'haptic_mode';

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      preferenceService = DefaultPreferenceService(mockSharedPreferences);
    });

    group('setHapticMode', () {
      final cases = [
        (
          description: 'sets HapticMode.enabled',
          mode: HapticMode.enabled,
          expectedName: 'enabled',
        ),
        (
          description: 'sets HapticMode.disabled',
          mode: HapticMode.disabled,
          expectedName: 'disabled',
        ),
      ];

      for (final c in cases) {
        test(c.description, () async {
          when(
            () =>
                mockSharedPreferences.setString(hapticModeKey, c.expectedName),
          ).thenAnswer((_) async => true);

          await preferenceService.setHapticMode(c.mode);

          verify(
            () =>
                mockSharedPreferences.setString(hapticModeKey, c.expectedName),
          ).called(1);
        });
      }
    });

    group('getHapticMode', () {
      final cases = [
        (
          description: 'returns HapticMode.enabled when mode name is "enabled"',
          input: 'enabled',
          expected: HapticMode.enabled,
        ),
        (
          description:
              'returns HapticMode.disabled when mode name is "disabled"',
          input: 'disabled',
          expected: HapticMode.disabled,
        ),
        (
          description: 'returns HapticMode.disabled when mode name is invalid',
          input: 'invalid_mode',
          expected: HapticMode.disabled,
        ),
        (
          description: 'returns HapticMode.disabled when mode name is null',
          input: null,
          expected: HapticMode.disabled,
        ),
      ];

      for (final c in cases) {
        test(c.description, () async {
          when(
            () => mockSharedPreferences.getString(hapticModeKey),
          ).thenReturn(c.input);

          final result = preferenceService.getHapticMode();

          expect(result, c.expected);
        });
      }
    });
  });
}
