package com.flutter.yolo;

import android.app.Application;

import com.tencent.mars.xlog.Log;
import com.tencent.upgrade.bean.UpgradeConfig;
import com.tencent.upgrade.core.UpgradeManager;

import org.opencv.android.BaseLoaderCallback;
import org.opencv.android.LoaderCallbackInterface;
import org.opencv.android.OpenCVLoader;


public class YoloApp extends Application{

    private BaseLoaderCallback mLoaderCallback = new BaseLoaderCallback(this) {
        @Override
        public void onManagerConnected(int status) {
            switch (status) {
                case LoaderCallbackInterface.SUCCESS:
                    Log.i("YoloApp", "OpenCV loaded successfully");
                    break;
                default:
                    super.onManagerConnected(status);
                    break;
            }
        }
    };
    @Override
    public void onLowMemory() {
        super.onLowMemory();
    }

    @Override
    public void onCreate() {
        super.onCreate();

        if (OpenCVLoader.initDebug()) {
            Log.d("YoloApp", "OpenCV library loaded");
        } else {
            OpenCVLoader.initAsync(OpenCVLoader.OPENCV_VERSION, this, mLoaderCallback);
        }

        UpgradeConfig.Builder builder = new UpgradeConfig.Builder();
        UpgradeConfig config = builder.appId("e517ced9dc").appKey("639118c2-77b8-483f-bd6a-bd7b75d2303a").build();
        UpgradeManager.getInstance().init(this, config);

//        UpgradeManager.getInstance().checkUpgrade(false, null, new YoloUpgradeStrategyRequestCallback());

    }

}
