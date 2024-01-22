import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_xlog/flutter_xlog.dart';
import 'package:ncnn_plugin/export.dart';
import 'package:screenshot_plugin/export.dart';
import 'package:yolo_flutter/region/region_manager.dart';

import '../landlord/landlord_manager.dart';
import '../landlord_recorder.dart';
import '../overlay_window_widget.dart';

enum GameStatusWeile {
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

///状态管理
class GameStatusMgrWeile {
  static String LOG_TAG = 'GameStatusWeile';
  static GameStatusWeile curGameStatus = GameStatusWeile.gamePreparing;
  static List<String> gameStatusStr = ['准备中', '地主已分配', '我出牌中', '我不出', '我已出牌', '下家出牌中', '下家不出', '下家已出牌', '上家出牌中', '上家不出', '上家已出牌', '游戏结束'];
  static List<NcnnDetectModel>? myOutCardBuff;
  static List<NcnnDetectModel>? leftOutCardBuff;
  static List<NcnnDetectModel>? rightOutCardBuff;
  static List<NcnnDetectModel>? lastRightOutCard;
  static List<NcnnDetectModel>? lastLeftOutCard;
  static List<NcnnDetectModel>? lastMyOutCard;
  static bool myBuChu = false;

  ///是否打了不出
  static bool leftBuChu = false;
  static bool rightBuChu = false;
  static int myOutCardBuffLength = 0;
  static int myEmptyBuffLength = 0;

  ///出牌缓冲区长度，长度越长，准确率越高，相应的，实时性降低
  static int leftOutCardBuffLength = 0;
  static int leftEmptyBuffLength = 0;

  ///出牌缓冲区长度，长度越长，准确率越高，相应的，实时性降低
  static int rightOutCardBuffLength = 0;
  static int rightEmptyBuffLength = 0;

  ///出牌缓冲区长度，长度越长，准确率越高，相应的，实时性降低

  static GameStatusWeile initGameStatus(NcnnDetectModel landlord, ScreenshotModel screenshotModel, detectList) {
    curGameStatus = GameStatusWeile.gamePreparing;
    if (RegionManager.inMyLandlordRegion(landlord, screenshotModel)) {
      var list = LandlordManager.getMyHandCard(detectList, screenshotModel);
      XLog.i(LOG_TAG, 'myHandCard length: ${list?.length}');
      if (list?.length == 20) {
        curGameStatus = GameStatusWeile.myTurn;
      }
    } else if (RegionManager.inLeftPlayerLandlordRegion(landlord, screenshotModel)) {
      curGameStatus = GameStatusWeile.leftTurn;
    } else if (RegionManager.inRightPlayerLandlordRegion(landlord, screenshotModel)) {
      curGameStatus = GameStatusWeile.rightTurn;
    }
    return curGameStatus;
  }

  static String getGameStatusStr(GameStatusWeile status) {
    return gameStatusStr[status.index];
  }

  static bool compareList(List<NcnnDetectModel>? list1, List<NcnnDetectModel>? list2) {
    if (list1?.length != list2?.length) {
      return false;
    }
    if (list1 == null && list2 == null) {
      return true;
    }
    var temp1 = List.from(list1!);
    var temp2 = List.from(list2!);
    for (var model in temp1) {
      temp2.removeWhere((element) => element.label == model.label);
    }
    if (temp2.isNotEmpty) {
      return false;
    }
    return true;
  }

  static void notifyOverlayWindow(OverlayUpdateType updateType, {List<NcnnDetectModel>? models, String? showString}) {
    String showStr = (models != null ? LandlordManager.getCardsSorted(models) : showString) ?? '';
    FlutterOverlayWindow.shareData([updateType.index, showStr]);
  }

  static GameStatusWeile calculateNextGameStatus(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) {
    GameStatusWeile nextStatus = curGameStatus;

    var rightOutCard = LandlordManager.getRightPlayerOutCard(detectList, screenshotModel);
    if ((rightOutCard?.isNotEmpty ?? false)) {
      rightEmptyBuffLength = 0;
      nextStatus = cacheRightOutCard(rightOutCard!);
    } else {
      rightEmptyBuffLength++;
      if (rightEmptyBuffLength == 3) {
        lastRightOutCard = null;
        rightEmptyBuffLength = 0;
      }
      rightOutCardBuff = null;
      rightOutCardBuffLength = 0;
    }

    var leftOutCard = LandlordManager.getLeftPlayerOutCard(detectList, screenshotModel);
    if ((leftOutCard?.isNotEmpty ?? false)) {
      leftEmptyBuffLength = 0;
      nextStatus = cacheLeftOutCard(leftOutCard!);
    } else {
      if (leftEmptyBuffLength == 3) {
        lastLeftOutCard = null;
        leftEmptyBuffLength = 0;
      }
      leftOutCardBuffLength = 0;
      leftOutCardBuff = null;
    }

    var myOutCard = LandlordManager.getMyOutCard(detectList, screenshotModel);
    if ((myOutCard?.isNotEmpty ?? false)) {
      myEmptyBuffLength = 0;
      nextStatus = cacheMyOutCard(myOutCard!);
    } else {
      myEmptyBuffLength++;
      if (myEmptyBuffLength == 3) {
        lastMyOutCard = null;
        myEmptyBuffLength = 0;
      }
      myOutCardBuffLength = 0;
      myOutCardBuff = null;
    }

    return nextStatus;
  }

