import 'package:flutter_test/flutter_test.dart';
import 'package:mp3_android_player/ui/player_screen_main.dart';

void main() {
  group('FormatDuration', () {
    final durationCases = <Map<String, Object>>[
      {'duration': Duration.zero, 'expected': '0:00'},
      {'duration': const Duration(seconds: 5), 'expected': '0:05'},
      {'duration': const Duration(seconds: 65), 'expected': '1:05'},
      {'duration': const Duration(seconds: 125), 'expected': '2:05'},
    ];

    for (final caseData in durationCases) {
      final expected = caseData['expected'];
      final duration = caseData['duration'];
      testWidgets('formatDuration returns "$expected" for $duration', (
        tester,
      ) async {
        expect(
          formatDuration(caseData['duration'] as Duration),
          caseData['expected'],
        );
      });
    }
  });
}
