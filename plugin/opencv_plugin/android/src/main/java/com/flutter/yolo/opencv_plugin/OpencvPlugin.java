package com.flutter.yolo.opencv_plugin;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Handler;
import android.os.HandlerThread;

import androidx.annotation.NonNull;

import com.tencent.mars.xlog.Log;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** OpencvPlugin */
public class OpencvPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  public static Context activityContext;
  private HandlerThread handlerThread;
  private Handler handler;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "opencv_plugin");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("detectImage")) {
      String imagePath = call.argument("imagePath");
      startDetectImage(imagePath, result);
    } else {
      result.notImplemented();
    }
  }
  public void startDetectImage(String imagePath, Result result) {
    runInBackground(new Runnable() {
      @Override
      public void run() {
        Bitmap bitmap = null;
        Bitmap assetBitmap = null;
        try {
          bitmap = getBitmap(imagePath);
          assetBitmap = getAssetsBitmap("redA.png");
        } catch (Exception e) {
          Log.e("NcnnPlugin", "getBitmap error: " + e);
          return;
        }
        long before = System.currentTimeMillis();
        MatchingUtil.match(bitmap, assetBitmap, 60);
        long after = System.currentTimeMillis();
        Log.i("chenshengfa", "getResult cost %d", after - before);
//        ArrayList<String> resList = getDetectRes(objects);
//        result.success(resList);
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

  private byte[] inputStream2ByteArr(InputStream inputStream) throws IOException {
    ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
    byte[] buff = new byte[1024];
    int len = 0;
    while ((len = inputStream.read(buff)) != -1) {
      outputStream.write(buff, 0, len);
    }
    inputStream.close();
    outputStream.close();
    return outputStream.toByteArray();
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