  static GameStatusWeile cacheMyOutCard(List<NcnnDetectModel>? myOutCard) {
    GameStatusWeile nextStatus = curGameStatus;
    XLog.i(LOG_TAG, 'lastMyOutCard: ${LandlordManager.getCardsSorted(lastMyOutCard)}');
    XLog.i(LOG_TAG, 'myOutCardBuff: ${LandlordManager.getCardsSorted(myOutCardBuff)}');
    XLog.i(LOG_TAG, 'myOutCardBuffLength: $myOutCardBuffLength, cache myOutCards ${LandlordManager.getCardsSorted(myOutCard)}');
    if (lastMyOutCard != null) {
      if (compareList(myOutCard, lastMyOutCard) == true) {
        myOutCardBuff = null;
        myOutCardBuffLength = 0;
        return nextStatus;
      }
    }
    if (myOutCardBuff == null) {
      myOutCardBuff = myOutCard;
      myOutCardBuffLength++;
    } else {
      if (compareList(myOutCard, myOutCardBuff) == false) {
        myOutCardBuff = myOutCard;
        myOutCardBuffLength = 1;
      } else {
        myOutCardBuffLength++;
        if (myOutCardBuffLength == 3) {
          myOutCardBuffLength = 0;
          lastMyOutCard = myOutCardBuff;
          myOutCardBuff = null;
          nextStatus = GameStatusWeile.iDone;
          notifyOverlayWindow(OverlayUpdateType.gameStatus, showString: GameStatusMgrWeile.getGameStatusStr(nextStatus));
          notifyOverlayWindow(OverlayUpdateType.myOutCard, models: lastMyOutCard);
        }
      }
    }
    return nextStatus;
  }

  static GameStatusWeile cacheRightOutCard(List<NcnnDetectModel> rightOutCard) {
    GameStatusWeile nextStatus = curGameStatus;
    XLog.i(LOG_TAG, 'lastRightOutCard: ${LandlordManager.getCardsSorted(lastRightOutCard)}');
    XLog.i(LOG_TAG, 'rightOutCardBuff: ${LandlordManager.getCardsSorted(rightOutCardBuff)}');
    XLog.i(LOG_TAG, 'rightOutCardBuffLength: $rightOutCardBuffLength, cache rightOutCards ${LandlordManager.getCardsSorted(rightOutCard)}');
    if (lastRightOutCard != null) {
      if (compareList(rightOutCard, lastRightOutCard) == true) {
        rightOutCardBuff = null;
        rightOutCardBuffLength = 0;
        return nextStatus;
      }
    }
    if (rightOutCardBuff == null) {
      rightOutCardBuff = rightOutCard;
      rightOutCardBuffLength++;
    } else {
      if (compareList(rightOutCard, rightOutCardBuff) == false) {
        rightOutCardBuff = rightOutCard;
        rightOutCardBuffLength = 1;
      } else {
        rightOutCardBuffLength++;
        if (rightOutCardBuffLength == 3) {
          rightOutCardBuffLength = 0;
          lastRightOutCard = rightOutCardBuff;
          rightOutCardBuff = null;
          nextStatus = GameStatusWeile.rightDone;
          notifyOverlayWindow(OverlayUpdateType.gameStatus, showString: GameStatusMgrWeile.getGameStatusStr(nextStatus));
          notifyOverlayWindow(OverlayUpdateType.rightOutCard, models: lastRightOutCard);
          LandlordRecorder.updateRecorder(lastRightOutCard);
        }
      }
    }
    return nextStatus;
  }

  static GameStatusWeile cacheLeftOutCard(List<NcnnDetectModel>? leftOutCard) {
    GameStatusWeile nextStatus = curGameStatus;
    XLog.i(LOG_TAG, 'lastLeftOutCard: ${LandlordManager.getCardsSorted(lastLeftOutCard)}');
    XLog.i(LOG_TAG, 'leftOutCardBuff: ${LandlordManager.getCardsSorted(leftOutCardBuff)}');
    XLog.i(LOG_TAG, 'leftOutCardBuffLength: $leftOutCardBuffLength, cache leftOutCards ${LandlordManager.getCardsSorted(leftOutCard)}');
    if (lastLeftOutCard != null) {
      if (compareList(leftOutCard, lastLeftOutCard) == true) {
        leftOutCardBuff = null;
        leftOutCardBuffLength = 0;
        return nextStatus;
      }
    }
    if (leftOutCardBuff == null) {
      leftOutCardBuff = leftOutCard;
      leftOutCardBuffLength++;
    } else {
      if (compareList(leftOutCard, leftOutCardBuff) == false) {
        leftOutCardBuff = leftOutCard;
        leftOutCardBuffLength = 1;
      } else {
        leftOutCardBuffLength++;
        if (leftOutCardBuffLength == 3) {
          leftOutCardBuffLength = 0;
          lastLeftOutCard = leftOutCardBuff;
          leftOutCardBuff = null;
          nextStatus = GameStatusWeile.leftDone;
          notifyOverlayWindow(OverlayUpdateType.gameStatus, showString: GameStatusMgrWeile.getGameStatusStr(nextStatus));
          notifyOverlayWindow(OverlayUpdateType.leftOutCard, models: lastLeftOutCard);
          LandlordRecorder.updateRecorder(lastLeftOutCard);
        }
      }
    }
    return nextStatus;
  }

  static void destroy() {
    curGameStatus = GameStatusWeile.gamePreparing;
    lastLeftOutCard = null;
    lastRightOutCard = null;
    lastMyOutCard = null;
    myOutCardBuff = null;
    leftOutCardBuff = null;
    rightOutCardBuff = null;
    myOutCardBuffLength = 0;
    leftOutCardBuffLength = 0;
    rightOutCardBuffLength = 0;
    myEmptyBuffLength = 0;
    leftEmptyBuffLength = 0;
    rightEmptyBuffLength = 0;
    myBuChu = false;
    leftBuChu = false;
    rightBuChu = false;
    FlutterOverlayWindow.shareData([OverlayUpdateType.gameStatus.index, getGameStatusStr(GameStatusWeile.gameOver)]);
  }
}
