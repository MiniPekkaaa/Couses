package com.example.tevalearn_miniapp

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.FrameLayout
import android.view.ViewGroup

class MainActivity: FlutterActivity() {
    private val CHANNEL = "kinescope_player"
    private var webView: WebView? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initPlayer" -> {
                    val videoId = call.argument<String>("videoId")
                    if (videoId != null) {
                        initKinescopePlayer(videoId)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Video ID is required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun initKinescopePlayer(videoId: String) {
        runOnUiThread {
            webView = WebView(this).apply {
                settings.javaScriptEnabled = true
                webViewClient = WebViewClient()
                loadUrl("https://kinescope.io/embed/$videoId")
            }

            val container = findViewById<FrameLayout>(android.R.id.content)
            container.addView(webView, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
        }
    }

    override fun onDestroy() {
        webView?.destroy()
        super.onDestroy()
    }
} 