import 'dart:ui';

import 'package:yolo_flutter/region/region_type.dart';

import '../../screen_shot_manager.dart';

class HuanleRegion {
  static Rect getThreeCardRegion() {
    double xLeftTop = 290.0 / 1184.0 * ScreenShotManager.width; //左上角x坐标
    double yLeftTop = 0; //左上角y坐标
    double xRightBottom = 880.0 / 1184.0 * ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 55.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
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
    double yLeftTop = 230.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 310.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getRightPlayerOutCardRegion() {
    double xLeftTop = 590.0 / 1184.0 * ScreenShotManager.width; //左上角x坐标
    double yLeftTop = 85.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 230.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getLeftPlayerOutCardRegion() {
    double xLeftTop = 0; //左上角x坐标
    double yLeftTop = 85.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = 540.0 / 1184.0 * ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 230.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getRightPlayerBuchuRegion() {
    double xLeftTop = 700.0 / 1184.0 * ScreenShotManager.width; //左上角x坐标
    double yLeftTop = 107.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 230.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getLeftPlayerBuchuRegion() {
    double xLeftTop = 0; //左上角x坐标
    double yLeftTop = 107.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = 450.0 / 1184.0 * ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 230.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getMyBuchuRegion() {
    double xLeftTop = 500.0 / 1184.0 * ScreenShotManager.width; //左上角x坐标
    double yLeftTop = 230.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = 630.0 / 1184.0 * ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 310.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getMyLandlordRegion() {
    double xLeftTop = 0; //左上角x坐标
    double yLeftTop = 335.0 / 540.0 * ScreenShotManager.height; //左上角y坐标
    double xRightBottom = 165.0 / 1184.0 * ScreenShotManager.width; //右下角x坐标
    double yRightBottom = ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getLeftLandlordRegion() {
    double xLeftTop = 0; //左上角x坐标
    double yLeftTop = 0; //左上角y坐标
    double xRightBottom = 215.0 / 1184.0 * ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 225.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }

  static Rect getRightLandlordRegion() {
    double xLeftTop = 850.0 / 1184.0 * ScreenShotManager.width; //左上角x坐标
    double yLeftTop = 0; //左上角y坐标
    double xRightBottom = ScreenShotManager.width; //右下角x坐标
    double yRightBottom = 225.0 / 540.0 * ScreenShotManager.height; //右下角y坐标
    return Rect.fromLTRB(xLeftTop, yLeftTop, xRightBottom, yRightBottom);
  }
}
