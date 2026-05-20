// ignore: implementation_imports
import 'package:file_picker/src/platform/file_picker_platform_interface.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mp3_android_player/models/audio_file.dart';
import 'package:mp3_android_player/services/default_audio_file_picker_service.dart';

class MockFilePicker extends Mock implements FilePickerPlatform {}

class MockFilePickerResult extends Mock implements FilePickerResult {
  @override
  late List<PlatformFile> files;
}

class MockPlatformFile extends Mock implements PlatformFile {}

void main() {
  late DefaultAudioFilePickerService filePickerService;
  late MockFilePicker mockFilePicker;

  setUpAll(() {
    registerFallbackValue(FileType.any);
  });

  setUp(() {
    mockFilePicker = MockFilePicker();
    filePickerService = DefaultAudioFilePickerService(
      filePicker: mockFilePicker,
    );
  });

  group('DefaultAudioFilePickerService', () {
    test('pickFile returns an AudioFile when a file is selected', () async {
      final mockFile = MockPlatformFile();
      when(() => mockFile.path).thenReturn('/path/to/audio.mp3');
      when(() => mockFile.name).thenReturn('audio.mp3');

      final mockResult = MockFilePickerResult();
      mockResult.files = [mockFile];

      when(
        () => mockFilePicker.pickFiles(
          type: any(named: 'type'),
          allowMultiple: any(named: 'allowMultiple'),
        ),
      ).thenAnswer((_) async => mockResult);

      final result = await filePickerService.pickFile();

      expect(result, isA<AudioFile>());
      expect(result?.path, '/path/to/audio.mp3');
      expect(result?.name, 'audio.mp3');
    });

    test('pickFile returns null when no file is selected', () async {
      when(
        () => mockFilePicker.pickFiles(
          type: any(named: 'type'),
          allowMultiple: any(named: 'allowMultiple'),
        ),
      ).thenAnswer((_) async => null);

      final result = await filePickerService.pickFile();

      expect(result, isNull);
    });

    test('pickFile handles errors gracefully', () async {
      when(
        () => mockFilePicker.pickFiles(
          type: any(named: 'type'),
          allowMultiple: any(named: 'allowMultiple'),
        ),
      ).thenThrow(Exception('Picker error'));

      final result = await filePickerService.pickFile();

      expect(result, isNull);
    });
  });
}
