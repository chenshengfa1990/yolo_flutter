package com.flutter.yolo

import android.content.Intent
import android.os.Bundle
import com.flutter.yolo.screenshot_plugin.ScreenshotPlugin
import io.flutter.embedding.android.FlutterActivity
import org.opencv.android.BaseLoaderCallback
import org.opencv.android.OpenCVLoader
import org.opencv.core.Core

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
//        App.init(this);
//        OpenCVLoader.initAsync(OpenCVLoader.OPENCV_VERSION, this, object : BaseLoaderCallback(this) {
//            override fun onManagerConnected(status: Int) {
//                super.onManagerConnected(status)
//            }
//        })
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == ScreenshotPlugin.REQUEST_CODE_CAPTURE_SCREEN && resultCode == RESULT_OK) {
            ScreenshotPlugin.screenShotIntent = data
            ScreenshotPlugin.screenshotPermissionResultCode = resultCode
        }
    }
}
