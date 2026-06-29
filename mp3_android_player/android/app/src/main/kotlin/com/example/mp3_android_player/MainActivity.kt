package com.example.mp3_android_player

import android.media.audiofx.HapticGenerator
import android.os.Build
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.haptics.audio_pipe"
    private var hapticGenerator: HapticGenerator? = null
    private val TAG = "HapticAudioPipe"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "attachHaptics" -> {
                    val sessionId = call.argument<Int>("sessionId")
                    if (sessionId != null) {
                        attachHapticsToSession(sessionId)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGS", "Session ID cannot be null", null)
                    }
                }

                "release" -> {
                    releaseHaptics()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun attachHapticsToSession(sessionId: Int) {
        // HapticGenerator is only available on Android 12 (API 31) and higher
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (HapticGenerator.isAvailable()) {
                try {
                    // Clean up any existing generator before attaching a new one
                    releaseHaptics()

                    // Attach directly to just_audio's Exoplayer session
                    hapticGenerator = HapticGenerator.create(sessionId)
                    hapticGenerator?.enabled = true

                    Log.d(TAG, "Successfully attached HapticGenerator to session $sessionId")
                } catch (e: Exception) {
                    Log.e(TAG, "Failed to attach HapticGenerator: ${e.message}")
                }
            } else {
                Log.w(TAG, "HapticGenerator is not supported by this device's hardware.")
            }
        } else {
            Log.w(TAG, "HapticGenerator requires Android 12 (API 31) or higher.")
        }
    }

    private fun releaseHaptics() {
        hapticGenerator?.let {
            it.enabled = false
            it.release()
            Log.d(TAG, "HapticGenerator released")
        }
        hapticGenerator = null
    }
}
