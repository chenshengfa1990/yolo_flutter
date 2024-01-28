import 'dart:io';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_xlog/flutter_xlog.dart';
import 'package:ncnn_plugin/ncnn_detect_model.dart';
import 'package:screenshot_plugin/screenshot_model.dart';
import 'package:yolo_flutter/status/game_status_factory.dart';
import 'package:yolo_flutter/status/game_status_manager.dart';

import '../../landlord/landlord_manager.dart';
import '../../landlord_recorder.dart';
import '../../overlay_window_widget.dart';
import '../../strategy_manager.dart';
import '../../util/FileUtil.dart';
import '../screen_shot_manager.dart';

class HuanleScreenshot extends ScreenShotManager {
  static const String LOG_TAG = 'HuanleScreenshot';

  HuanleScreenshot(super.ncnnPlugin);

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
        if (landlord != null) {
          GameStatus status = statusManager.initGameStatus(landlord, screenshotModel);
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
            if (LandlordManager.myIdentify == 'landlord') {
              ///首次告知信息，需要await，第二次请求策略，为了减少时间，不必await
              await StrategyManager().getServerSuggestion();
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
      XLog.i(LOG_TAG, 'show myHandCards ${LandlordManager.getCardsSorted(myHandCards)}');
      notifyOverlayWindow(OverlayUpdateType.handCard, models: myHandCards);

      ///计算下一个状态
      var nextStatus = statusManager.calculateNextGameStatus(detectList, screenshotModel);
      XLog.i(LOG_TAG, 'nextGameStatus is $nextStatus');

      ///刷新游戏状态
      notifyOverlayWindow(OverlayUpdateType.gameStatus, showString: GameStatusManager.getGameStatusStr(nextStatus));

      statusManager.curGameStatus = nextStatus;

      ///轮到我出牌时，暂停一下，等牌面动画完成后再截图，否则可能出现错误状态
      if (nextStatus == GameStatus.myTurn || nextStatus == GameStatus.leftTurn || nextStatus == GameStatus.rightTurn) {
        if (nextStatus == GameStatus.myTurn) {
          notifyOverlayWindow(OverlayUpdateType.myOutCard, showString: "");
        } else if (nextStatus == GameStatus.leftTurn) {
          notifyOverlayWindow(OverlayUpdateType.leftOutCard, showString: "");
        } else if (nextStatus == GameStatus.rightTurn) {
          notifyOverlayWindow(OverlayUpdateType.rightOutCard, showString: "");
        }

        if (firstCheck) {
          if (nextStatus == GameStatus.myTurn) {
            XLog.i(LOG_TAG, 'myTurn, sleep 1200ms');
          } else if (nextStatus == GameStatus.rightTurn) {
            XLog.i(LOG_TAG, 'rightTurn, sleep 1200ms');
          } else if (nextStatus == GameStatus.leftTurn) {
            XLog.i(LOG_TAG, 'leftTurn, sleep 1200ms');
          }
          firstCheck = false;
          await Future.delayed(const Duration(milliseconds: 1200));
        }
      }
      if (nextStatus == GameStatus.iDone ||
          nextStatus == GameStatus.iSkip ||
          nextStatus == GameStatus.leftSkip ||
          nextStatus == GameStatus.leftDone ||
          nextStatus == GameStatus.rightSkip ||
          nextStatus == GameStatus.rightDone) {
        firstCheck = true;
      }
    }
  }
}
