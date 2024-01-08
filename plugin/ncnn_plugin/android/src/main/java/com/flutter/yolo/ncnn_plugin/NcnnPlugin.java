package com.flutter.yolo.ncnn_plugin;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.ExifInterface;
import android.net.Uri;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;

import androidx.annotation.NonNull;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** NcnnPlugin */
public class NcnnPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  public static Context activityContext;
  private YoloV5Ncnn yolov5ncnn = new YoloV5Ncnn();
  private HandlerThread handlerThread;
  private Handler handler;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "ncnn_plugin");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("detectImage")) {
      Boolean useGPU = call.<Boolean>argument("useGPU") == Boolean.TRUE;
      Boolean isTest = call.<Boolean>argument("test") == Boolean.TRUE;
      String imagePath = call.argument("imagePath");
      startDetectImage(imagePath, useGPU, isTest, result);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    activityContext = null;
  }

  public void startDetectImage(String imagePath, Boolean useGPU, Boolean isTest, Result result) {
    runInBackground(new Runnable() {
      @Override
      public void run() {
        Bitmap bitmap = null;
        try {
          bitmap = getBitmap(imagePath, isTest);
        } catch (Exception e) {
          Log.e("NcnnPlugin", "getBitmap error: " + e);
          return;
        }
        YoloV5Ncnn.Obj[] objects = yolov5ncnn.Detect(bitmap, useGPU);
        ArrayList<String> resList = getDetectRes(objects);
        result.success(resList);
      }
    });

  }

  public Bitmap getBitmap(String imagePath, boolean isTest) throws Exception {
    InputStream inputStream;
    if (isTest) {
      inputStream = activityContext.getAssets().open("test0.jpg");
    } else {
      File file = new File(imagePath);
      inputStream = new FileInputStream(file);
    }
    byte[] inputStream2ByteArr = inputStream2ByteArr(inputStream);
    // Decode image size
    BitmapFactory.Options o = new BitmapFactory.Options();
    o.inJustDecodeBounds = true;
    BitmapFactory.decodeByteArray(inputStream2ByteArr, 0, inputStream2ByteArr.length, o);

    // The new size we want to scale to
    final int REQUIRED_SIZE = 1280;

    // Find the correct scale value. It should be the power of 2.
    int width_tmp = o.outWidth, height_tmp = o.outHeight;
    int scale = 1;
    while (true) {
      if (width_tmp / 2 < REQUIRED_SIZE
              || height_tmp / 2 < REQUIRED_SIZE) {
        break;
      }
      width_tmp /= 2;
      height_tmp /= 2;
      scale *= 2;
    }

    // Decode with inSampleSize
    BitmapFactory.Options o2 = new BitmapFactory.Options();
    o2.inSampleSize = scale;
    Bitmap bitmap = BitmapFactory.decodeByteArray(inputStream2ByteArr, 0,inputStream2ByteArr.length, o2);

    // Rotate according to EXIF
    int rotate = 0;
//    try
//    {
//      ExifInterface exif = new ExifInterface(inputStream);
//      int orientation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL);
//      switch (orientation) {
//        case ExifInterface.ORIENTATION_ROTATE_270:
//          rotate = 270;
//          break;
//        case ExifInterface.ORIENTATION_ROTATE_180:
//          rotate = 180;
//          break;
//        case ExifInterface.ORIENTATION_ROTATE_90:
//          rotate = 90;
//          break;
//      }
//    }
//    catch (IOException e)
//    {
//      Log.e("NcnnPlugin", "ExifInterface IOException");
//    }

    Matrix matrix = new Matrix();
    matrix.postRotate(rotate);
    return Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);
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

  private ArrayList<String> getDetectRes(YoloV5Ncnn.Obj[] objects) {
    ArrayList<String> resList = new ArrayList<>();
    for (YoloV5Ncnn.Obj object : objects) {
      if (object != null) {
        resList.add(object.toJson());
      }
    }
    return resList;
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    activityContext = binding.getActivity();
    boolean ret_init = yolov5ncnn.Init(activityContext.getAssets());
    if (!ret_init)
    {
      Log.e("NcnnPlugin", "yolov5ncnn Init failed");
    }
    handlerThread = new HandlerThread("ncnnPlugin");
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
