import 'dart:ui';

import 'package:ncnn_plugin/export.dart';
import 'package:screenshot_plugin/export.dart';
import 'package:yolo_flutter/region/region_factory.dart';

///区域识别管理
class RegionManager {
  static String LOG_TAG = 'RegionManager';

  ///三张牌区域
  static bool inThreeCardRegion(NcnnDetectModel model, ScreenshotModel screenshotModel) {
    Rect region = RegionFactory.getThreeCardRegion();
    if (model.y! < region.bottom && model.x! > region.left && model.x! < region.right) {
      return true;
    }
    return false;
  }

  ///手牌区域
  static bool inMyHandCardRegion(NcnnDetectModel model, ScreenshotModel screenshotModel) {
    Rect region = RegionFactory.getMyHandCardRegion();
    if (model.y! > region.top) {
      return true;
    }
    return false;
  }

  ///我的出牌区域
  static bool inMyOutCardRegion(NcnnDetectModel model, ScreenshotModel screenshotModel) {
    Rect region = RegionFactory.getMyOutCardRegion();
    if (model.y! > region.top && model.y! < region.bottom) {
      return true;
    }
    return false;
  }

  ///右边玩家出牌区域
  static bool inRightPlayerOutCardRegion(NcnnDetectModel model, ScreenshotModel screenshotModel) {
    Rect region = RegionFactory.getRightPlayerOutCardRegion();
    if (model.x! > region.left && model.x! < region.right) {
      if (model.y! > region.top && model.y! < region.bottom) {
        return true;
      }
    }
    return false;
  }

  ///左边玩家出牌区域
  static bool inLeftPlayerOutCardRegion(NcnnDetectModel model, ScreenshotModel screenshotModel) {
    Rect region = RegionFactory.getLeftPlayerOutCardRegion();
    if (model.x! < region.right && model.x! > region.left) {
      if (model.y! > region.top && model.y! < region.bottom) {
        return true;
      }
    }
    return false;
  }

  ///左边玩家出牌区域
  static bool inLeftPlayerBuChuRegion(NcnnDetectModel model, ScreenshotModel screenshotModel) {
    Rect region = RegionFactory.getLeftPlayerBuchuRegion();
    if (model.x! < region.right) {
      if (model.y! > region.top && model.y! < region.bottom) {
        return true;
      }
    }
    return false;
  }

  ///右边玩家不出区域
  static bool inRightPlayerBuChuRegion(NcnnDetectModel model, ScreenshotModel screenshotModel) {
    Rect region = RegionFactory.getRightPlayerBuchuRegion();
    if (model.x! > region.left) {
      if (model.y! > region.top && model.y! < region.bottom) {
        return true;
      }
    }
    return false;
  }

  ///我的不出区域
  static bool inMyCenterBuChuRegion(NcnnDetectModel model, ScreenshotModel screenshotModel) {
    Rect region = RegionFactory.getMyBuchuRegion();
    if (model.y! > region.top && model.y! < region.bottom && model.x! > region.left && model.x! < region.right) {
      return true;
    }
    return false;
  }

  ///我是地主
  static bool inMyLandlordRegion(NcnnDetectModel model, ScreenshotModel screenshotModel) {
    Rect region = RegionFactory.getMyLandlordRegion();
    if (model.x! < region.right && model.y! > region.top) {
      return true;
    }
    return false;
  }

  ///左边玩家是地主
  static bool inLeftPlayerLandlordRegion(NcnnDetectModel model, ScreenshotModel screenshotModel) {
    Rect region = RegionFactory.getLeftLandlordRegion();
    if (model.x! < region.right && model.y! < region.bottom) {
      return true;
    }
    return false;
  }

  ///右边玩家是地主
  static bool inRightPlayerLandlordRegion(NcnnDetectModel model, ScreenshotModel screenshotModel) {
    Rect region = RegionFactory.getRightLandlordRegion();
    if (model.x! > region.left && model.y! < region.bottom) {
      return true;
    }
    return false;
  }

  ///我不出牌
  static bool inMyBuchuRegion(List<NcnnDetectModel>? models, ScreenshotModel screenshotModel) {
    for (int i = 0; i < (models?.length ?? 0); i++) {
      if (inMyCenterBuChuRegion(models![i], screenshotModel)) {
        return true;
      }
    }
    return false;
  }

  ///右边玩家不出牌
  static bool inRightBuchuRegion(List<NcnnDetectModel>? models, ScreenshotModel screenshotModel) {
    for (int i = 0; i < (models?.length ?? 0); i++) {
      if (inRightPlayerBuChuRegion(models![i], screenshotModel)) {
        return true;
      }
    }
    return false;
  }

  ///左边玩家不出牌
  static bool inLeftBuchuRegion(List<NcnnDetectModel>? models, ScreenshotModel screenshotModel) {
    for (int i = 0; i < (models?.length ?? 0); i++) {
      if (inLeftPlayerBuChuRegion(models![i], screenshotModel)) {
        return true;
      }
    }
    return false;
  }
}
