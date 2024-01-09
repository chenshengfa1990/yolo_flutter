import 'dart:async';
import 'dart:io';

import 'package:cpu_reader/cpu_reader.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_xlog/flutter_xlog.dart';
import 'package:ncnn_plugin/export.dart';
import 'package:screenshot_plugin/export.dart';
import 'package:yolo_flutter/landlord_recorder.dart';
import 'package:yolo_flutter/strategy_manager.dart';
import 'package:yolo_flutter/util/FileUtil.dart';

import 'game_status_manager.dart';
import 'landlord_manager.dart';
import 'overlay_window_widget.dart';

class ScreenShotManager {
  static const String LOG_TAG = 'ScreenShotManager';
  late ScreenshotPlugin screenshotPlugin;
  late NcnnPlugin ncnnPlugin;
  int screenShotCount = 0;
  int detectCount = 0;
  bool isGameRunning = false;

  ScreenShotManager(this.ncnnPlugin) {
    screenshotPlugin = ScreenshotPlugin();
  }

  Future<bool?> requestPermission() async {
    return await screenshotPlugin.requestPermission();
  }

  void startScreenshotRepeat() async {
    isGameRunning = true;
    while (isGameRunning) {
      await screenshotRepeat();
    }
  }

  void stopScreenshotRepeat() {
    isGameRunning = false;
  }

  Future<void> screenshotRepeat() async {
    ScreenshotModel? screenshotModel = await screenshotPlugin.takeScreenshot();

    if (screenshotModel?.filePath.isNotEmpty ?? false) {
      screenShotCount++;
      XLog.i(LOG_TAG,
          'Yolo screenshot $screenShotCount, width: ${screenshotModel?.width}, height: ${screenshotModel?.height}, path: ${screenshotModel?.filePath}');
      int before = DateTime.now().millisecondsSinceEpoch;
      var detectList = await ncnnPlugin.startDetectImage((screenshotModel?.filePath)!);
      int after = DateTime.now().millisecondsSinceEpoch;
      XLog.i(LOG_TAG,
          'detectFile $screenShotCount ${FileUtil.getFileName(screenshotModel?.filePath)} detect ${detectList?.length ?? 0} objects, useGPU: ${ncnnPlugin.useGPU}, cost ${after - before}ms');
      if (detectList?.isEmpty ?? true) {
        if (GameStatusManager.curGameStatus != GameStatus.gamePreparing) {
          XLog.i(LOG_TAG, "GameOver");
          screenShotCount = 0;
          GameStatusManager.destroy();
          LandlordManager.destroy();
          StrategyManager.destroy();
          LandlordRecorder.destroy();
        } else {
          XLog.i(LOG_TAG, "useless screenshot file, deleted");
          File((screenshotModel?.filePath)!).delete();
          FlutterOverlayWindow.shareData([OverlayUpdateType.gameStatus.index, GameStatusManager.getGameStatusStr(GameStatus.gamePreparing)]);
        }
        return;
      }

      if (GameStatusManager.curGameStatus == GameStatus.gamePreparing) {
        ///根据地主标记出现判断游戏是否准备好
        NcnnDetectModel? landlord = LandlordManager.getLandlord(detectList, screenshotModel!);
        if (landlord != null) {
          GameStatus status = GameStatusManager.initGameStatus(landlord, screenshotModel);
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
          }
        } else {
          return;
        }
      }
      XLog.i(LOG_TAG, 'Current game status is ${GameStatusManager.curGameStatus}');
      if (LandlordManager.threeCards?.length != 3) {
        List<NcnnDetectModel>? threeCard = LandlordManager.getThreeCard(detectList, screenshotModel!);
        if (threeCard?.length == 3) {
          XLog.i(LOG_TAG, 'Three card is ${LandlordManager.getCardsSorted(threeCard)}');
          notifyOverlayWindow(OverlayUpdateType.threeCard, models: threeCard);
        }
      }

      ///刷新手牌
      List<NcnnDetectModel>? myHandCards = LandlordManager.getMyHandCard(detectList, screenshotModel!);
      notifyOverlayWindow(OverlayUpdateType.handCard, models: myHandCards);

      ///刷新我的出牌
      List<NcnnDetectModel>? myOutCards = LandlordManager.getMyOutCard(detectList, screenshotModel);
      notifyOverlayWindow(OverlayUpdateType.myOutCard, models: myOutCards);

      ///刷新左边玩家出牌
      List<NcnnDetectModel>? leftPlayerCards = LandlordManager.getLeftPlayerOutCard(detectList, screenshotModel);
      notifyOverlayWindow(OverlayUpdateType.leftOutCard, models: leftPlayerCards);

      ///刷新右边玩家出牌
      List<NcnnDetectModel>? rightPlayerCards = LandlordManager.getRightPlayerOutCard(detectList, screenshotModel);
      notifyOverlayWindow(OverlayUpdateType.rightOutCard, models: rightPlayerCards);

      ///计算下一个状态
      var nextStatus = GameStatusManager.calculateNextGameStatus(detectList, screenshotModel);
      XLog.i(LOG_TAG, 'nextStatus is $nextStatus');

      ///刷新游戏状态
      notifyOverlayWindow(OverlayUpdateType.gameStatus, showString: GameStatusManager.getGameStatusStr(nextStatus));

      ///请求出牌策略，告知后台牌面信息
      StrategyManager.getLandlordStrategy(nextStatus, detectList, screenshotModel);

      GameStatusManager.curGameStatus = nextStatus;

      ///根据左右两边玩家出牌，更新记牌器
      if (nextStatus == GameStatus.leftDone) {
        XLog.i(LOG_TAG, 'leftPlayerDone, updateRecorder, outCard: ${LandlordManager.getCardsSorted(GameStatusManager.leftOutCardBuff)}');
        LandlordRecorder.updateRecorder(GameStatusManager.leftOutCardBuff);
        GameStatusManager.leftOutCardBuff = null; //用完即恢复，不影响下一次
      }
      if (nextStatus == GameStatus.rightDone) {
        XLog.i(LOG_TAG, 'rightPlayerDone, updateRecorder, outCard: ${LandlordManager.getCardsSorted(GameStatusManager.rightOutCardBuff)}');
        LandlordRecorder.updateRecorder(GameStatusManager.rightOutCardBuff);
        GameStatusManager.rightOutCardBuff = null;
      }
      if (nextStatus == GameStatus.iDone) {
        XLog.i(LOG_TAG, 'iDone, myOutCard: ${LandlordManager.getCardsSorted(GameStatusManager.myOutCardBuff)}');
        GameStatusManager.myOutCardBuff = null;
      }
      if (nextStatus == GameStatus.iDone || nextStatus == GameStatus.iSkip) {
        notifyOverlayWindow(OverlayUpdateType.suggestion, showString: "");
      }

      ///轮到我出牌时，暂停一下，等牌面动画完成后再截图，否则可能出现错误状态
      if (nextStatus == GameStatus.myTurn) {
        XLog.i(LOG_TAG, 'myTurn, restart screenshot timer');
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  void notifyOverlayWindow(OverlayUpdateType updateType, {List<NcnnDetectModel>? models, String? showString}) {
    String showStr = (models != null ? LandlordManager.getCardsSorted(models) : showString) ?? '';
    FlutterOverlayWindow.shareData([updateType.index, showStr]);
  }

  void destroy() {
    screenshotPlugin.stopScreenshot();
    screenShotCount = 0;
    detectCount = 0;
  }
}
