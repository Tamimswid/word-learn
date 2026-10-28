package com.example.wordlearn

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Shows the small capture card over the app that sent the text, without
 * launching the full app. Dart runs in a dedicated entrypoint
 * (`quickCaptureMain`) and closes this activity when the word is saved.
 */
class QuickCaptureActivity : FlutterActivity() {
    private var pendingText: String? = null
    private var channel: MethodChannel? = null
    private val handler = Handler(Looper.getMainLooper())
    private val timeout = Runnable { finish() }

    override fun onCreate(savedInstanceState: Bundle?) {
        pendingText = extractText(intent)
        super.onCreate(savedInstanceState)
        // Never leave a transparent window behind if Dart cannot answer.
        handler.postDelayed(timeout, TIMEOUT_MS)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "takeText" -> {
                        result.success(pendingText)
                        pendingText = null
                    }
                    "close" -> {
                        result.success(null)
                        finish()
                    }
                    "openApp" -> {
                        result.success(null)
                        openApp()
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun getDartEntrypointFunctionName(): String = DART_ENTRYPOINT

    override fun getBackgroundMode(): BackgroundMode = BackgroundMode.transparent

    override fun onDestroy() {
        handler.removeCallbacks(timeout)
        channel?.setMethodCallHandler(null)
        channel = null
        super.onDestroy()
    }

    private fun openApp() {
        startActivity(Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        finish()
    }

    private fun extractText(intent: Intent?): String? {
        if (intent == null) return null

        val raw = when (intent.action) {
            Intent.ACTION_SEND -> intent.getCharSequenceExtra(Intent.EXTRA_TEXT)
            Intent.ACTION_PROCESS_TEXT -> intent.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)
            else -> null
        }

        return raw?.toString()?.trim()?.takeIf { it.isNotEmpty() }
    }

    companion object {
        private const val CHANNEL = "wordlearn/quick_capture"
        private const val DART_ENTRYPOINT = "quickCaptureMain"
        private const val TIMEOUT_MS = 20_000L
    }
}
