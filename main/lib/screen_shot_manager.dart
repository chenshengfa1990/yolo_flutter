import 'dart:async';
import 'dart:io';

import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_xlog/flutter_xlog.dart';
import 'package:ncnn_plugin/export.dart';
import 'package:screenshot_plugin/export.dart';
import 'package:yolo_flutter/landlord/landlord_type.dart';
import 'package:yolo_flutter/landlord_recorder.dart';
import 'package:yolo_flutter/status/game_status_weile.dart';
import 'package:yolo_flutter/strategy_manager.dart';
import 'package:yolo_flutter/util/FileUtil.dart';

import 'status/game_status_manager.dart';
import 'landlord/landlord_manager.dart';
import 'overlay_window_widget.dart';

class ScreenShotManager {
  static const String LOG_TAG = 'ScreenShotManager';
  late ScreenshotPlugin screenshotPlugin;
  late NcnnPlugin ncnnPlugin;
  static double width = 0;
  static double height = 0;
  int screenShotCount = 0;
  int detectCount = 0;
  bool isGameRunning = false;
  bool firstCheck = true;

  ScreenShotManager(this.ncnnPlugin) {
    screenshotPlugin = ScreenshotPlugin();
  }

  Future<bool?> requestPermission() async {
    return await screenshotPlugin.requestPermission();
  }

  void startScreenshotRepeat() async {
    isGameRunning = true;
    if (LandlordManager.curLandlordType == LandlordType.huanle) {
      while (isGameRunning) {
        await screenshotRepeat();
      }
    } else if (LandlordManager.curLandlordType == LandlordType.weile) {
      while (isGameRunning) {
        await screenshotWeile();
      }
    }
  }

  void stopScreenshotRepeat() {
    isGameRunning = false;
  }

  Future<void> screenshotRepeat() async {
    ScreenshotModel? screenshotModel = await screenshotPlugin.takeScreenshot();

    if (screenshotModel?.filePath.isNotEmpty ?? false) {
      width = (screenshotModel?.width ?? 0).toDouble();
      height = (screenshotModel?.height ?? 0).toDouble();
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
            if (LandlordManager.myIdentify == 'landlord') {
              StrategyManager.getServerSuggestion();
              StrategyManager.getServerSuggestion();
            }
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
      XLog.i(LOG_TAG, 'show myHandCards ${LandlordManager.getCardsSorted(myHandCards)}');
      notifyOverlayWindow(OverlayUpdateType.handCard, models: myHandCards);

      ///计算下一个状态
      var nextStatus = GameStatusManager.calculateNextGameStatus(detectList, screenshotModel);
      XLog.i(LOG_TAG, 'nextStatus is $nextStatus');

      ///刷新游戏状态
      notifyOverlayWindow(OverlayUpdateType.gameStatus, showString: GameStatusManager.getGameStatusStr(nextStatus));

      GameStatusManager.curGameStatus = nextStatus;

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

  Future<void> screenshotWeile() async {
    ScreenshotModel? screenshotModel = await screenshotPlugin.takeScreenshot();

    if (screenshotModel?.filePath.isNotEmpty ?? false) {
      width = (screenshotModel?.width ?? 0).toDouble();
      height = (screenshotModel?.height ?? 0).toDouble();
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
        if (landlord != null) {
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

  void notifyOverlayWindow(OverlayUpdateType updateType, {List<NcnnDetectModel>? models, String? showString}) {
    String showStr = (models != null ? LandlordManager.getCardsSorted(models) : showString) ?? '';
    FlutterOverlayWindow.shareData([updateType.index, showStr]);
  }

  void destroy() {
    screenshotPlugin.stopScreenshot();
    screenShotCount = 0;
    detectCount = 0;
    firstCheck = true;
  }
}
