package com.flutter.yolo.screenshot_plugin;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.Bitmap;
import android.graphics.ImageFormat;
import android.graphics.Matrix;
import android.graphics.PixelFormat;
import android.hardware.display.DisplayManager;
import android.hardware.display.VirtualDisplay;
import android.media.Image;
import android.media.ImageReader;
import android.media.projection.MediaProjection;
import android.media.projection.MediaProjectionManager;
import android.os.Environment;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Display;
import android.view.Surface;
import android.view.WindowManager;

import androidx.annotation.NonNull;

import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.nio.ByteBuffer;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * ScreenshotPlugin
 */
public class ScreenshotPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private static final String TAG = "ScreenshotPlugin";
    private MethodChannel channel;
    private Activity mActivity;
    private Context mContext;
    static public Intent screenShotIntent;
    static public Result requestPermissionResult;
    static public MediaProjectionManager mediaProjectionManager = null;
    private VirtualDisplay mVirtualDisplay = null;
    ImageReader imageReader = null;
    static public int screenshotPermissionResultCode = Activity.RESULT_CANCELED;
    static public int REQUEST_CODE_CAPTURE_SCREEN = 1001;
    private HandlerThread handlerThread;
    private Handler handler;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "screenshot_plugin");
        channel.setMethodCallHandler(this);
        mContext = flutterPluginBinding.getApplicationContext();
    }

    static public void setRequestPermissionResult(Boolean result) {
        requestPermissionResult.success(result);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("takeScreenshot")) {
            takeScreenshot(result);
        } else if (call.method.equals("stopScreenshot")) {
            stopScreenshot();
            result.success(null);
        } else if (call.method.equals("requestPermission")) {
            requestPermissionResult = result;
            requestPermission();
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        mContext = null;
        requestPermissionResult = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        mActivity = binding.getActivity();
        handlerThread = new HandlerThread("screenshot");
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
        mActivity = null;
        requestPermissionResult = null;
    }

    private void requestPermission() {
        mediaProjectionManager = (MediaProjectionManager) mContext.getSystemService(Context.MEDIA_PROJECTION_SERVICE);
        Intent permissionIntent = mediaProjectionManager.createScreenCaptureIntent();
        mActivity.startActivityForResult(permissionIntent, REQUEST_CODE_CAPTURE_SCREEN);
    }

    private void stopScreenshot() {
        if (mVirtualDisplay != null) {
            mVirtualDisplay.release();
            mVirtualDisplay = null;
        }
        //todo 此处可能造成崩溃，暂时注释
//        if (imageReader != null) {
//            imageReader.close();
//            imageReader = null;
//        }
        screenShotIntent = null;
        screenshotPermissionResultCode = Activity.RESULT_CANCELED;
    }

    @SuppressLint("WrongConstant")
    private void initScreenShot() {
        //通过权限返回的结果获取MediaProjection
        MediaProjection mediaProjection = mediaProjectionManager.getMediaProjection(screenshotPermissionResultCode, screenShotIntent);
        if (mediaProjection == null) {
            return;
        }
        DisplayMetrics metrics = new DisplayMetrics();
        WindowManager windowManager = (WindowManager) mContext.getSystemService(Context.WINDOW_SERVICE);
        Display display = windowManager.getDefaultDisplay();
        display.getRealMetrics(metrics);

        //横屏
        int screenWidth = metrics.heightPixels;
        int screenHeight = metrics.widthPixels;

        //创建用于接收投影的容器
        imageReader = ImageReader.newInstance(screenWidth, screenHeight, PixelFormat.RGBA_8888, 2);

        //通过MediaProjection创建创建虚拟显示器对象，创建后物理屏幕画面会不断地投影到虚拟显示器VirtualDisplay上，输出到虚拟现实器创建时设定的输出Surface上
        mVirtualDisplay = mediaProjection.createVirtualDisplay("mediaprojection", screenWidth, screenHeight,
                metrics.densityDpi, DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR, imageReader.getSurface(), null, null);

    }

    private void takeScreenshot(Result result) {
        runInBackground((Runnable) () -> {
            if (screenShotIntent == null || mediaProjectionManager == null) {
                result.success(null);
                return;
            }

            if (imageReader == null || mVirtualDisplay == null) {
                initScreenShot();
            }

            //从容器中获取image，页面静止时，获取到的image有可能为null
            Image image = imageReader.acquireLatestImage();
            if (image != null) {
                Image.Plane[] planes = image.getPlanes();
                ByteBuffer buffer = planes[0].getBuffer();
                int pixelStride = planes[0].getPixelStride();
                int rowStride = planes[0].getRowStride();
                int rowPadding = rowStride - pixelStride * image.getWidth();
                int realWidth = image.getWidth() + rowPadding / pixelStride;
                int realHeight = image.getHeight();
                Bitmap bitmap = Bitmap.createBitmap(realWidth, realHeight, Bitmap.Config.ARGB_8888);
                bitmap.copyPixelsFromBuffer(buffer);
                String filePath = writeBitmap(bitmap);

                Map<String, Object> resultMap = new HashMap<>();
                resultMap.put("filePath", filePath);
                resultMap.put("width", realWidth / 2);
                resultMap.put("height", realHeight / 2);
                String resStr = mapToString(resultMap);
                bitmap.recycle();
                image.close();
                result.success(resStr);
                return;
            }
            result.success(null);
        });

    }

    private String mapToString(Map<String, Object> map) {
        if (map == null) {
            return "";
        }
        return new JSONObject(map).toString();
    }

    private String getScreenshotName() {
        java.text.SimpleDateFormat sf = new java.text.SimpleDateFormat("yyyyMMdd-HHmmss-SSS");
        String sDate = sf.format(new Date());

        return "yolo_screenshot-" + sDate + ".jpg";
    } // getScreenshotName()

    private String getScreenshotPath() {
//        String pathTemporary = mContext.getCacheDir().getPath();
        String pathTemporary = mContext.getExternalFilesDir(Environment.DIRECTORY_PICTURES).getPath();

        return pathTemporary + "/" + getScreenshotName();
    } // getScreenshotPath()

    private String writeBitmap(Bitmap bitmap) {
        try {
            String path = getScreenshotPath();
            File imageFile = new File(path);
            FileOutputStream oStream = new FileOutputStream(imageFile);
            Bitmap scaledBitmap = Bitmap.createScaledBitmap(bitmap, bitmap.getWidth() / 2, bitmap.getHeight() / 2, false);

            scaledBitmap.compress(Bitmap.CompressFormat.JPEG, 50, oStream);
            oStream.flush();
            oStream.close();

            return path;
        } catch (Exception ex) {
            Log.println(Log.INFO, TAG, "Error writing bitmap: " + ex.getMessage());
        }

        return null;
    }

    protected synchronized void runInBackground(final Runnable r) {
        if (this.handler != null) {
            this.handler.post(r);
        }
    }
}
