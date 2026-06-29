package com.example.mp3_android_player

import android.media.audiofx.HapticGenerator
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
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

            val sampleRate = 44100
            // CHANGE 1: Use STEREO instead of MONO. It is much safer across all Android devices.
            val channelConfig = AudioFormat.CHANNEL_OUT_STEREO
            val audioFormat = AudioFormat.ENCODING_PCM_16BIT

            val bufferSize = AudioTrack.getMinBufferSize(sampleRate, channelConfig, audioFormat)

            // CHANGE 2: Prevent the -20 crash by ensuring bufferSize is valid (> 0)
            if (bufferSize <= 0) {
                println("Haptics Error: Invalid AudioTrack parameters. Device does not support this format.")
                return
            }

            audioTrack = AudioTrack.Builder()
                .setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build()
                )
                .setAudioFormat(
                    AudioFormat.Builder()
                        .setEncoding(audioFormat)
                        .setSampleRate(sampleRate)
                        .setChannelMask(channelConfig) // Updated to STEREO
                        .build()
                )
                // CHANGE 3: Multiply buffer size slightly to prevent underruns
                .setBufferSizeInBytes(bufferSize * 2)
                .setTransferMode(AudioTrack.MODE_STREAM)
                .build()

            hapticGenerator = HapticGenerator.create(sessionId)
            hapticGenerator?.enabled = true
            audioTrack!!.play()
        }
    }

    private fun releaseHaptics() {
        hapticGenerator?.release()
        hapticGenerator = null
    }
}
