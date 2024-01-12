
import 'package:ncnn_plugin/export.dart';
import 'package:screenshot_plugin/export.dart';

///区域识别管理
class RegionManager {
    static String LOG_TAG = 'RegionManager';
    ///三张牌区域
    static bool inThreeCardRegion(NcnnDetectModel model, ScreenshotModel screenshotModel) {
      double bottomYBorder = 110.0 / 1080.0 * screenshotModel.height;
      double leftXBorder = 580.0 / 2368.0 * screenshotModel.width;
      double rightXBorder = 1760.0 / 2368.0 * screenshotModel.width;
      if (model.y! < bottomYBorder && model.x! > leftXBorder && model.x! < rightXBorder) {
        return true;
      }
      return false;
    }

    ///手牌区域
    static bool inMyHandCardRegion(NcnnDetectModel model, ScreenshotModel screenshotModel) {
      double topYBorder = 600.0 / 1080.0 * screenshotModel.height;
      if (model.y! > topYBorder) {
        return true;
      }
      return false;
    }

    ///我的出牌区域
    static bool inMyOutCardRegion(NcnnDetectModel model, ScreenshotModel screenshotModel) {
      double topYBorder = 460.0 / 1080.0 * screenshotModel.height;
      double bottomYBorder = 620.0 / 1080.0 * screenshotModel.height;
      if (model.y! > topYBorder && model.y! < bottomYBorder) {
        return true;
      }
      return false;
    }

    ///右边玩家出牌区域
    static bool inRightPlayerOutCardRegion(NcnnDetectModel model, ScreenshotModel screenshotModel) {
    double leftXBorder = 1180.0 / 2368.0 * screenshotModel.width;
    // double rightXBorder = 1640.0 / 2368.0 * screenshotModel.width;
    double topYBorder = 170.0 / 1080.0 * screenshotModel.height;
    double bottomYBorder = 460.0 / 1080.0 * screenshotModel.height;
    if (model.x! > leftXBorder) {
      if (model.y! > topYBorder && model.y! < bottomYBorder) {
        return true;
      }
    }
    return false;
  }

  ///左边玩家出牌区域
    static bool inLeftPlayerOutCardRegion(NcnnDetectModel model, ScreenshotModel screenshotModel) {
    // double leftXBorder = 680.0 / 2368.0 * screenshotModel.width;
    double rightXBorder = 1180.0 / 2368.0 * screenshotModel.width;
    double topYBorder = 170.0 / 1080.0 * screenshotModel.height;
    double bottomYBorder = 460.0 / 1080.0 * screenshotModel.height;
    if (model.x! < rightXBorder) {
      if (model.y! > topYBorder && model.y! < bottomYBorder) {
        return true;
      }
    }
    return false;
  }

  ///左边玩家出牌区域
    static bool inLeftPlayerBuChuRegion(NcnnDetectModel model, ScreenshotModel screenshotModel) {
      // double leftXBorder = 680.0 / 2368.0 * screenshotModel.width;
      double rightXBorder = 900.0 / 2368.0 * screenshotModel.width;
      double topYBorder = 215.0 / 1080.0 * screenshotModel.height;
      double bottomYBorder = 460.0 / 1080.0 * screenshotModel.height;
      if (model.x! < rightXBorder) {
        if (model.y! > topYBorder && model.y! < bottomYBorder) {
          return true;
        }
      }
      return false;
    }

    ///右边玩家不出区域
    static bool inRightPlayerBuChuRegion(NcnnDetectModel model, ScreenshotModel screenshotModel) {
      double leftXBorder = 1400.0 / 2368.0 * screenshotModel.width;
      // double rightXBorder = 1640.0 / 2368.0 * screenshotModel.width;
      double topYBorder = 215.0 / 1080.0 * screenshotModel.height;
      double bottomYBorder = 460.0 / 1080.0 * screenshotModel.height;
      if (model.x! > leftXBorder) {
        if (model.y! > topYBorder && model.y! < bottomYBorder) {
          return true;
        }
      }
      return false;
    }

    ///我的不出区域
    static bool inMyCenterBuChuRegion(NcnnDetectModel model, ScreenshotModel screenshotModel) {
      double topYBorder = 460.0 / 1080.0 * screenshotModel.height;
      double bottomYBorder = 620.0 / 1080.0 * screenshotModel.height;
      double leftXBorder = 1000.0 / 2368.0 * screenshotModel.width;
      double rightXBorder = 1260.0 / 2368.0 * screenshotModel.width;
      if (model.y! > topYBorder && model.y! < bottomYBorder && model.x! > leftXBorder && model.x! < rightXBorder) {
        return true;
      }
      return false;
    }

    ///我是地主
    static bool inMyLandlordRegion(NcnnDetectModel model, ScreenshotModel screenshotModel) {
      double rightXBorder = 330.0 / 2368.0 * screenshotModel.width;
      double topYBorder = 670.0 / 1080.0 * screenshotModel.height;
      if (model.x! < rightXBorder && model.y! > topYBorder) {
        return true;
      }
      return false;
    }

    ///左边玩家是地主
    static bool inLeftPlayerLandlordRegion(NcnnDetectModel model, ScreenshotModel screenshotModel) {
      double rightXBorder = 430.0 / 2368.0 * screenshotModel.width;
      double bottomYBorder = 450.0 / 1080.0 * screenshotModel.height;
      if (model.x! < rightXBorder && model.y! < bottomYBorder) {
        return true;
      }
      return false;
    }

    ///右边玩家是地主
    static bool inRightPlayerLandlordRegion(NcnnDetectModel model, ScreenshotModel screenshotModel) {
      double leftXBorder = 1700.0 / 2368.0 * screenshotModel.width;
      double bottomYBorder = 450.0 / 1080.0 * screenshotModel.height;
      if (model.x! > leftXBorder && model.y! < bottomYBorder) {
        return true;
      }
      return false;
    }

    ///我不出牌
    static bool inMyBuchuRegion(List<NcnnDetectModel>? models, ScreenshotModel screenshotModel) {
      for(int i = 0; i < (models?.length ?? 0); i++) {
        if (inMyCenterBuChuRegion(models![i], screenshotModel)) {
          return true;
        }
      }
      return false;
    }

    ///右边玩家不出牌
    static bool inRightBuchuRegion(List<NcnnDetectModel>? models, ScreenshotModel screenshotModel) {
      for(int i = 0; i < (models?.length ?? 0); i++) {
        if (inRightPlayerBuChuRegion(models![i], screenshotModel)) {
          return true;
        }
      }
      return false;
    }

    ///左边玩家不出牌
    static bool inLeftBuchuRegion(List<NcnnDetectModel>? models, ScreenshotModel screenshotModel) {
      for(int i = 0; i < (models?.length ?? 0); i++) {
        if (inLeftPlayerBuChuRegion(models![i], screenshotModel)) {
          return true;
        }
      }
      return false;
    }
}