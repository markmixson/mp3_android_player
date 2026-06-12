import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mp3_android_player/models/audio_file.dart';
import 'package:mp3_android_player/providers.dart';
import 'package:mp3_android_player/providers/player_notifier.dart';
import 'package:mp3_android_player/services/audio_file_picker_service_interface.dart';
import 'package:mp3_android_player/services/audio_player_service_interface.dart';

class MockAudioPlayerService extends Mock implements AudioPlayerService {}

class MockAudioFilePickerService extends Mock
    implements AudioFilePickerService {}

void main() {
  late MockAudioPlayerService mockAudioPlayerService;
  late MockAudioFilePickerService mockAudioFilePickerService;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      AudioFile(path: '', name: '', duration: Duration.zero),
    );
  });

  setUp(() {
    mockAudioPlayerService = MockAudioPlayerService();
    mockAudioFilePickerService = MockAudioFilePickerService();
    final mockHapticAudioPlayerService = MockAudioPlayerService();

    // Setup default stream behaviors
    when(
      () => mockAudioPlayerService.positionStream,
    ).thenAnswer((_) => Stream.value(Duration.zero));
    when(
      () => mockAudioPlayerService.durationStream,
    ).thenAnswer((_) => Stream.value(Duration.zero));
    when(
      () => mockHapticAudioPlayerService.positionStream,
    ).thenAnswer((_) => Stream.value(Duration.zero));
    when(
      () => mockHapticAudioPlayerService.durationStream,
    ).thenAnswer((_) => Stream.value(Duration.zero));

    container = ProviderContainer(
      overrides: [
        defaultAudioPlayerServiceProvider.overrideWithValue(
          mockAudioPlayerService,
        ),
        audioFilePickerServiceProvider.overrideWithValue(
          mockAudioFilePickerService,
        ),
        hapticAudioPlayerServiceProvider.overrideWithValue(
          mockHapticAudioPlayerService,
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
      final state = container.read(playerNotifierProvider).requireValue;
      expect(state.status, PlaybackStatus.stopped);
      expect(state.currentFile, isNull);
    });

    test('pickAndPlayFile should update state when file is picked', () async {
      when(
        () => mockAudioFilePickerService.pickFile(),
      ).thenAnswer((_) async => testFile);
      when(
        () => mockAudioPlayerService.play(any()),
      ).thenAnswer((_) async => {});

      final notifier = container.read(playerNotifierProvider.notifier);
      await notifier.pickAndPlayFile();

      expect(notifier.state.requireValue.currentFile, testFile);
      expect(notifier.state.requireValue.status, PlaybackStatus.playing);
      verify(() => mockAudioPlayerService.play(testFile)).called(1);
    });

    test('togglePlayPause should pause when playing', () async {
      when(() => mockAudioPlayerService.pause()).thenAnswer((_) async => {});
      container.read(playerNotifierProvider.notifier).state = AsyncValue.data(PlayerState(
        currentFile: testFile,
        status: PlaybackStatus.playing,
      ));

      await container.read(playerNotifierProvider.notifier).togglePlayPause();

      expect(
        container.read(playerNotifierProvider).requireValue.status,
        PlaybackStatus.paused,
      );
      verify(() => mockAudioPlayerService.pause()).called(1);
    });

    test('togglePlayPause should play when paused', () async {
      when(() => mockAudioPlayerService.hasAudioSource).thenReturn(true);
      when(() => mockAudioPlayerService.resume()).thenAnswer((_) async => {});
      container.read(playerNotifierProvider.notifier).state = AsyncValue.data(PlayerState(
        currentFile: testFile,
        status: PlaybackStatus.paused,
      ));

      await container.read(playerNotifierProvider.notifier).togglePlayPause();

      expect(
        container.read(playerNotifierProvider).requireValue.status,
        PlaybackStatus.playing,
      );
      verify(() => mockAudioPlayerService.resume()).called(1);
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
        notifier.state = AsyncValue.data(PlayerState(
          currentFile: audioFile,
          status: PlaybackStatus.stopped,
        ));

        when(() => mockAudioPlayerService.hasAudioSource).thenReturn(false);
        when(
          () => mockAudioPlayerService.play(any()),
        ).thenAnswer((_) async => {});

        // Act
        await notifier.resumeOrPlay();

        verify(() => mockAudioPlayerService.play(audioFile)).called(1);
      },
    );

    test(
      'resumeOrPlay should call resume() when hasAudioSource is true',
      () async {
        when(() => mockAudioPlayerService.hasAudioSource).thenReturn(true);
        final notifier = container.read(playerNotifierProvider.notifier);

        await notifier.resumeOrPlay();

        verify(() => mockAudioPlayerService.resume()).called(1);
      },
    );
  });
}
