import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mp3_android_player/models/audio_file.dart';
import 'package:mp3_android_player/services/default_audio_player_service.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

class MockAudioSource extends Mock implements AudioSource {}

void main() {
  late DefaultAudioPlayerService audioPlayerService;
  late MockAudioPlayer mockAudioPlayer;
  late MockAudioSource mockAudioSource;
  final audioFile = AudioFile(
    path: 'test/path/to/audio.mp3',
    name: 'test.mp3',
    duration: const Duration(seconds: 10),
  );

  setUp(() {
    mockAudioPlayer = MockAudioPlayer();
    audioPlayerService = DefaultAudioPlayerService(player: mockAudioPlayer);
    mockAudioSource = MockAudioSource();

    registerFallbackValue(audioFile);
    registerFallbackValue(Duration.zero);
  });

  group('DefaultAudioPlayerService', () {
    test(
      'initialize calls setFilePath and not play on the underlying player',
      () async {
        when(() => mockAudioPlayer.setFilePath(any())).thenAnswer((_) async {
          return null;
        });
        audioPlayerService.initialize(audioFile);

        verify(() => mockAudioPlayer.setFilePath(audioFile.path)).called(1);
      },
    );

    test('pause calls pause on the underlying player', () async {
      when(() => mockAudioPlayer.pause()).thenAnswer((_) async => {});

      audioPlayerService.pause();

      verify(() => mockAudioPlayer.pause()).called(1);
    });

    test('resume calls play on the underlying player', () async {
      when(() => mockAudioPlayer.play()).thenAnswer((_) async {});

      audioPlayerService.resume();

      verify(() => mockAudioPlayer.play()).called(1);
    });

    test('seek calls seek on the underlying player', () async {
      const seekPosition = Duration(seconds: 5);
      when(() => mockAudioPlayer.seek(any())).thenAnswer((_) async => {});

      await audioPlayerService.seek(seekPosition);

      verify(() => mockAudioPlayer.seek(seekPosition)).called(1);
    });

    test('stop calls stop on the underlying player', () async {
      when(() => mockAudioPlayer.stop()).thenAnswer((_) async => {});

      audioPlayerService.stop();

      verify(() => mockAudioPlayer.stop()).called(1);
    });

    test('positionStream returns the underlying player position stream', () {
      final mockStream = Stream<Duration>.empty();
      when(
        () => mockAudioPlayer.positionStream,
      ).thenAnswer((_) => mockStream.cast<Duration>());

      final stream = audioPlayerService.positionStream;

      expect(stream, isA<Stream<Duration>>());
    });

    test('durationStream returns the underlying player duration stream', () {
      final mockStream = Stream<Duration>.empty();
      when(
        () => mockAudioPlayer.durationStream,
      ).thenAnswer((_) => mockStream.cast<Duration>());

      final stream = audioPlayerService.durationStream;

      expect(stream, isA<Stream<Duration>>());
    });

    test('play rethrows error when it fails', () async {
      when(() => mockAudioPlayer.play()).thenThrow(Exception('Failed'));

      expect(
        () => audioPlayerService.play(audioFile),
        throwsA(isA<Exception>()),
      );
    });

    test('dispose calls dispose on the underlying player', () {
      when(
        () => mockAudioPlayer.dispose(),
      ).thenAnswer((_) => Future<void>.value());

      audioPlayerService.dispose();

      verify(() => mockAudioPlayer.dispose()).called(1);
    });

    // Parameterized test cases to cover both branches of the boolean expression
    final testCases = [
      {
        'hasSource': true,
        'expected': true,
        'description': 'returns true when audioSource is not null',
      },
      {
        'hasSource': false,
        'expected': false,
        'description': 'returns false when audioSource is null',
      },
    ];

    for (var params in testCases) {
      final bool hasSource = params['hasSource'] as bool;
      final bool expectedResult = params['expected'] as bool;
      final String description = params['description'] as String;

      test(description, () {
        if (hasSource) {
          when(() => mockAudioPlayer.audioSource).thenReturn(mockAudioSource);
        } else {
          when(() => mockAudioPlayer.audioSource).thenReturn(null);
        }

        // Act
        final result = audioPlayerService.hasAudioSource;

        // Assert
        expect(result, equals(expectedResult));
      });
    }
  });
}
