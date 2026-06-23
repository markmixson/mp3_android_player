
import 'dart:io';
import 'package:path_provider/path_provider.dart' as p;

// coverage:ignore-file
class TemporaryDirectoryWrapper {
  Future<Directory> getTemporaryDirectory() {
    return p.getTemporaryDirectory();
  }
}