import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mp3_android_player/models/audio_file.dart';
import 'package:mp3_android_player/models/haptic_mode.dart';
import 'package:mp3_android_player/models/player_state.dart';
import 'package:mp3_android_player/models/player_status.dart';
import 'package:mp3_android_player/player_app.dart';
import 'package:mp3_android_player/providers.dart';
import 'package:mp3_android_player/providers/player_notifier.dart';
import 'package:mp3_android_player/services/audio_player_service_interface.dart';
import 'package:mp3_android_player/services/audio_file_picker_service_interface.dart';
import 'package:mp3_android_player/services/preference_service_interface.dart';
import 'package:mp3_android_player/sources/haptic_stream_audio_source.dart';

class MockAudioService extends Mock implements AudioPlayerService {}

class MockHapticAudioPlayerService extends Mock implements AudioPlayerService {}

class MockFilePickerService extends Mock implements AudioFilePickerService {}

class MockPreferenceService extends Mock implements PreferenceService {}

class MockHapticStreamAudioSource extends Mock
    implements HapticStreamAudioSource {}

late ProviderContainer container;

void main() {
  late MockAudioService audioService;
  late MockHapticAudioPlayerService hapticAudioService;
  late MockFilePickerService filePickerService;
  late StreamController<Duration> defaultPositionController;
  late StreamController<Duration> defaultDurationController;
  late StreamController<Duration> hapticPositionController;
  late StreamController<Duration> hapticDurationController;
  late MockPreferenceService preferenceService;
  late MockHapticStreamAudioSource hapticStreamAudioSource;

  const audioFile = AudioFile(
    path: 'test/path/to/audio.mp3',
    name: 'test.mp3',
    duration: Duration(seconds: 10),
  );

  setUpAll(() {
    registerFallbackValue(audioFile);
    registerFallbackValue(Duration.zero);
    registerFallbackValue(HapticMode.disabled);
  });

  tearDown(() {
    defaultPositionController.close();
    defaultDurationController.close();

    hapticPositionController.close();
    hapticDurationController.close();
  });

  setUp(() {
    audioService = MockAudioService();
    hapticAudioService = MockHapticAudioPlayerService();
    filePickerService = MockFilePickerService();
    defaultPositionController = StreamController<Duration>.broadcast();
    defaultDurationController = StreamController<Duration>.broadcast();
    hapticPositionController = StreamController<Duration>.broadcast();
    hapticDurationController = StreamController<Duration>.broadcast();
    preferenceService = MockPreferenceService();
    hapticStreamAudioSource = MockHapticStreamAudioSource();

    when(
      () => audioService.positionStream,
    ).thenAnswer((_) => defaultPositionController.stream);
    when(
      () => audioService.durationStream,
    ).thenAnswer((_) => defaultDurationController.stream);
    when(
      () => hapticAudioService.positionStream,
    ).thenAnswer((_) => hapticPositionController.stream);
    when(
      () => hapticAudioService.durationStream,
    ).thenAnswer((_) => hapticDurationController.stream);

    when(() => audioService.pause()).thenAnswer((_) async => {});
    when(() => audioService.resume()).thenAnswer((_) async => {});
    when(() => audioService.play(any())).thenAnswer((_) async => {});
    when(() => audioService.seek(any())).thenAnswer((_) async => {});
    when(() => audioService.initialize(any())).thenAnswer((_) async {});

    when(() => hapticAudioService.pause()).thenAnswer((_) async => {});
    when(() => hapticAudioService.resume()).thenAnswer((_) async => {});
    when(() => hapticAudioService.play(any())).thenAnswer((_) async => {});
    when(() => hapticAudioService.seek(any())).thenAnswer((_) async {});
    
    when(
      () => hapticAudioService.initialize(any(), any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => hapticAudioService.audioSource,
    ).thenReturn(hapticStreamAudioSource);

    when(() => hapticStreamAudioSource.go()).thenAnswer((_) async {});
    when(() => hapticStreamAudioSource.setHapticMode(any())).thenAnswer((_) async {});

    when(() => audioService.hasAudioSource).thenReturn(true);
    when(() => hapticAudioService.hasAudioSource).thenReturn(true);
    when(() => filePickerService.pickFile()).thenAnswer((_) async => audioFile);
    when(
      () => preferenceService.getHapticMode(),
    ).thenReturn(HapticMode.disabled);
    when(
      () => preferenceService.setHapticMode(any()),
    ).thenAnswer((_) async => {});

    container = ProviderContainer(
      overrides: [
        defaultAudioPlayerServiceProvider.overrideWithValue(audioService),
        hapticAudioPlayerServiceProvider.overrideWithValue(hapticAudioService),
        audioFilePickerServiceProvider.overrideWithValue(filePickerService),
        preferenceServiceProvider.overrideWith((ref) {
          return preferenceService;
        }),
      ],
    );
    addTearDown(container.dispose);
  });

  Widget buildPlayerScreen() {
    return UncontrolledProviderScope(container: container, child: PlayerApp());
  }

  group('PlayerScreen', () {
    testWidgets(
      '''shows "No file selected" and play button does not resume or pause when 
      no file is loaded''',
      (tester) async {
        await tester.pumpWidget(buildPlayerScreen());
        await tester.pumpAndSettle();

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

    testWidgets('''error loading preferences''', (tester) async {
      container = ProviderContainer(
        overrides: [
          defaultAudioPlayerServiceProvider.overrideWithValue(audioService),
          hapticAudioPlayerServiceProvider.overrideWithValue(
            hapticAudioService,
          ),
          audioFilePickerServiceProvider.overrideWithValue(filePickerService),
          preferenceServiceProvider.overrideWith((ref) {
            throw Exception();
          }),
        ],
      );
      await tester.pumpWidget(buildPlayerScreen());
      await tester.pumpAndSettle();

      expect(
        find.textContaining("Can't load preferences!  Error"),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.play_arrow), findsNothing);
    });

    testWidgets('''no preferences returned''', (tester) async {
      container = ProviderContainer(
        overrides: [
          defaultAudioPlayerServiceProvider.overrideWithValue(audioService),
          hapticAudioPlayerServiceProvider.overrideWithValue(
            hapticAudioService,
          ),
          audioFilePickerServiceProvider.overrideWithValue(filePickerService),
          preferenceServiceProvider.overrideWith((ref) {
            return null;
          }),
        ],
      );
      await tester.pumpWidget(buildPlayerScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining("Can't load preferences!"), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsNothing);
    });

    testWidgets(
      '''selecting a file plays it, shows now playing text, pauses, then 
      resumes correctly''',
      (tester) async {
        when(
          () => filePickerService.pickFile(),
        ).thenAnswer((_) async => audioFile);
        when(() => audioService.play(any())).thenAnswer((_) async {});
        when(() => audioService.hasAudioSource).thenReturn(true);
        when(() => audioService.resume()).thenAnswer((_) async {});

        await tester.pumpWidget(buildPlayerScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.file_present));
        await tester.pumpAndSettle();

        verify(() => filePickerService.pickFile()).called(1);
        verify(() => audioService.play(audioFile)).called(1);

        expect(find.text('Now Playing: ${audioFile.name}'), findsOneWidget);
        expect(find.byIcon(Icons.pause), findsOneWidget);

        await tester.tap(find.byIcon(Icons.pause));
        await tester.pumpAndSettle();

        verify(() => audioService.pause()).called(1);
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);

        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pumpAndSettle();

        verify(() => audioService.resume()).called(1);
        expect(find.byIcon(Icons.pause), findsOneWidget);
      },
    );

    testWidgets('haptic mode toggle switches between services', (tester) async {
      await tester.pumpWidget(buildPlayerScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.file_present));
      await tester.pumpAndSettle();

      container.read(playerNotifierProvider.notifier).state = PlayerState(
        currentFile: audioFile,
        status: PlaybackStatus.playing,
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      verify(() => audioService.pause()).called(1);
      verify(
        () => hapticStreamAudioSource.setHapticMode(HapticMode.enabled),
      ).called(1);

      await tester.pumpAndSettle();

      when(
        () => preferenceService.getHapticMode(),
      ).thenReturn(HapticMode.enabled);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      verify(() => hapticAudioService.pause()).called(1);
      verify(
        () => hapticStreamAudioSource.setHapticMode(HapticMode.disabled),
      ).called(1);
    });

    testWidgets('slider seek updates position stream and calls seek', (
      tester,
    ) async {
      await tester.pumpWidget(buildPlayerScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.file_present));
      await tester.pumpAndSettle();

      defaultPositionController.add(const Duration(seconds: 2));
      defaultDurationController.add(const Duration(seconds: 10));
      await tester.pumpAndSettle();

      expect(find.text('0:02'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);

      final slider = tester.widget<Slider>(find.byType(Slider));
      slider.onChanged?.call(5.0);
      await tester.pump();

      verify(() => audioService.seek(const Duration(seconds: 5))).called(1);
    });
  });

  for (final (bool isLoading, AudioFile? currentFile, String expectedText) in [
    (true, null, 'Loading...'),
    (true, audioFile, 'Loading test.mp3...'),
  ]) {
    testWidgets(
      'shows loading indicator and "$expectedText" when isLoading=$isLoading and currentFile=${currentFile != null}',
      (tester) async {
        container.read(playerNotifierProvider.notifier).state = PlayerState(
          isLoading: isLoading,
          currentFile: currentFile,
          status: PlaybackStatus.stopped,
        );
        await tester.pumpWidget(buildPlayerScreen());
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text(expectedText), findsOneWidget);
      },
    );
  }
}
