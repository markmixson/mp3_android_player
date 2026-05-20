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

    // Setup default stream behaviors
    when(
      () => mockAudioPlayerService.positionStream,
    ).thenAnswer((_) => Stream.value(Duration.zero));
    when(
      () => mockAudioPlayerService.durationStream,
    ).thenAnswer((_) => Stream.value(Duration.zero));

    container = ProviderContainer(
      overrides: [
        audioPlayerServiceProvider.overrideWithValue(mockAudioPlayerService),
        audioFilePickerServiceProvider.overrideWithValue(
          mockAudioFilePickerService,
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
        () => mockAudioPlayerService.play(any()),
      ).thenAnswer((_) async => {});

      final notifier = container.read(playerNotifierProvider.notifier);
      await notifier.pickAndPlayFile();

      expect(notifier.state.currentFile, testFile);
      expect(notifier.state.status, PlaybackStatus.playing);
      verify(() => mockAudioPlayerService.play(testFile)).called(1);
    });

    test('togglePlayPause should pause when playing', () async {
      // Arrange
      when(() => mockAudioPlayerService.pause()).thenAnswer((_) async => {});
      // Set initial state to playing
      container.read(playerNotifierProvider.notifier).state = PlayerState(
        currentFile: testFile,
        status: PlaybackStatus.playing,
      );

      // Act
      await container.read(playerNotifierProvider.notifier).togglePlayPause();

      // Assert
      expect(
        container.read(playerNotifierProvider).status,
        PlaybackStatus.paused,
      );
      verify(() => mockAudioPlayerService.pause()).called(1);
    });

    test('togglePlayPause should play when paused', () async {
      // Arrange
      when(
        () => mockAudioPlayerService.play(any()),
      ).thenAnswer((_) async => {});
      container.read(playerNotifierProvider.notifier).state = PlayerState(
        currentFile: testFile,
        status: PlaybackStatus.paused,
      );

      // Act
      await container.read(playerNotifierProvider.notifier).togglePlayPause();

      // Assert
      expect(
        container.read(playerNotifierProvider).status,
        PlaybackStatus.playing,
      );
      verify(() => mockAudioPlayerService.resume()).called(1);
    });
  });
}
