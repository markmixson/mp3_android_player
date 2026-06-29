import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class HapticAudioPipe {
  static const MethodChannel _channel = MethodChannel('com.haptics.audio_pipe');

  /// Initialize the AudioTrack and HapticGenerator on the native side.
  /// Call this before starting your FFmpeg stream.
  Future<void> init() async {
    try {
      await _channel.invokeMethod('initHaptics');
    } on PlatformException catch (e) {
      debugPrint("Failed to init haptics: '${e.message}'.");
    }
  }

  /// Pipe your chunked FFmpeg PCM output here.
  Future<void> writeBytes(Uint8List pcmBytes) async {
    try {
      await _channel.invokeMethod('writeBytes', {'bytes': pcmBytes});
    } catch (e) {
      debugPrint("Failed to write bytes: $e");
    }
  }

  /// Clean up native resources when playback stops.
  Future<void> dispose() async {
    await _channel.invokeMethod('release');
  }
}