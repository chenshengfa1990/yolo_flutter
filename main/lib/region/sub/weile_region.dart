import 'dart:ui';

import 'package:yolo_flutter/region/region_type.dart';

import '../../screenshot/screen_shot_manager.dart';

class WeileRegion {
  static Rect getThreeCardRegion() {
    double xLeftTop = 450.0 / 1184.0 * ScreenShotManager.width; //左上角x坐标
    double yLeftTop = 0; //左上角y坐标
    double xRightBottom = 730.0 / 1184.0 * ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 60.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getMyHandCardRegion() {
    double xLeftTop = 0; //左上角x坐标
    double yLeftTop = 280.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = ScreenShotManager.width; //右下角x坐标
    double yRightBottom = ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getMyOutCardRegion() {
    double xLeftTop = 0; //左上角x坐标
    double yLeftTop = 160.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 265.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getRightPlayerOutCardRegion() {
    double xLeftTop = 590.0 / 1184.0 * ScreenShotManager.width; //左上角x坐标
    double yLeftTop = 60.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = 995.0 / 1184.0 * ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 160.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getLeftPlayerOutCardRegion() {
    double xLeftTop = 165.0 / 1184.0 * ScreenShotManager.width; //左上角x坐标
    double yLeftTop = 60.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = 590.0 / 1184.0 * ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 160.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getMyLandlordRegion() {
    double xLeftTop = 280.0 / 1184.0 * ScreenShotManager.width; //左上角x坐标
    double yLeftTop = 475.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = 415.0 / 1184.0 * ScreenShotManager.width; //右下角x坐标
    double yRightBottom = ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getLeftLandlordRegion() {
    double xLeftTop = 90.0 / 1184.0 * ScreenShotManager.width; //左上角x坐标
    double yLeftTop = 110.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = 190.0 / 1184.0 * ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 190.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getRightLandlordRegion() {
    double xLeftTop = 970.0 / 1184.0 * ScreenShotManager.width; //左上角x坐标
    double yLeftTop = 110.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = 1070.0 / 1184.0 * ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 190.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getRightPlayerBuchuRegion() {
    double xLeftTop = 880.0 / 1184.0 * ScreenShotManager.width; //左上角x坐标
    double yLeftTop = 85.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = 1030.0 / 1184.0 * ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 170.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getLeftPlayerBuchuRegion() {
    double xLeftTop = 160.0 / 1184.0 * ScreenShotManager.width; //左上角x坐标
    double yLeftTop = 85.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = 280.0 / 1184.0 * ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 170.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getMyBuchuRegion() {
    double xLeftTop = 525.0 / 1184.0 * ScreenShotManager.width; //左上角x坐标
    double yLeftTop = 225.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = 650.0 / 1184.0 * ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 310.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }
}
