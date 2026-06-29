package com.example.mp3_android_player

import android.media.audiofx.HapticGenerator
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.haptics.audio_pipe"
    private var hapticGenerator: HapticGenerator? = null

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
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && HapticGenerator.isAvailable()) {
            // Clean up any existing generator first
            releaseHaptics()
            
            // Attach directly to just_audio's session!
            hapticGenerator = HapticGenerator.create(sessionId)
            hapticGenerator?.enabled = true
        }
    }

    private fun releaseHaptics() {
        hapticGenerator?.release()
        hapticGenerator = null
    }
}
