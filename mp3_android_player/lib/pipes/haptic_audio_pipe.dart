import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

class HapticAudioPipe {
  static const MethodChannel _channel = MethodChannel('com.haptics.audio_pipe');
  final AudioPlayer _player;
  bool _isAttached = false; // Prevent attaching multiple times per track

  HapticAudioPipe(this._player) {
    // Listen to the player's state instead of just the session ID stream
    _player.playerStateStream.listen((state) async {
      // ONLY attach the haptics once ExoPlayer has fully built the track
      // and is ready to play (or is actively playing).
      if (state.processingState == ProcessingState.ready && !_isAttached) {
        
        final sessionId = _player.androidAudioSessionId;
        if (sessionId != null) {
          await _attachHaptics(sessionId);
          _isAttached = true;
        }
      }
      
      // Reset the flag if the player finishes or stops, 
      // in case you load a new song.
      if (state.processingState == ProcessingState.idle || 
          state.processingState == ProcessingState.completed) {
        _isAttached = false;
      }
    });
  }

  Future<void> _attachHaptics(int sessionId) async {
    try {
      await _channel.invokeMethod('attachHaptics', {'sessionId': sessionId});
      debugPrint('Haptics attached to session: $sessionId');
    } catch (e) {
      debugPrint("Failed to attach haptics: $e");
    }
  }

  Future<void> dispose() async {
    await _channel.invokeMethod('release');
  }
}