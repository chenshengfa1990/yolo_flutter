import 'dart:ui';

import 'package:yolo_flutter/region/region_type.dart';

import '../../screenshot/screen_shot_manager.dart';

class TuyouRegion {
  static Rect getThreeCardRegion() {
    double xLeftTop = 525.0 / 1184.0 * ScreenShotManager.width; //左上角x坐标
    double yLeftTop = 0; //左上角y坐标
    double xRightBottom = 720.0 / 1184.0 * ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 60.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getMyHandCardRegion() {
    double xLeftTop = 0; //左上角x坐标
    double yLeftTop = 300.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = ScreenShotManager.width; //右下角x坐标
    double yRightBottom = ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getMyOutCardRegion() {
    double xLeftTop = 0; //左上角x坐标
    double yLeftTop = 200.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 285.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getRightPlayerOutCardRegion() {
    double xLeftTop = 590.0 / 1184.0 * ScreenShotManager.width; //左上角x坐标
    double yLeftTop = 80.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = 1000.0 / 1184.0 * ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 200.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getLeftPlayerOutCardRegion() {
    double xLeftTop = 180.0 / 1184.0 * ScreenShotManager.width; //左上角x坐标
    double yLeftTop = 80.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = 590.0 / 1184.0 * ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 200.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getMyLandlordRegion() {
    double xLeftTop = 135.0 / 1184.0 * ScreenShotManager.width; //左上角x坐标
    double yLeftTop = 415.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = 260.0 / 1184.0 * ScreenShotManager.width; //右下角x坐标
    double yRightBottom = ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getLeftLandlordRegion() {
    double xLeftTop = 130.0 / 1184.0 * ScreenShotManager.width; //左上角x坐标
    double yLeftTop = 80.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = 250.0 / 1184.0 * ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 175.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getRightLandlordRegion() {
    double xLeftTop = 920.0 / 1184.0 * ScreenShotManager.width; //左上角x坐标
    double yLeftTop = 80.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = 1040.0 / 1184.0 * ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 175.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getRightPlayerBuchuRegion() {
    double xLeftTop = 825.0 / 1184.0 * ScreenShotManager.width; //左上角x坐标
    double yLeftTop = 117.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = 960.0 / 1184.0 * ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 220.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getLeftPlayerBuchuRegion() {
    double xLeftTop = 210.0 / 1184.0 * ScreenShotManager.width; //左上角x坐标
    double yLeftTop = 117.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = 350.0 / 1184.0 * ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 220.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getMyBuchuRegion() {
    double xLeftTop = 510.0 / 1184.0 * ScreenShotManager.width; //左上角x坐标
    double yLeftTop = 225.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = 670.0 / 1184.0 * ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 310.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }
}
