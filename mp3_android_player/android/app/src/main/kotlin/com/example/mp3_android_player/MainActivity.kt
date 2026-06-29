package com.example.mp3_android_player
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import android.media.audiofx.HapticGenerator
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.haptics.audio_pipe"
    private var audioTrack: AudioTrack? = null
    private var hapticGenerator: HapticGenerator? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initHaptics" -> {
                    initHaptics()
                    result.success(null)
                }
                "writeBytes" -> {
                    val bytes = call.argument<ByteArray>("bytes")
                    if (bytes != null) {
                        writeBytes(bytes)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGS", "Bytes array cannot be null", null)
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

    private fun initHaptics() {
        // HapticGenerator is only available on Android 12 (API 31) and higher
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && HapticGenerator.isAvailable()) {
            
            // NOTE: This sampleRate MUST match the output of your FFmpeg low-pass filter
            val sampleRate = 44100 
            val channelConfig = AudioFormat.CHANNEL_OUT_STEREO // Forced to Stereo for hardware compatibility
            val audioFormat = AudioFormat.ENCODING_PCM_16BIT

            val bufferSize = AudioTrack.getMinBufferSize(
                sampleRate,
                channelConfig,
                audioFormat
            )

            // Prevent -20 crash by ensuring bufferSize is valid (> 0)
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
                        .setChannelMask(channelConfig)
                        .build()
                )
                // Multiply buffer size slightly to prevent underruns
                .setBufferSizeInBytes(bufferSize * 2) 
                .setTransferMode(AudioTrack.MODE_STREAM)
                .build()

            // Attach the HapticGenerator to this specific AudioTrack's session
            val sessionId = audioTrack!!.audioSessionId
            hapticGenerator = HapticGenerator.create(sessionId)
            hapticGenerator?.enabled = true

            // Prime the track to receive data
            audioTrack!!.play()
        }
    }

    private fun writeBytes(bytes: ByteArray) {
        // Feed the FFmpeg PCM stream directly to the AudioTrack
        audioTrack?.write(bytes, 0, bytes.size)
    }

    private fun releaseHaptics() {
        hapticGenerator?.release()
        hapticGenerator = null
        audioTrack?.stop()
        audioTrack?.release()
        audioTrack = null
    }
}
