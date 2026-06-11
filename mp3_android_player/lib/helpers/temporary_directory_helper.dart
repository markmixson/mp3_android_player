
import 'dart:io';
import 'package:path_provider/path_provider.dart' as p;

// coverage:ignore-file
class TemporaryDirectoryHelper {
  Future<Directory> getTemporaryDirectory() {
    return p.getTemporaryDirectory();
  }
}