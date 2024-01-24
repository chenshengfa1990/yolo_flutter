import 'dart:io';

import 'package:flutter_xlog/flutter_xlog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qiniu_flutter_sdk/qiniu_flutter_sdk.dart';

class UploadUtil {
  static String LOG_TAG = "UploadUtil";

  static Future<void> uploadFile(String path, String token) async {
    var storage = Storage();
    // 使用 storage 的 putFile 对象进行文件上传
    storage.putFile(File(path), token)
      ..then((PutResponse response) {
        XLog.i(LOG_TAG, "上传成功 $response");
        Fluttertoast.showToast(msg: '上传成功');
      })
      ..catchError((dynamic error) {
        if (error is StorageError) {
          switch (error.type) {
            case StorageErrorType.CONNECT_TIMEOUT:
              XLog.e(LOG_TAG, '发生错误: 连接超时');
              Fluttertoast.showToast(msg: '发生错误: 连接超时');
              break;
            case StorageErrorType.SEND_TIMEOUT:
              XLog.e(LOG_TAG, '发生错误: 发送数据超时');
              Fluttertoast.showToast(msg: '发生错误: 发送数据超时');
              break;
            case StorageErrorType.RECEIVE_TIMEOUT:
              XLog.e(LOG_TAG, '发生错误: 响应数据超时');
              Fluttertoast.showToast(msg: '发生错误: 响应数据超时');
              break;
            case StorageErrorType.RESPONSE:
              XLog.e(LOG_TAG, '发生错误: ${error.message}');
              Fluttertoast.showToast(msg: '发生错误: ${error.message}');
              break;
            case StorageErrorType.CANCEL:
              XLog.e(LOG_TAG, '发生错误: 请求取消');
              Fluttertoast.showToast(msg: '发生错误: 请求取消');
              break;
            case StorageErrorType.UNKNOWN:
              XLog.e(LOG_TAG, '发生错误: 未知错误');
              Fluttertoast.showToast(msg: '发生错误: 未知错误');
              break;
            case StorageErrorType.NO_AVAILABLE_HOST:
              XLog.e(LOG_TAG, '发生错误: 无可用 Host');
              Fluttertoast.showToast(msg: '发生错误: 无可用 Host');
              break;
            case StorageErrorType.IN_PROGRESS:
              XLog.e(LOG_TAG, '发生错误: 已在队列中');
              Fluttertoast.showToast(msg: '发生错误: 已在队列中');
              break;
          }
        } else {
          XLog.e(LOG_TAG, '发生错误: ${error.toString()}');
          Fluttertoast.showToast(msg: '发生错误: ${error.toString()}');
        }
      });
  }
}
