package com.example.virtual_scientist

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.virtual_scientist/unity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "launchUnity") {
                    val uiName = call.argument<String>("uiName") ?: "UI_Canvas"
                    launchUnityActivity(uiName)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun launchUnityActivity(uiName: String) {
        val intent = Intent(this, CustomUnityPlayerActivity::class.java)
        intent.putExtra("ui_name", uiName)
        startActivity(intent)
    }
}