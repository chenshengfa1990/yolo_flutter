import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_xlog/flutter_xlog.dart';
import 'package:ncnn_plugin/export.dart';
import 'package:screenshot_plugin/export.dart';
import 'package:yolo_flutter/region/region_manager.dart';
import 'package:yolo_flutter/strategy_manager.dart';

import '../landlord/landlord_manager.dart';
import '../overlay_window_widget.dart';

enum GameStatus {
  gamePreparing, // 游戏准备中
  gameReady, //游戏准备好, 地主已分配

  myTurn, //轮到我出牌，我的出牌按钮出现
  iSkip, //我跳过，不出牌
  iDone, //我已出牌

  rightTurn, //轮到右边玩家出牌
  rightSkip, //右边玩家跳过，不出牌
  rightDone, //右边玩家已出牌

  leftTurn, //轮到左边玩家出牌
  leftSkip, //左边玩家跳过，不出牌
  leftDone, //左边玩家已出牌

  gameOver, //游戏结束
}

enum BuffWho {
  my,
  left,
  right,
}

///状态管理
abstract class GameStatusManager {
  static String LOG_TAG = 'GameStatusManager';
  GameStatus curGameStatus = GameStatus.gamePreparing;
  static List<String> gameStatusStr = ['准备中', '地主已分配', '我出牌中', '我不出', '我已出牌', '下家出牌中', '下家不出', '下家已出牌', '上家出牌中', '上家不出', '上家已出牌', '游戏结束'];
  List<NcnnDetectModel>? myOutCardBuff;
  List<NcnnDetectModel>? leftOutCardBuff;
  List<NcnnDetectModel>? rightOutCardBuff;

  List<NcnnDetectModel>? lastRightOutCard;
  List<NcnnDetectModel>? lastLeftOutCard;
  List<NcnnDetectModel>? lastMyOutCard;

  List<NcnnDetectModel> myHistoryOutCard = <NcnnDetectModel>[];
  List<NcnnDetectModel> leftHistoryOutCard = [];
  List<NcnnDetectModel> rightHistoryOutCard = [];

  bool myBuChu = false;

  ///是否打了不出
  bool leftBuChu = false;
  bool rightBuChu = false;
  int myOutCardBuffLength = 0;
  int myEmptyBuffLength = 0;

  ///出牌缓冲区长度，长度越长，准确率越高，相应的，实时性降低
  int leftOutCardBuffLength = 0;
  int leftEmptyBuffLength = 0;

  ///出牌缓冲区长度，长度越长，准确率越高，相应的，实时性降低
  int rightOutCardBuffLength = 0;
  int rightEmptyBuffLength = 0;

  GameStatus initGameStatus(NcnnDetectModel landlord, ScreenshotModel screenshotModel, {List<NcnnDetectModel>? detectList});

  GameStatus calculateNextGameStatus(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel);

  int getOutCardBuffLength(BuffWho who);

  static String getGameStatusStr(GameStatus status) {
    return gameStatusStr[status.index];
  }

  static void notifyOverlayWindow(OverlayUpdateType updateType, {List<NcnnDetectModel>? models, String? showString}) {
    String showStr = (models != null ? LandlordManager.getCardsSorted(models) : showString) ?? '';
    FlutterOverlayWindow.shareData([updateType.index, showStr]);
  }

  void destroy() {
    curGameStatus = GameStatus.gamePreparing;
    lastLeftOutCard = null;
    lastRightOutCard = null;
    lastMyOutCard = null;
    myOutCardBuff = null;
    leftOutCardBuff = null;
    rightOutCardBuff = null;
    myHistoryOutCard.clear();
    leftHistoryOutCard.clear();
    rightHistoryOutCard.clear();
    myOutCardBuffLength = 0;
    leftOutCardBuffLength = 0;
    rightOutCardBuffLength = 0;
    myEmptyBuffLength = 0;
    leftEmptyBuffLength = 0;
    rightEmptyBuffLength = 0;
    myBuChu = false;
    leftBuChu = false;
    rightBuChu = false;
    FlutterOverlayWindow.shareData([OverlayUpdateType.gameStatus.index, getGameStatusStr(GameStatus.gameOver)]);
  }
}
