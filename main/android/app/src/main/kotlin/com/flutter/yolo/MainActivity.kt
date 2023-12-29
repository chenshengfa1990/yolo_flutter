package com.flutter.yolo

import android.content.Intent
import android.media.projection.MediaProjection
import android.os.Bundle
import com.flutter.yolo.screenshot_plugin.ScreenshotPlugin
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == ScreenshotPlugin.REQUEST_CODE_CAPTURE_SCREEN && resultCode == RESULT_OK) {
            ScreenshotPlugin.screenShotIntent = data
            ScreenshotPlugin.screenshotPermissionResultCode = resultCode
        }
    }
}
