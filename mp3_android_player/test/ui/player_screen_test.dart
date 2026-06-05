import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mp3_android_player/models/audio_file.dart';
import 'package:mp3_android_player/player_app.dart';
import 'package:mp3_android_player/providers.dart';
import 'package:mp3_android_player/services/audio_player_service_interface.dart';
import 'package:mp3_android_player/services/audio_file_picker_service_interface.dart';
import 'package:mp3_android_player/ui/player_screen.dart';

class MockAudioService extends Mock implements AudioPlayerService {}

class MockHapticAudioPlayerService extends Mock implements AudioPlayerService {}

class MockFilePickerService extends Mock implements AudioFilePickerService {}

late ProviderContainer container;

void main() {
  late MockAudioService audioService;
  late MockHapticAudioPlayerService hapticAudioService;
  late MockFilePickerService filePickerService;
  late StreamController<Duration> positionController;
  late StreamController<Duration> durationController;

  const audioFile = AudioFile(
    path: 'test/path/to/audio.mp3',
    name: 'test.mp3',
    duration: Duration(seconds: 10),
  );

  setUpAll(() {
    registerFallbackValue(audioFile);
    registerFallbackValue(Duration.zero);
  });

  tearDown(() {
    positionController.close();
    durationController.close();
  });

  setUp(() {
    audioService = MockAudioService();
    hapticAudioService = MockHapticAudioPlayerService();
    filePickerService = MockFilePickerService();
    positionController = StreamController<Duration>.broadcast();
    durationController = StreamController<Duration>.broadcast();

    when(
      () => audioService.positionStream,
    ).thenAnswer((_) => positionController.stream);
    when(
      () => audioService.durationStream,
    ).thenAnswer((_) => durationController.stream);
    when(() => audioService.pause()).thenReturn(null);
    when(() => audioService.resume()).thenReturn(null);
    when(() => audioService.seek(any())).thenAnswer((_) async {});
    when(() => hapticAudioService.seek(any())).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        defaultAudioPlayerServiceProvider.overrideWithValue(audioService),
        hapticAudioPlayerServiceProvider.overrideWithValue(hapticAudioService),
        audioFilePickerServiceProvider.overrideWithValue(filePickerService),
      ],
    );
    addTearDown(container.dispose);
  });

  Widget buildPlayerScreen() {
    return UncontrolledProviderScope(container: container, child: PlayerApp());
  }

  group('PlayerScreen', () {
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
        await tester.pumpWidget(buildPlayerScreen());

        expect(
          formatDuration(caseData['duration'] as Duration),
          caseData['expected'],
        );
      });
    }

    testWidgets(
      '''shows "No file selected" and play button does not resume or pause when 
      no file is loaded''',
      (tester) async {
        await tester.pumpWidget(buildPlayerScreen());

        expect(find.text('No file selected'), findsOneWidget);
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);

        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        expect(find.byIcon(Icons.pause), findsNothing);
        verifyNever(() => audioService.resume());
        verifyNever(() => audioService.pause());
        verifyNever(() => audioService.play(any()));
      },
    );

    testWidgets(
      '''selecting a file plays it, shows now playing text, pauses, then 
      resumes correctly''',
      (tester) async {
        when(
          () => filePickerService.pickFile(),
        ).thenAnswer((_) async => audioFile);
        when(() => audioService.play(any())).thenAnswer((_) async {});

        await tester.pumpWidget(buildPlayerScreen());

        await tester.tap(find.byIcon(Icons.file_present));
        await tester.pumpAndSettle();

        verify(() => filePickerService.pickFile()).called(1);
        verify(() => audioService.play(audioFile)).called(1);

        expect(find.text('Now Playing: ${audioFile.name}'), findsOneWidget);
        expect(find.byIcon(Icons.pause), findsOneWidget);

        await tester.tap(find.byIcon(Icons.pause));
        await tester.pump();

        verify(() => audioService.pause()).called(1);
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);

        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pump();

        verify(() => audioService.resume()).called(1);
        expect(find.byIcon(Icons.pause), findsOneWidget);
      },
    );

    testWidgets('haptic mode toggle switches between services', (
      tester,
    ) async {
      when(
        () => filePickerService.pickFile(),
      ).thenAnswer((_) async => audioFile);
      when(() => audioService.play(any())).thenAnswer((_) async {});
      when(() => hapticAudioService.play(any())).thenAnswer((_) async {});
      when(() => audioService.pause()).thenReturn(null);
      when(() => hapticAudioService.pause()).thenReturn(null);
      when(() => audioService.seek(any())).thenAnswer((_) async {});
      when(() => hapticAudioService.seek(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildPlayerScreen());
      await tester.tap(find.byIcon(Icons.file_present));
      await tester.pumpAndSettle();

      // Start with default (non-haptic)
      expect(find.text('Now Playing: ${audioFile.name}'), findsOneWidget);

      // Toggle Haptic Mode ON
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      verify(() => audioService.pause()).called(1);
      verify(() => audioService.seek(any())).called(1);

      // Toggle Haptic Mode OFF
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      verify(() => hapticAudioService.pause()).called(1);
      verify(() => hapticAudioService.seek(any())).called(1);
    });

    testWidgets('slider seek updates position stream and calls seek', (
      tester,
    ) async {
      when(
        () => filePickerService.pickFile(),
      ).thenAnswer((_) async => audioFile);
      when(() => audioService.play(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildPlayerScreen());
      await tester.tap(find.byIcon(Icons.file_present));
      await tester.pumpAndSettle();

      positionController.add(const Duration(seconds: 2));
      durationController.add(const Duration(seconds: 10));
      await tester.pumpAndSettle();

      expect(find.text('0:02'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);

      final slider = tester.widget<Slider>(find.byType(Slider));
      slider.onChanged?.call(5.0);
      await tester.pump();

      verify(() => audioService.seek(const Duration(seconds: 5))).called(1);
    });
  });
}
