
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:ncnn_plugin/export.dart';
import 'package:ncnn_plugin/ncnn_plugin.dart';
import 'package:screenshot_plugin/export.dart';
import 'package:yolo_flutter/strategy_manager.dart';

import 'game_status.dart';
import 'landlord_manager.dart';

class ScreenShotManager {
  late ScreenshotPlugin screenshotPlugin;
  Timer? screenshotTimer;
  late NcnnPlugin ncnnPlugin;

  ScreenShotManager(this.ncnnPlugin) {
    screenshotPlugin = ScreenshotPlugin();
  }

  Future<bool?> requestPermission() async {
    return await screenshotPlugin.requestPermission();
  }

  void startScreenshotPeriodic() {
    screenshotTimer = Timer.periodic(const Duration(milliseconds: 500), timerCallback);
  }

  Future<void> timerCallback(Timer timer) async {
    ScreenshotModel? screenshotModel = await screenshotPlugin.takeScreenshot();
    print('yolo screenshot ----- width: ${screenshotModel?.width}, height: ${screenshotModel?.height}, path: ${screenshotModel?.filePath}');
    if (screenshotModel?.filePath.isNotEmpty ?? false) {
      var detectList = await ncnnPlugin.startDetectImage((screenshotModel?.filePath)!);
      if (detectList?.isEmpty ?? true) {
        File((screenshotModel?.filePath)!).delete();
        return;
      }
      if (GameStatusManager.curGameStatus == GameStatus.gamePreparing) {
        NcnnDetectModel? landlord = LandlordManager.getLandlord(detectList, screenshotModel!);
        if (landlord != null) {
          GameStatus status = GameStatusManager.initGameStatus(landlord, screenshotModel);
          if (status == GameStatus.gamePreparing) {
            return;
          } else {
            LandlordManager.initPlayerIdentify(landlord, screenshotModel);
          }
        } else {
          return;
        }
      }
      List<NcnnDetectModel>? threeCards = LandlordManager.getThreeCard(detectList, screenshotModel!);
      List<NcnnDetectModel>? myHandCards = LandlordManager.getMyHandCard(detectList, screenshotModel);
      List<NcnnDetectModel>? myOutCards = LandlordManager.getMyOutCard(detectList, screenshotModel!);
      List<NcnnDetectModel>? leftPlayerCards = LandlordManager.getLeftPlayerOutCard(detectList, screenshotModel!);
      List<NcnnDetectModel>? rightPlayerCards = LandlordManager.getRightPlayerOutCard(detectList, screenshotModel!);

      print('chenshengfa current status: ${GameStatusManager.getGameStatusStr(GameStatusManager.curGameStatus)}');
      var nextStatus = GameStatusManager.calculateNextGameStatus(detectList, screenshotModel);
      StrategyManager.getLandlordStrategy(nextStatus, detectList, screenshotModel);
      String gameStatusStr = GameStatusManager.getGameStatusStr(nextStatus);
      print('chenshengfa next status: $gameStatusStr');
      GameStatusManager.curGameStatus = nextStatus;

      String threeCardStr = LandlordManager.getCardsSorted(threeCards);
      String myHandCardStr = LandlordManager.getCardsSorted(myHandCards);
      String myOutCardStr = LandlordManager.getCardsSorted(myOutCards);
      String leftPlayerCardStr = LandlordManager.getCardsSorted(leftPlayerCards);
      String rightPlayerCardStr = LandlordManager.getCardsSorted(rightPlayerCards);
      await FlutterOverlayWindow.shareData([gameStatusStr, threeCardStr, leftPlayerCardStr, rightPlayerCardStr, myHandCardStr, myOutCardStr]);
      if (nextStatus == GameStatus.myTurn) {
        screenshotTimer?.cancel();
        screenshotTimer = null;
        screenshotTimer = Timer.periodic(const Duration(milliseconds: 500), timerCallback);
      }
    }
  }

  void destroy() {
    screenshotTimer?.cancel();
    screenshotTimer = null;
    screenshotPlugin.stopScreenshot();
  }
}
