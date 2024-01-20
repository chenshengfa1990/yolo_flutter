package com.flutter.yolo.opencv_plugin;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Handler;
import android.os.HandlerThread;

import androidx.annotation.NonNull;

import com.tencent.mars.xlog.Log;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * OpencvPlugin
 */
public class OpencvPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    public static Context activityContext;
    private HandlerThread handlerThread;
    private Handler handler;

    private String[] indexLabel = {"dw", "xw", "2", "A", "K", "Q", "J", "10", "9", "8", "7", "6", "5", "4", "3"};
    private String[] landlordTypeName = {"tx", "weile", "jj"};
    private String[] regionName = {"handcard", "outcard", "loutcard", "routcard", "three", "landlord", "landlord", "landlord"};

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "opencv_plugin");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("startDetectHandCard")) {
            String imagePath = call.argument("imagePath");
            int landlordType = call.argument("landlordType");
            int regionType = call.argument("regionType");
            startDetectImage(imagePath, landlordType, regionType, result);
        } else if (call.method.equals("cropTemplate")) {
            String imagePath = call.argument("imagePath");
            String outputName = call.argument("outputName");
            int xLTop = call.argument("xLTop");
            int yLTop = call.argument("yLTop");
            int xRBottom = call.argument("xRBottom");
            int yRBottom = call.argument("yRBottom");
            startCropTemplate(imagePath, outputName, xLTop, yLTop, xRBottom, yRBottom);
        } else {
            result.notImplemented();
        }
    }

    ArrayList<String> formatDetectResult(ArrayList<OpenCvDetectModel> matchResult) {
        ArrayList<String> resList = new ArrayList<>();
        for (OpenCvDetectModel item : matchResult) {
            if (item != null) {
                resList.add(item.toJson());
            }
        }
        return resList;
    }

    public void startDetectImage(String imagePath, int landlordType, int regionType, Result result) {
        runInBackground(new Runnable() {
            @Override
            public void run() {
                Bitmap bitmap = null;
                Bitmap templateBitmap = null;
                ArrayList<OpenCvDetectModel> matchResult = new ArrayList<>();
                try {
                    bitmap = getBitmap(imagePath);
                    long before = System.currentTimeMillis();
                    for (int i = 0; i < 15; i++) {
                        String templateFile = landlordTypeName[landlordType] + "/" + regionName[regionType] + "/" + indexLabel[i] + ".png";
                        boolean useBinary = true;
                        int threshold = 80;
                        templateBitmap = getAssetsBitmap(templateFile);
                        if (i == 13 || i == 14) {
                            useBinary = false;
                            threshold = 91;
                        }
                        ArrayList<OpenCvDetectModel> thisResult = MatchingUtil.match(bitmap, templateBitmap, indexLabel[i], useBinary, threshold);
                        matchResult.addAll(thisResult);
                        ImageUtils.recycle(templateBitmap);
                    }
                    long after = System.currentTimeMillis();
                    Log.i("OpenCVPlugin", "openCV matchTemplate cost %d", after - before);
                } catch (Exception e) {
                    Log.e("OpenCVPlugin", "getBitmap error: " + e);
                } finally {
                    ImageUtils.recycle(bitmap);
                    ArrayList<String> resList = formatDetectResult(matchResult);
                    result.success(resList);
                }
            }
        });

    }

    public void startCropTemplate(String imagePath, String outputName, int xLTop, int yLTop, int xRBottom, int yRBottom) {
        runInBackground(new Runnable() {
            @Override
            public void run() {
                Bitmap bitmap = null;
                try {
                    bitmap = getBitmap(imagePath);
                } catch (Exception e) {
                    Log.e("OpenCVPlugin", "cropBitmap error: " + e);
                    return;
                }
                CropTemplate.crop(bitmap, outputName, xLTop, yLTop, xRBottom, yRBottom);
            }
        });
    }

    public Bitmap getBitmap(String imagePath) throws Exception {
        File file = new File(imagePath);
        InputStream inputStream = new FileInputStream(file);
        Bitmap bitmap = BitmapFactory.decodeStream(inputStream);
        return bitmap;
    }

    public Bitmap getAssetsBitmap(String assetName) throws Exception {
        InputStream inputStream = activityContext.getAssets().open(assetName);
        Bitmap bitmap = BitmapFactory.decodeStream(inputStream);
        return bitmap;
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        activityContext = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activityContext = binding.getActivity();
        Utils.init(activityContext);
        handlerThread = new HandlerThread("openCvPlugin");
        handlerThread.start();
        handler = new Handler(handlerThread.getLooper());
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {
        activityContext = null;
    }

    protected synchronized void runInBackground(final Runnable r) {
        if (this.handler != null) {
            this.handler.post(r);
        }
    }
}
