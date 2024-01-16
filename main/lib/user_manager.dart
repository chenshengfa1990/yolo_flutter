import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_xlog/flutter_xlog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:yolo_flutter/strategy_manager.dart';

import 'http/httpUtils.dart';

class UserManager {
  static const String LOG_TAG = 'UserManager';
  static String deviceId = "123";
  static String loginToken = '';

  static Future<void> init() async {
    try {
      var id = await PlatformDeviceId.getDeviceId;
      if (id?.isNotEmpty ?? false) {
        deviceId = id!;
        XLog.i(LOG_TAG, 'deviceId: $deviceId');
      } else {
        XLog.e(LOG_TAG, 'deviceId is empty');
      }
    } on PlatformException {
      XLog.e(LOG_TAG, 'Failed to get deviceId.');
    }
  }

  static Future<bool> userLogin(String loginTok) async {
    XLog.i(LOG_TAG, 'check userLogin');
    loginToken = loginTok;
    Map<String, dynamic> httpParams = {};
    var jsonStr = json.encode(httpParams);
    String userId = getUserId();
    String hash = getHash(jsonStr);
    Options options = Options();
    options.headers = {'userid': userId, 'hash': hash};
    if (userId.isEmpty || hash.isEmpty) {
      return false;
    }
    try {
      var res = await HttpUtils.post(StrategyManager.serverUrl, data: jsonStr, options: options);
      if (res.containsKey('error_msg') && res['error_msg'] != null && res['error_msg'].isNotEmpty) {
        var errMsg = res['error_msg'];
        XLog.i(LOG_TAG, 'userLogin fail, $errMsg');
        Fluttertoast.showToast(msg: '$errMsg');
        return false;
      }
      XLog.i(LOG_TAG, 'userLogin success');
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: '登录失败');
      XLog.i(LOG_TAG, 'userLogin error: $e');
      return false;
    }
  }

  static Future<int> requestUserOutDate(String loginTok) async {
    XLog.i(LOG_TAG, 'check userLogin');
    loginToken = loginTok;
    Map<String, dynamic> httpParams = {};
    var jsonStr = json.encode(httpParams);
    String userId = getUserId();
    String hash = getHash(jsonStr);
    Options options = Options();
    options.headers = {'userid': userId, 'hash': hash};
    if (userId.isEmpty || hash.isEmpty) {
      return 0;
    }
    try {
      var res = await HttpUtils.post(StrategyManager.userInfoUrl, data: jsonStr, options: options);
      if (res.containsKey('data')) {
        return res['data']['second'];
      }
      return 0;
    } catch (e) {
      XLog.i(LOG_TAG, 'userInfo error: $e');
      return 0;
    }
  }

  static String getUserId() {
    if (loginToken.isEmpty) {
      XLog.e(LOG_TAG, 'getUserId error, loginToken is null');
      Fluttertoast.showToast(msg: '激活码格式错误');
      return '';
    }
    if (loginToken.length != 16) {
      Fluttertoast.showToast(msg: '激活码格式错误');
      XLog.e(LOG_TAG, 'getUserId error, loginToken length: ${loginToken.length}');
      return '';
    }
    return loginToken.substring(0, 8);
  }

  static String getHash(String dataContent) {
    if (loginToken.isEmpty) {
      XLog.e(LOG_TAG, 'getHash error, loginToken is null');
      return '';
    }
    if (loginToken.length != 16) {
      XLog.e(LOG_TAG, 'getHash error, loginToken length: ${loginToken.length}');
      return '';
    }
    String hashContent = dataContent + loginToken.substring(8);
    List<int> hashBytes = utf8.encode(hashContent);
    Digest sha256Result = sha256.convert(hashBytes);
    String hashCode = sha256Result.toString();
    return hashCode;
  }
}