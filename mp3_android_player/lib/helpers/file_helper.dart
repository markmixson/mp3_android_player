import 'dart:async';
import 'dart:io';

class FileHelper {
  Future<File> getFileWhenPresent(final String processedPath) async {
    final file = File(processedPath);
    if (await file.exists()) {
      return file;
    }
    final directory = Directory(file.parent.path);
    final completer = Completer<File>();
    late StreamSubscription<FileSystemEvent> subscription;
    subscription = directory.watch().listen((event) {
      if (event is FileSystemCreateEvent && event.path == file.path) {
        subscription.cancel();
        completer.complete(file);
      }
    });
    return completer.future;
  }
}
