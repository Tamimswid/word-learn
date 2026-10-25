package com.example.wordlearn

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingProcessText: String? = null
    private var channel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        captureProcessText(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        captureProcessText(intent)
        flushPendingText()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialText" -> {
                        result.success(pendingProcessText)
                        pendingProcessText = null
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    private fun captureProcessText(intent: Intent?) {
        if (intent?.action != Intent.ACTION_PROCESS_TEXT) return

        val text = intent.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)
            ?.toString()
            ?.trim()
            .orEmpty()
        if (text.isEmpty()) return

        pendingProcessText = text
    }

    private fun flushPendingText() {
        val text = pendingProcessText ?: return
        pendingProcessText = null
        channel?.invokeMethod("processText", text)
    }

    companion object {
        private const val CHANNEL = "wordlearn/process_text"
    }
}
