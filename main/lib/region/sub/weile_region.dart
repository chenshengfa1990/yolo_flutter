import 'dart:ui';

import 'package:yolo_flutter/region/region_type.dart';

import '../../screenshot/screen_shot_manager.dart';

class WeileRegion {
  static Rect getRegion(RegionType regionType) {
    // if (regionType == RegionType.leftSkip) {
    //   return getLeftSkipRegion();
    // }
    return Rect.zero;
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
}
