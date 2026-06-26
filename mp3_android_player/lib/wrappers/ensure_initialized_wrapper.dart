import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// coverage:ignore-file
class EnsureInitializedWrapper {
  static void ensureInitialized(final RootIsolateToken? rootToken) {
    if (rootToken == null) {
      debugPrint("can't get root token!");
    } else {
      BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);
    }
  }
}
