import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mp3_android_player/helpers/file_helper.dart';

void testParameterized(
  String description,
  void Function(String) testCase,
  List<String> parameters,
) {
  for (final parameter in parameters) {
    testCase(parameter);
  }
}

void main() {
  group('FileHelper', () {
    late FileHelper fileHelper;

    setUp(() {
      fileHelper = FileHelper();
    });

    group('getFile', () {
      testParameterized(
        'should return a File object for the given path',
        (String path) => test('returns File with path: $path', () {
          final file = fileHelper.getFile(path);
          expect(file, isA<File>());
          expect(file.path, equals(path));
        }),
        [
          'path/to/file.mp3',
          '/absolute/path/to/audio.wav',
          'relative_dir/file.txt',
          'file_with_spaces in name.mp3',
        ],
      );
    });
  });
}
