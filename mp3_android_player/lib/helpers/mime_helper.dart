import 'package:mime/mime.dart';

class MimeHelper {
  String getMimeType(final String path, final String defaultType) {
    return lookupMimeType(path) ?? defaultType;
  }
}
