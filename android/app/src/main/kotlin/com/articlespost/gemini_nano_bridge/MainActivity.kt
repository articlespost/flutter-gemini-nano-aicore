package com.articlespost.gemini_nano_bridge

import com.articlespost.gemini_nano_bridge.ai.GeminiNanoBridge
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    private var geminiNanoBridge: GeminiNanoBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        geminiNanoBridge = GeminiNanoBridge(flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        geminiNanoBridge?.dispose()
        geminiNanoBridge = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
