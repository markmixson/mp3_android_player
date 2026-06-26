import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mp3_android_player/wrappers/advanced_haptics_wrapper.dart';

// coverage:ignore-file
class EnsureInitializedWrapper {
  static Future<void> ensureInitialized(final RootIsolateToken? rootToken, final AdvancedHapticsWrapper wrapper) async {
    if (rootToken == null) {
      debugPrint("can't get root token!");
    } else {
      BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);
      final hasSupport = await wrapper.hasCustomHapticsSupport();
      if (!hasSupport) {
        debugPrint("no custom haptics support!");
      }
    }
  }
}
