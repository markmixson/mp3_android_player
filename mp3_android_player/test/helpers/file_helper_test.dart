import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mp3_android_player/helpers/file_helper.dart';

void main() {
  group('FileHelper.getFileWhenPresent', () {
    late FileHelper fileHelper;
    late Directory tempDir;

    setUp(() async {
      fileHelper = FileHelper();
      tempDir = await Directory.systemTemp.createTemp();
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('returns the file if it already exists', () async {
      final file = File('${tempDir.path}/exists.txt');
      await file.create();

      final result = await fileHelper.getFileWhenUpdated(file.path);

      expect(result.toString(), equals(file.toString()));
      expect(await result.exists(), isTrue);
    });

    test('returns the file when it is created in the directory', () async {
      final file = File('${tempDir.path}/new_file.txt');
      await file.create();
      final targetPath = file.path;

      final future = fileHelper.getFileWhenUpdated(targetPath);
      await file.create();

      final result = await future;
      expect(result.toString(), equals(file.toString()));
      expect(await result.exists(), isTrue);
    });

    test('does not complete if a different file is created', () async {
      final targetPath = '${tempDir.path}/target.txt';
      final otherFile = File('${tempDir.path}/other.txt');

      final future = fileHelper.getFileWhenUpdated(targetPath);

      await otherFile.create();

      // Expect the future NOT to complete. Use a timeout to avoid hanging.
      expect(
        future.timeout(const Duration(milliseconds: 200)),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('file is updated after a delay', () async {
      final path = '${tempDir.path}/mod_test_1.txt';
      final file = File(path);

      final future = FileHelper().getFileWhenUpdated(path);

      await Future.delayed(Duration(milliseconds: 500)).then((onValue) async {
        await file.create();
        await file.writeAsString("hello");
      });

      final result1 = await future;
      expect(result1.toString(), file.toString());
    });
  });
}
