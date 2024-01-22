import 'package:ncnn_plugin/export.dart';
import 'package:yolo_flutter/landlord/landlord_type.dart';
import 'package:yolo_flutter/screenshot/screen_shot_manager.dart';
import 'package:yolo_flutter/screenshot/sub/huanle_screenshot.dart';
import 'package:yolo_flutter/screenshot/sub/tuyou_screenshot.dart';
import 'package:yolo_flutter/screenshot/sub/weile_screenshot.dart';

class ScreenshotFactory {
  static ScreenShotManager getScreenshotManager(LandlordType landlordType, NcnnPlugin ncnnPlugin) {
    switch (landlordType) {
      case LandlordType.huanle:
        return HuanleScreenshot(ncnnPlugin);
      case LandlordType.weile:
        return WeileScreenshot(ncnnPlugin);
      case LandlordType.tuyou:
        return TuyouScreenshot(ncnnPlugin);
      default:
        return HuanleScreenshot(ncnnPlugin);
    }
  }
}
