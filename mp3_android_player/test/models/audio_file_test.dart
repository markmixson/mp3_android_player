import 'package:flutter_test/flutter_test.dart';
import 'package:mp3_android_player/models/audio_file.dart';

void main() {
  group('AudioFile', () {
    const testAudioFile = AudioFile(
      path: '/test/path/song.mp3',
      name: 'song.mp3',
      duration: Duration(seconds: 180),
    );

    group('constructor', () {
      final constructorCases = <Map<String, dynamic>>[
        {
          'path': '/test/path/song.mp3',
          'name': 'song.mp3',
          'duration': const Duration(seconds: 180),
          'description': 'creates AudioFile with standard values',
        },
        {
          'path': '/another/path/music.m4a',
          'name': 'music.m4a',
          'duration': const Duration(minutes: 5),
          'description': 'creates AudioFile with different file type',
        },
        {
          'path': '',
          'name': '',
          'duration': Duration.zero,
          'description':
              'creates AudioFile with empty strings and zero duration',
        },
        {
          'path': 'relative/path/file.wav',
          'name': 'file.wav',
          'duration': const Duration(hours: 1),
          'description':
              'creates AudioFile with relative path and long duration',
        },
      ];

      for (final testCase in constructorCases) {
        test('${testCase['description']}', () {
          final audioFile = AudioFile(
            path: testCase['path'] as String,
            name: testCase['name'] as String,
            duration: testCase['duration'] as Duration,
          );

          expect(audioFile.path, testCase['path']);
          expect(audioFile.name, testCase['name']);
          expect(audioFile.duration, testCase['duration']);
        });
      }
    });

    group('equality operator (==)', () {
      final equalityCases = <Map<String, dynamic>>[
        {
          'description': 'same object is equal',
          'audioFile1': testAudioFile,
          'audioFile2': testAudioFile,
          'shouldBeEqual': true,
          'identicalCheck': true,
        },
        {
          'description': 'different objects with identical values are equal',
          'audioFile1': const AudioFile(
            path: '/test/path/song.mp3',
            name: 'song.mp3',
            duration: Duration(seconds: 180),
          ),
          'audioFile2': const AudioFile(
            path: '/test/path/song.mp3',
            name: 'song.mp3',
            duration: Duration(seconds: 180),
          ),
          'shouldBeEqual': true,
          'identicalCheck': false,
        },
        {
          'description': 'objects with different paths are not equal',
          'audioFile1': const AudioFile(
            path: '/path1/song.mp3',
            name: 'song.mp3',
            duration: Duration(seconds: 180),
          ),
          'audioFile2': const AudioFile(
            path: '/path2/song.mp3',
            name: 'song.mp3',
            duration: Duration(seconds: 180),
          ),
          'shouldBeEqual': false,
          'identicalCheck': false,
        },
        {
          'description': 'objects with different names are not equal',
          'audioFile1': const AudioFile(
            path: '/test/path/song.mp3',
            name: 'song1.mp3',
            duration: Duration(seconds: 180),
          ),
          'audioFile2': const AudioFile(
            path: '/test/path/song.mp3',
            name: 'song2.mp3',
            duration: Duration(seconds: 180),
          ),
          'shouldBeEqual': false,
          'identicalCheck': false,
        },
        {
          'description': 'objects with different durations are not equal',
          'audioFile1': const AudioFile(
            path: '/test/path/song.mp3',
            name: 'song.mp3',
            duration: Duration(seconds: 180),
          ),
          'audioFile2': const AudioFile(
            path: '/test/path/song.mp3',
            name: 'song.mp3',
            duration: Duration(seconds: 200),
          ),
          'shouldBeEqual': false,
          'identicalCheck': false,
        },
        {
          'description': 'objects with all fields different are not equal',
          'audioFile1': const AudioFile(
            path: '/path1/file1.mp3',
            name: 'file1.mp3',
            duration: Duration(seconds: 100),
          ),
          'audioFile2': const AudioFile(
            path: '/path2/file2.mp3',
            name: 'file2.mp3',
            duration: Duration(seconds: 200),
          ),
          'shouldBeEqual': false,
          'identicalCheck': false,
        },
      ];

      for (final testCase in equalityCases) {
        test('${testCase['description']}', () {
          final result = testCase['audioFile1'] == testCase['audioFile2'];
          expect(result, testCase['shouldBeEqual']);
        });
      }

      test('AudioFile is not equal to null', () {
        // ignore: unnecessary_null_comparison
        expect(testAudioFile == null, false);
      });

      test('AudioFile is not equal to objects of different types', () {
        // ignore: unrelated_type_equality_checks
        expect(testAudioFile == 'not an AudioFile', false);
        // ignore: unrelated_type_equality_checks
        expect(testAudioFile == 123, false);
        // ignore: unrelated_type_equality_checks
        expect(testAudioFile == {'path': '/test/path/song.mp3'}, false);
      });
    });

    group('hashCode', () {
      final hashCodeCases = <Map<String, dynamic>>[
        {
          'description': 'equal objects produce the same hash code',
          'audioFile1': const AudioFile(
            path: '/test/path/song.mp3',
            name: 'song.mp3',
            duration: Duration(seconds: 180),
          ),
          'audioFile2': const AudioFile(
            path: '/test/path/song.mp3',
            name: 'song.mp3',
            duration: Duration(seconds: 180),
          ),
          'shouldHaveSameHash': true,
        },
        {
          'description':
              'objects with different paths produce different hash codes',
          'audioFile1': const AudioFile(
            path: '/path1/song.mp3',
            name: 'song.mp3',
            duration: Duration(seconds: 180),
          ),
          'audioFile2': const AudioFile(
            path: '/path2/song.mp3',
            name: 'song.mp3',
            duration: Duration(seconds: 180),
          ),
          'shouldHaveSameHash': false,
        },
        {
          'description':
              'objects with different names produce different hash codes',
          'audioFile1': const AudioFile(
            path: '/test/path/song.mp3',
            name: 'song1.mp3',
            duration: Duration(seconds: 180),
          ),
          'audioFile2': const AudioFile(
            path: '/test/path/song.mp3',
            name: 'song2.mp3',
            duration: Duration(seconds: 180),
          ),
          'shouldHaveSameHash': false,
        },
        {
          'description':
              'objects with different durations produce different hash codes',
          'audioFile1': const AudioFile(
            path: '/test/path/song.mp3',
            name: 'song.mp3',
            duration: Duration(seconds: 180),
          ),
          'audioFile2': const AudioFile(
            path: '/test/path/song.mp3',
            name: 'song.mp3',
            duration: Duration(seconds: 200),
          ),
          'shouldHaveSameHash': false,
        },
      ];

      for (final testCase in hashCodeCases) {
        test('${testCase['description']}', () {
          final hash1 = testCase['audioFile1'].hashCode;
          final hash2 = testCase['audioFile2'].hashCode;

          if (testCase['shouldHaveSameHash'] as bool) {
            expect(hash1, hash2);
          } else {
            expect(hash1, isNot(hash2));
          }
        });
      }

      test('hashCode is consistent across multiple calls', () {
        final hash1 = testAudioFile.hashCode;
        final hash2 = testAudioFile.hashCode;
        expect(hash1, hash2);
      });

      test('hashCode can be used in hash-based collections', () {
        const audioFile1 = AudioFile(
          path: '/test/path/song.mp3',
          name: 'song.mp3',
          duration: Duration(seconds: 180),
        );
        const audioFile2 = AudioFile(
          path: '/test/path/song.mp3',
          name: 'song.mp3',
          duration: Duration(seconds: 180),
        );
        const audioFile3 = AudioFile(
          path: '/different/path/song.mp3',
          name: 'song.mp3',
          duration: Duration(seconds: 180),
        );

        // ignore: equal_elements_in_set
        final set = {audioFile1, audioFile2, audioFile3};
        expect(set.length, 2);
      });
    });

    group('toString', () {
      final toStringCases = <Map<String, dynamic>>[
        {
          'audioFile': const AudioFile(
            path: '/test/path/song.mp3',
            name: 'song.mp3',
            duration: Duration(seconds: 180),
          ),
          'description': 'returns correct string for standard audio file',
          'checks': {
            'contains_class_name': 'AudioFile',
            'contains_path': '/test/path/song.mp3',
            'contains_name': 'song.mp3',
            'contains_duration': '0:03:00',
          },
        },
        {
          'audioFile': const AudioFile(
            path: '/another/path/music.wav',
            name: 'music.wav',
            duration: Duration(minutes: 5),
          ),
          'description':
              'returns correct string for audio file with different duration',
          'checks': {
            'contains_class_name': 'AudioFile',
            'contains_path': '/another/path/music.wav',
            'contains_name': 'music.wav',
            'contains_duration': '0:05:00',
          },
        },
        {
          'audioFile': const AudioFile(
            path: '',
            name: '',
            duration: Duration.zero,
          ),
          'description': 'returns correct string for empty audio file',
          'checks': {
            'contains_class_name': 'AudioFile',
            'contains_path': 'path: ,',
            'contains_name': 'name: ,',
            'contains_duration': '0:00:00',
          },
        },
      ];

      for (final testCase in toStringCases) {
        test('${testCase['description']}', () {
          final result = (testCase['audioFile'] as AudioFile).toString();
          final checks = testCase['checks'] as Map<String, String>;

          for (final entry in checks.entries) {
            expect(
              result,
              contains(entry.value),
              reason: 'toString should contain ${entry.key}: ${entry.value}',
            );
          }
        });
      }

      test('toString is not empty', () {
        expect(testAudioFile.toString().isNotEmpty, true);
      });

      test('toString includes all required fields', () {
        final result = testAudioFile.toString();
        expect(result, contains('AudioFile'));
        expect(result, contains('path'));
        expect(result, contains('name'));
        expect(result, contains('duration'));
      });
    });

    group('immutability', () {
      test('AudioFile fields are final and cannot be modified', () {
        const audioFile = AudioFile(
          path: '/test/path/song.mp3',
          name: 'song.mp3',
          duration: Duration(seconds: 180),
        );

        expect(() => audioFile.path, returnsNormally);
        expect(() => audioFile.name, returnsNormally);
        expect(() => audioFile.duration, returnsNormally);

        final retrievedPath = audioFile.path;
        final retrievedName = audioFile.name;
        final retrievedDuration = audioFile.duration;

        expect(retrievedPath, '/test/path/song.mp3');
        expect(retrievedName, 'song.mp3');
        expect(retrievedDuration, const Duration(seconds: 180));
      });
    });
  });
}
