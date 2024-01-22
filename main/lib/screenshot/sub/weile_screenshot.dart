import 'dart:io';

import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_xlog/flutter_xlog.dart';
import 'package:ncnn_plugin/export.dart';
import 'package:screenshot_plugin/export.dart';
import 'package:yolo_flutter/landlord/landlord_manager.dart';
import 'package:yolo_flutter/landlord_recorder.dart';
import 'package:yolo_flutter/overlay_window_widget.dart';
import 'package:yolo_flutter/screenshot/screen_shot_manager.dart';
import 'package:yolo_flutter/status/game_status_weile.dart';
import 'package:yolo_flutter/strategy_manager.dart';
import 'package:yolo_flutter/util/FileUtil.dart';

class WeileScreenshot extends ScreenShotManager {
  static const String LOG_TAG = 'WeileScreenshot';

  WeileScreenshot(super.ncnnPlugin);

  @override
  Future<void> startScreenShot() async {
    ScreenshotModel? screenshotModel = await screenshotPlugin.takeScreenshot();

    if (screenshotModel?.filePath.isNotEmpty ?? false) {
      ScreenShotManager.width = (screenshotModel?.width ?? 0).toDouble();
      ScreenShotManager.height = (screenshotModel?.height ?? 0).toDouble();
      screenShotCount++;
      XLog.i(LOG_TAG,
          'Yolo screenshot $screenShotCount, width: ${screenshotModel?.width}, height: ${screenshotModel?.height}, path: ${screenshotModel?.filePath}');
      int before = DateTime.now().millisecondsSinceEpoch;
      var detectList = await ncnnPlugin.startDetectImage((screenshotModel?.filePath)!);
      int after = DateTime.now().millisecondsSinceEpoch;
      XLog.i(LOG_TAG,
          'detectFile $screenShotCount ${FileUtil.getFileName(screenshotModel?.filePath)} detect ${detectList?.length ?? 0} objects, useGPU: ${ncnnPlugin.useGPU}, cost ${after - before}ms');
      FlutterOverlayWindow.shareData([OverlayUpdateType.speed.index, after - before]);
      if (detectList?.isEmpty ?? true) {
        if (GameStatusMgrWeile.curGameStatus != GameStatusWeile.gamePreparing) {
          XLog.i(LOG_TAG, "GameOver");
          screenShotCount = 0;
          GameStatusMgrWeile.destroy();
          LandlordManager.destroy();
          StrategyManager.destroy();
          LandlordRecorder.destroy();
        } else {
          XLog.i(LOG_TAG, "useless screenshot file, deleted");
          File((screenshotModel?.filePath)!).delete();
          FlutterOverlayWindow.shareData([OverlayUpdateType.gameStatus.index, GameStatusMgrWeile.getGameStatusStr(GameStatusWeile.gamePreparing)]);
        }
        return;
      }

      if (GameStatusMgrWeile.curGameStatus == GameStatusWeile.gamePreparing) {
        ///根据地主标记出现判断游戏是否准备好
        NcnnDetectModel? landlord = LandlordManager.getLandlord(detectList, screenshotModel!);
        List<NcnnDetectModel>? handCards = LandlordManager.getMyHandCard(detectList, screenshotModel);
        if (landlord != null && handCards != null) {
          GameStatusWeile status = GameStatusMgrWeile.initGameStatus(landlord, screenshotModel, detectList);
          if (status == GameStatusWeile.gamePreparing) {
            return;
          } else {
            XLog.i(LOG_TAG, 'landLord appear');
            LandlordManager.initPlayerIdentify(landlord, screenshotModel);
            LandlordRecorder.updateRecorder(LandlordManager.getMyHandCard(detectList, screenshotModel));
            if (LandlordManager.leftPlayerIdentify == "landlord" || LandlordManager.rightPlayerIdentify == "landlord") {
              await Future.delayed(const Duration(milliseconds: 3000));
            }
          }
        } else {
          return;
        }
      }
      XLog.i(LOG_TAG, 'Current game status is ${GameStatusMgrWeile.curGameStatus}');
      // if (LandlordManager.threeCards?.length != 3) {
      //   List<NcnnDetectModel>? threeCard = LandlordManager.getThreeCard(detectList, screenshotModel!);
      //   if (threeCard?.length == 3) {
      //     XLog.i(LOG_TAG, 'Three card is ${LandlordManager.getCardsSorted(threeCard)}');
      //     notifyOverlayWindow(OverlayUpdateType.threeCard, models: threeCard);
      //   }
      // }

      ///刷新手牌
      List<NcnnDetectModel>? myHandCards = LandlordManager.getMyHandCard(detectList, screenshotModel!);
      if (myHandCards?.isEmpty ?? true) {
        XLog.i(LOG_TAG, "GameOver");
        screenShotCount = 0;
        GameStatusMgrWeile.destroy();
        LandlordManager.destroy();
        StrategyManager.destroy();
        LandlordRecorder.destroy();
      }
      XLog.i(LOG_TAG, 'show myHandCards ${LandlordManager.getCardsSorted(myHandCards)}');
      notifyOverlayWindow(OverlayUpdateType.handCard, models: myHandCards);

      ///计算下一个状态
      var nextStatus = GameStatusMgrWeile.calculateNextGameStatus(detectList, screenshotModel);
      // XLog.i(LOG_TAG, 'nextStatus is $nextStatus');

      ///刷新游戏状态
      // notifyOverlayWindow(OverlayUpdateType.gameStatus, showString: GameStatusMgrWeile.getGameStatusStr(nextStatus));

      GameStatusMgrWeile.curGameStatus = nextStatus;
    }
  }
}
