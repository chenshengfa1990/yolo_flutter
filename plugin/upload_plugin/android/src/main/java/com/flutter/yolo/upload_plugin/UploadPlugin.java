package com.flutter.yolo.upload_plugin;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

//import com.alibaba.sdk.android.oss.ClientException;
//import com.alibaba.sdk.android.oss.ServiceException;
//import com.alibaba.sdk.android.oss.callback.OSSCompletedCallback;
//import com.alibaba.sdk.android.oss.callback.OSSProgressCallback;
//import com.alibaba.sdk.android.oss.common.OSSLog;
//import com.alibaba.sdk.android.oss.internal.OSSAsyncTask;
//import com.alibaba.sdk.android.oss.model.OSSRequest;
//import com.alibaba.sdk.android.oss.model.PutObjectRequest;
//import com.alibaba.sdk.android.oss.model.PutObjectResult;
import com.qiniu.util.Auth;

import java.io.File;
import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** UploadPlugin */
public class UploadPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  public static Context activityContext;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "upload_plugin");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("getQiniuToken")) {
      String token = createQiniuToken();
      result.success(token);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    activityContext = null;
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

  public String createQiniuToken() {
    String accessKey = "Qq91Xkp5NFYyRRp_K6VrZMTyVUyDq6XmZrjFN7mR";
    String secretKey = "xKGkar_FIwgbRQn80PcugEbtgTSET4xkIYeFONWV";
    String bucket = "yolo-log";
    Auth auth = Auth.create(accessKey, secretKey);
    String upToken = auth.uploadToken(bucket);
    return upToken;
  }

//  public void asyncPutImage(String object, String localFile) {
//    final long upload_start = System.currentTimeMillis();
//    OSSLog.logDebug("upload start");
//
//    if (object.equals("")) {
//      Log.w("AsyncPutImage", "ObjectNull");
//      return;
//    }
//
//    File file = new File(localFile);
//    if (!file.exists()) {
//      Log.w("AsyncPutImage", "FileNotExist");
//      Log.w("LocalFile", localFile);
//      return;
//    }
//
//    // 构造上传请求
//    OSSLog.logDebug("create PutObjectRequest ");
//    PutObjectRequest put = new PutObjectRequest(Config.BUCKET_NAME, object, localFile);
//    put.setCRC64(OSSRequest.CRC64Config.YES);
////    if (mCallbackAddress != null) {
////      // 传入对应的上传回调参数，这里默认使用OSS提供的公共测试回调服务器地址
////      put.setCallbackParam(new HashMap<String, String>() {
////        {
////          put("callbackUrl", mCallbackAddress);
////          //callbackBody可以自定义传入的信息
////          put("callbackBody", "filename=${object}");
////        }
////      });
////    }
//
//    // 异步上传时可以设置进度回调
//    put.setProgressCallback(new OSSProgressCallback<PutObjectRequest>() {
//      @Override
//      public void onProgress(PutObjectRequest request, long currentSize, long totalSize) {
//        Log.d("PutObject", "currentSize: " + currentSize + " totalSize: " + totalSize);
//        int progress = (int) (100 * currentSize / totalSize);
////        mDisplayer.updateProgress(progress);
////        mDisplayer.displayInfo("上传进度: " + String.valueOf(progress) + "%");
//      }
//    });
//
//    OSSLog.logDebug(" asyncPutObject ");
//    OSSAsyncTask task = mOss.asyncPutObject(put, new OSSCompletedCallback<PutObjectRequest, PutObjectResult>() {
//      @Override
//      public void onSuccess(PutObjectRequest request, PutObjectResult result) {
//        Log.d("PutObject", "UploadSuccess");
//
//        Log.d("ETag", result.getETag());
//        Log.d("RequestId", result.getRequestId());
//
//        long upload_end = System.currentTimeMillis();
//        OSSLog.logDebug("upload cost: " + (upload_end - upload_start) / 1000f);
//        mDisplayer.uploadComplete();
//        mDisplayer.displayInfo("Bucket: " + mBucket
//                + "\nObject: " + request.getObjectKey()
//                + "\nETag: " + result.getETag()
//                + "\nRequestId: " + result.getRequestId()
//                + "\nCallback: " + result.getServerCallbackReturnBody());
//      }
//
//      @Override
//      public void onFailure(PutObjectRequest request, ClientException clientExcepion, ServiceException serviceException) {
//        String info = "";
//        // 请求异常
//        if (clientExcepion != null) {
//          // 本地异常如网络异常等
//          clientExcepion.printStackTrace();
//          info = clientExcepion.toString();
//        }
//        if (serviceException != null) {
//          // 服务异常
//          Log.e("ErrorCode", serviceException.getErrorCode());
//          Log.e("RequestId", serviceException.getRequestId());
//          Log.e("HostId", serviceException.getHostId());
//          Log.e("RawMessage", serviceException.getRawMessage());
//          info = serviceException.toString();
//        }
//        mDisplayer.uploadFail(info);
//        mDisplayer.displayInfo(info);
//      }
//    });
//  }
}
