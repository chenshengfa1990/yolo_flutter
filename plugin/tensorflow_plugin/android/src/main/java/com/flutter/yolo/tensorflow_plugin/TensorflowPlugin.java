package com.flutter.yolo.tensorflow_plugin;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.RectF;
import android.os.Handler;
import android.os.HandlerThread;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.SeekBar;

import androidx.annotation.NonNull;

import org.json.JSONObject;

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

/** TensorflowPlugin */
public class TensorflowPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  public static Context activityContext;
  private File[] process_files = null;
  private int inputSize = 384;
  private float conf_threshold = 0.25F;
  private float iou_threshold = 0.45F;

  private boolean handler_stop_request;
  private Handler handler;
  private HandlerThread handlerThread;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "tensorflow_plugin");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("startInference")) {
      String imagePath = (String)call.arguments;
      startInference(imagePath, result);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    activityContext = null;
  }

  void startInference(String imagePath, Result result) {
    if (!imagePath.isEmpty()) {
      process_files = new File[]{new File(imagePath)};
    }

    TfliteRunner runner;
    TfliteRunMode.Mode runmode = TfliteRunMode.Mode.NONE_FP32;
    if (this.process_files == null || this.process_files.length == 0){
      showErrorDialog("Please select image or directory.");
      return;
    }
    if (runmode == null) {
      showErrorDialog("Please select valid configurations.");
      return;
    }
    try {
      Context context = activityContext.getApplicationContext();
      runner = new TfliteRunner(context, runmode, this.inputSize, conf_threshold, iou_threshold);
    } catch (Exception e) {
      showErrorDialog("Model load failed: " + e.getMessage());
      return;
    }

    if(isBackgroundTaskRunning()){
      //already inference is running, stop inference
      this.handler_stop_request = true;
      this.handlerThread.quitSafely();
      try {
        handlerThread.join();
        handlerThread = null;
        handler = null;
      } catch (final InterruptedException e) {
//        addLog(e.getMessage() +  "Exception!");
      }
      OnInferenceTaskCompleted();
      return;
    } else {
      //start inference task
      this.handler_stop_request = false;
      OnInferenceTaskStart();
    }

    //run inference in background
    this.handlerThread = new HandlerThread("inference");
    this.handlerThread.start();
    this.handler = new Handler(this.handlerThread.getLooper());
    File[] process_files = this.process_files;

    ArrayList<HashMap<String, Object>> resList = new ArrayList<>();
    runInBackground(
            new Runnable() {
              @Override
              public void run() {
                try {
                  for(int i = 0; i < process_files.length; i++){
                    if (handler_stop_request) break;
                    File file = process_files[i];
                    InputStream is = new FileInputStream(file);
                    Bitmap bitmap = BitmapFactory.decodeStream(is);
                    Bitmap resized = TfliteRunner.getResizedImage(bitmap, inputSize);
                    runner.setInput(resized);
                    List<TfliteRunner.Recognition> bboxes = runner.runInference();
                    Bitmap resBitmap = ImageProcess.drawBboxes(bboxes, bitmap, inputSize);
                    ArrayList<HashMap<String, Object>> bboxmaps = bboxesToMap(file, bboxes, bitmap.getHeight(), bitmap.getWidth());
                    resList.addAll(bboxmaps);
                    bitmap.recycle();
                    returnResultToFlutter(result, resList);
                  }
                } catch (Exception e) {
                  ((Activity)activityContext).runOnUiThread(
                          new Runnable() {
                            @Override
                            public void run() {
                              showErrorDialog("Inference failed : " + e.getMessage()) ;
                            }
                          }
                  );
                }
                //completed
                ((Activity)activityContext).runOnUiThread(
                        new Runnable() {
                          @Override
                          public void run() {
                            handler_stop_request = false;
                            OnInferenceTaskCompleted();
                            //output json if directory mode
//                            if (process_files.length > 1) {
//                              try {
//                                String jsonpath = saveBboxesToJson(resList, process_files[0], "result.json");
//                                showInfoDialog("result json is saved : " + jsonpath);
//                              } catch (Exception e){
//                                showErrorDialog("json output failed : " + e.getMessage());
//                              }
//                            }
                          }
                        }
                );
              }
            }
    );
  }

  private void showErrorDialog(String text){ showDialog("Error", text);}
  private void showInfoDialog(String text){ showDialog("Info", text);}
  private void showDialog(String title, String text){
    new AlertDialog.Builder(activityContext)
            .setTitle(title)
            .setMessage(text)
            .setPositiveButton("OK" , null )
            .create().show();
  }
  private boolean isBackgroundTaskRunning() {
    return this.handlerThread != null && this.handlerThread.isAlive();
  }

  public void OnInferenceTaskCompleted() {

  }

  public void OnInferenceTaskStart() {

  }

  protected synchronized void runInBackground(final Runnable r) {
    if (this.handler != null) {
      this.handler.post(r);
    }
  }

  ArrayList<HashMap<String, Object>> bboxesToMap(File file, List<TfliteRunner.Recognition> bboxes, int orig_h, int orig_w){
    ArrayList<HashMap<String, Object>> resList = new ArrayList<HashMap<String, Object>>();
    String basename = file.getName();
    basename = basename.substring(0, basename.lastIndexOf('.'));
    Object image_id;
    try{
      image_id = Integer.parseInt(basename);
    } catch (Exception e){
      image_id = basename;
    }
    for(TfliteRunner.Recognition bbox : bboxes){
      //clamp and scale to original image size
      RectF location = bbox.getLocation();
      float x1 = Math.min(Math.max(0, location.left), this.inputSize) * orig_w / (float)this.inputSize;
      float y1 = Math.min(Math.max(0, location.top), this.inputSize) * orig_h / (float)this.inputSize;
      float x2 = Math.min(Math.max(0, location.right), this.inputSize) * orig_w / (float)this.inputSize;
      float y2 = Math.min(Math.max(0, location.bottom), this.inputSize) * orig_h / (float)this.inputSize;
      float x = x1;
      float y = y1;
      float w = x2 - x1;
      float h = y2 - y1;
      float conf = bbox.getConfidence();
      int class_idx = TfliteRunner.get_coco91_from_coco80(bbox.getClass_idx());
      HashMap<String, Object> mapbox = new HashMap<>();
      mapbox.put("image_id", image_id);
      mapbox.put("bbox", new float[]{x, y, w, h});
      mapbox.put("score", conf);
      mapbox.put("category_id", class_idx);
      resList.add(mapbox);
    }
    return resList;
  }

  void returnResultToFlutter(Result result, ArrayList<HashMap<String, Object>> resList) {
    ArrayList<String> list = new ArrayList<>();
    for(int i = 0; i < resList.size(); i++) {
      String mapStr = mapToString(resList.get(i));
      list.add(mapStr);
    }
    result.success(resList);
  }

  private String mapToString(Map<String, Object> map) {
    if (map == null) {
      return "";
    }
    return new JSONObject(map).toString();
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    activityContext = binding.getActivity();
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
}
