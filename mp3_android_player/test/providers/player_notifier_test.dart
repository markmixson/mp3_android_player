import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mp3_android_player/models/audio_file.dart';
import 'package:mp3_android_player/models/haptic_mode.dart';
import 'package:mp3_android_player/models/player_state.dart';
import 'package:mp3_android_player/models/player_status.dart';
import 'package:mp3_android_player/providers.dart';
import 'package:mp3_android_player/providers/player_notifier.dart';
import 'package:mp3_android_player/services/audio_file_picker_service_interface.dart';
import 'package:mp3_android_player/services/audio_player_service_interface.dart';
import 'package:mp3_android_player/services/preference_service_interface.dart';

class MockAudioPlayerService extends Mock implements AudioPlayerService {}

class MockAudioFilePickerService extends Mock
    implements AudioFilePickerService {}

class MockPreferenceService extends Mock implements PreferenceService {}

void main() {
  late MockAudioPlayerService mockDefaultAudioPlayerService;
  late MockAudioFilePickerService mockAudioFilePickerService;
  late MockPreferenceService mockPreferenceService;
  late ProviderContainer container;
  late MockAudioPlayerService mockHapticAudioPlayerService;

  setUpAll(() {
    registerFallbackValue(
      AudioFile(path: '', name: '', duration: Duration.zero),
    );
    registerFallbackValue(HapticMode.disabled);
  });

  setUp(() {
    mockDefaultAudioPlayerService = MockAudioPlayerService();
    mockAudioFilePickerService = MockAudioFilePickerService();
    mockPreferenceService = MockPreferenceService();
    mockHapticAudioPlayerService = MockAudioPlayerService();

    // Setup default stream behaviors
    when(
      () => mockDefaultAudioPlayerService.positionStream,
    ).thenAnswer((_) => Stream.value(Duration.zero));
    when(
      () => mockDefaultAudioPlayerService.durationStream,
    ).thenAnswer((_) => Stream.value(Duration.zero));
    when(
      () => mockHapticAudioPlayerService.positionStream,
    ).thenAnswer((_) => Stream.value(Duration.zero));
    when(
      () => mockHapticAudioPlayerService.durationStream,
    ).thenAnswer((_) => Stream.value(Duration.zero));
    when(
      () => mockPreferenceService.getHapticMode(),
    ).thenReturn(HapticMode.disabled);
    when(
      () => mockPreferenceService.setHapticMode(any()),
    ).thenAnswer((_) async => {});
    when(
      () => mockDefaultAudioPlayerService.initialize(any()),
    ).thenAnswer((_) async => {});
    when(
      () => mockHapticAudioPlayerService.initialize(any(), any(), any()),
    ).thenAnswer((_) async => {});

    container = ProviderContainer(
      overrides: [
        defaultAudioPlayerServiceProvider.overrideWithValue(
          mockDefaultAudioPlayerService,
        ),
        audioFilePickerServiceProvider.overrideWithValue(
          mockAudioFilePickerService,
        ),
        hapticAudioPlayerServiceProvider.overrideWithValue(
          mockHapticAudioPlayerService,
        ),
        preferenceServiceProvider.overrideWith(
          (ref) async => mockPreferenceService,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('PlayerNotifier', () {
    final testFile = AudioFile(
      path: 'test.mp3',
      name: 'test.mp3',
      duration: Duration(minutes: 3),
    );

    test('initial state should be stopped', () {
      final state = container.read(playerNotifierProvider);
      expect(state.status, PlaybackStatus.stopped);
      expect(state.currentFile, isNull);
    });

    test('pickAndPlayFile should update state when file is picked', () async {
      when(
        () => mockAudioFilePickerService.pickFile(),
      ).thenAnswer((_) async => testFile);
      when(
        () => mockDefaultAudioPlayerService.play(any()),
      ).thenAnswer((_) async => {});
      final notifier = container.read(playerNotifierProvider.notifier);

      await notifier.pickAndPlayFile(mockPreferenceService);

      expect(notifier.state.currentFile, testFile);
      expect(notifier.state.status, PlaybackStatus.playing);
      verify(() => mockDefaultAudioPlayerService.play(testFile)).called(1);
      verify(() => mockHapticAudioPlayerService.initialize(testFile, any(), any())).called(1);
    });

    test('togglePlayPause should pause when playing', () async {
      when(
        () => mockDefaultAudioPlayerService.pause(),
      ).thenAnswer((_) async => {});
      container.read(playerNotifierProvider.notifier).state = PlayerState(
        currentFile: testFile,
        status: PlaybackStatus.playing,
      );

      await container.read(playerNotifierProvider.notifier).togglePlayPause();

      expect(
        container.read(playerNotifierProvider).status,
        PlaybackStatus.paused,
      );
      verify(() => mockDefaultAudioPlayerService.pause()).called(1);
    });

    test('togglePlayPause should play when paused', () async {
      when(() => mockDefaultAudioPlayerService.hasAudioSource).thenReturn(true);
      when(
        () => mockDefaultAudioPlayerService.resume(),
      ).thenAnswer((_) async => {});
      container.read(playerNotifierProvider.notifier).state = PlayerState(
        currentFile: testFile,
        status: PlaybackStatus.paused,
      );

      await container.read(playerNotifierProvider.notifier).togglePlayPause();

      expect(
        container.read(playerNotifierProvider).status,
        PlaybackStatus.playing,
      );
      verify(() => mockDefaultAudioPlayerService.resume()).called(1);
    });

    test(
      'resumeOrPlay should call play(currentFile) when hasAudioSource is false',
      () async {
        final audioFile = AudioFile(
          path: 'test.mp3',
          name: 'Test File',
          duration: Duration(minutes: 5),
        );
        final notifier = container.read(playerNotifierProvider.notifier);

        // Set the state to include a currentFile so the ! operator doesn't fail
        notifier.state = PlayerState(
          currentFile: audioFile,
          status: PlaybackStatus.stopped,
        );

        when(
          () => mockDefaultAudioPlayerService.hasAudioSource,
        ).thenReturn(false);
        when(
          () => mockDefaultAudioPlayerService.play(any()),
        ).thenAnswer((_) async => {});

        // Act
        await notifier.resumeOrPlay();

        verify(() => mockDefaultAudioPlayerService.play(audioFile)).called(1);
      },
    );

    test(
      'resumeOrPlay should call resume() when hasAudioSource is true',
      () async {
        when(
          () => mockDefaultAudioPlayerService.hasAudioSource,
        ).thenReturn(true);
        final notifier = container.read(playerNotifierProvider.notifier);

        await notifier.resumeOrPlay();

        verify(() => mockDefaultAudioPlayerService.resume()).called(1);
      },
    );
  });
}
