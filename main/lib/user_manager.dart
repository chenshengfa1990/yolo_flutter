import 'package:flutter/services.dart';
import 'package:flutter_xlog/flutter_xlog.dart';
import 'package:platform_device_id/platform_device_id.dart';

class UserManager {
  static const String LOG_TAG = 'UserManager';
  static String deviceId = "123";

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
}