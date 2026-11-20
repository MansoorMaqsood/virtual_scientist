package com.example.virtual_scientist
import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import com.unity3d.player.UnityPlayerActivity

class CustomUnityPlayerActivity : UnityPlayerActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val uiName = intent.getStringExtra("ui_name") ?: "UI_Canvas"
        Log.d("CustomUnity", " Unity will start with UI: $uiName")
    }
    override fun onBackPressed() {
        Log.d("CustomUnity", " Back pressed — closing Unity and returning to Flutter")

        // Send a result back to Flutter
        val resultIntent = Intent().apply {
            putExtra("unity_closed", true)
        }
        setResult(Activity.RESULT_OK, resultIntent)

        // Close Unity activity and return to Flutter
        finish()
    }
}
