import 'package:flutter_test/flutter_test.dart';
import 'package:mp3_android_player/helpers/mime_helper.dart';

void main() {
  group('MimeHelper', () {
    late MimeHelper mimeHelper;

    setUp(() {
      mimeHelper = MimeHelper();
    });

    group('getMimeType', () {
      final testCases = [
        // 1. Success: Valid extension
        ('test.mp3', 'application/octet-stream', 'audio/mpeg'),
        // 2. Success: Different valid extension
        ('image.png', 'text/plain', 'image/png'),
        // 3. Branch: lookupMimeType returns null (use default)
        (
          'file_without_extension',
          'application/octet-stream',
          'application/octet-stream',
        ),
        // 4. Branch: lookupMimeType returns null (use custom default)
        ('unknown_file', 'audio/mp3', 'audio/mp3'),
        // 5. Edge Case: Empty path
        ('', 'application/octet-stream', 'application/octet-stream'),
      ];

      for (final (String path, String defaultType, String expected)
          in testCases) {
        test(
          'path: "$path", default: "$defaultType" should return "$expected"',
          () {
            final result = mimeHelper.getMimeType(path, defaultType);
            expect(result, equals(expected));
          },
        );
      }
    });
  });
}
