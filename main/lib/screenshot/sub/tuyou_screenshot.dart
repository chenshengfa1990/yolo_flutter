import 'dart:io';

import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_xlog/flutter_xlog.dart';
import 'package:ncnn_plugin/export.dart';
import 'package:screenshot_plugin/export.dart';
import 'package:yolo_flutter/landlord/landlord_manager.dart';
import 'package:yolo_flutter/landlord_recorder.dart';
import 'package:yolo_flutter/overlay_window_widget.dart';
import 'package:yolo_flutter/screenshot/screen_shot_manager.dart';
import 'package:yolo_flutter/status/game_status_factory.dart';
import 'package:yolo_flutter/status/game_status_manager.dart';
import 'package:yolo_flutter/strategy_manager.dart';
import 'package:yolo_flutter/util/FileUtil.dart';

class TuyouScreenshot extends ScreenShotManager {
  static const String LOG_TAG = 'TuyouScreenshot';
  int emptyHandCardCount = 0;

  TuyouScreenshot(super.ncnnPlugin);

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
        if (statusManager.curGameStatus != GameStatus.gamePreparing) {
          XLog.i(LOG_TAG, "GameOver");
          screenShotCount = 0;
          statusManager.destroy();
          LandlordManager.destroy();
          StrategyManager().destroy();
          LandlordRecorder.destroy();
        } else {
          XLog.i(LOG_TAG, "useless screenshot file, deleted");
          File((screenshotModel?.filePath)!).delete();
          FlutterOverlayWindow.shareData([OverlayUpdateType.gameStatus.index, GameStatusManager.getGameStatusStr(GameStatus.gamePreparing)]);
        }
        return;
      }

      if (statusManager.curGameStatus == GameStatus.gamePreparing) {
        ///根据地主标记出现判断游戏是否准备好
        NcnnDetectModel? landlord = LandlordManager.getLandlord(detectList, screenshotModel!);
        List<NcnnDetectModel>? handCards = LandlordManager.getMyHandCard(detectList, screenshotModel);
        if (landlord != null && handCards != null) {
          GameStatus status = statusManager.initGameStatus(landlord, screenshotModel, detectList: detectList);
          if (status == GameStatus.gamePreparing) {
            return;
          } else {
            XLog.i(LOG_TAG, 'landLord appear');
            LandlordManager.initPlayerIdentify(landlord, screenshotModel);
            List<NcnnDetectModel>? threeCard = LandlordManager.getThreeCard(detectList, screenshotModel);
            if (threeCard?.length == 3) {
              XLog.i(LOG_TAG, 'Three card is ${LandlordManager.getCardsSorted(threeCard)}');
              notifyOverlayWindow(OverlayUpdateType.threeCard, models: threeCard);
            }
            LandlordRecorder.updateRecorder(LandlordManager.getMyHandCard(detectList, screenshotModel));
            await StrategyManager().tellServerInitialInfo();
            if (LandlordManager.leftPlayerIdentify == "landlord" || LandlordManager.rightPlayerIdentify == "landlord") {
              await Future.delayed(const Duration(milliseconds: 3000));
            } else if (LandlordManager.myIdentify == 'landlord') {
              StrategyManager().getServerSuggestion();
            }
          }
        } else {
          return;
        }
      }
      XLog.i(LOG_TAG, 'Current game status is ${statusManager.curGameStatus}');

      if (LandlordManager.threeCards?.length != 3) {
        List<NcnnDetectModel>? threeCard = LandlordManager.getThreeCard(detectList, screenshotModel!);
        if (threeCard?.length == 3) {
          XLog.i(LOG_TAG, 'Three card is ${LandlordManager.getCardsSorted(threeCard)}');
          notifyOverlayWindow(OverlayUpdateType.threeCard, models: threeCard);
        }
      }

      ///刷新手牌
      List<NcnnDetectModel>? myHandCards = LandlordManager.getMyHandCard(detectList, screenshotModel!);
      if (myHandCards?.isEmpty ?? true) {
        emptyHandCardCount++;
        if (emptyHandCardCount == 10) {
          XLog.i(LOG_TAG, "GameOver");
          screenShotCount = 0;
          statusManager.destroy();
          LandlordManager.destroy();
          StrategyManager().destroy();
          LandlordRecorder.destroy();
          return;
        }
      } else {
        emptyHandCardCount = 0;
      }
      XLog.i(LOG_TAG, 'show myHandCards ${LandlordManager.getCardsSorted(myHandCards)}');
      notifyOverlayWindow(OverlayUpdateType.handCard, models: myHandCards);

      ///计算下一个状态
      var nextStatus = statusManager.calculateNextGameStatus(detectList, screenshotModel);
      XLog.i(LOG_TAG, 'nextGameStatus is $nextStatus');

      if (nextStatus == GameStatus.myTurn) {
        notifyOverlayWindow(OverlayUpdateType.myOutCard, showString: "");
      } else if (nextStatus == GameStatus.leftTurn) {
        notifyOverlayWindow(OverlayUpdateType.leftOutCard, showString: "");
      } else if (nextStatus == GameStatus.rightTurn) {
        notifyOverlayWindow(OverlayUpdateType.rightOutCard, showString: "");
      }

      ///刷新游戏状态
      notifyOverlayWindow(OverlayUpdateType.gameStatus, showString: GameStatusManager.getGameStatusStr(nextStatus));

      statusManager.curGameStatus = nextStatus;
    }
  }
}
