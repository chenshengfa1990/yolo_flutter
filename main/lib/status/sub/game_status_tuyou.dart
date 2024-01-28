import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_xlog/flutter_xlog.dart';
import 'package:ncnn_plugin/export.dart';
import 'package:screenshot_plugin/export.dart';
import 'package:yolo_flutter/region/region_manager.dart';
import 'package:yolo_flutter/status/game_status_manager.dart';
import 'package:yolo_flutter/strategy_manager.dart';

import '../../landlord/landlord_manager.dart';
import '../../landlord_recorder.dart';
import '../../overlay_window_widget.dart';

///状态管理
class GameStatusTuyou extends GameStatusManager {
  static String LOG_TAG = 'GameStatusTuyou';

  static final GameStatusTuyou _singleton = GameStatusTuyou._internal();

  factory GameStatusTuyou() {
    return _singleton;
  }

  GameStatusTuyou._internal();

  @override
  GameStatus initGameStatus(NcnnDetectModel landlord, ScreenshotModel screenshotModel, {List<NcnnDetectModel>? detectList}) {
    curGameStatus = GameStatus.gamePreparing;
    if (RegionManager.inMyLandlordRegion(landlord, screenshotModel)) {
      var list = LandlordManager.getMyHandCard(detectList, screenshotModel);
      XLog.i(LOG_TAG, 'myHandCard length: ${list?.length}');
      if (list?.length == 20) {
        curGameStatus = GameStatus.myTurn;
        StrategyManager.currentTurn = RequestTurn.myTurn;
        XLog.i(LOG_TAG, 'I am landlord');
      }
    } else if (RegionManager.inLeftPlayerLandlordRegion(landlord, screenshotModel)) {
      curGameStatus = GameStatus.leftTurn;
      StrategyManager.currentTurn = RequestTurn.leftTurn;
      XLog.i(LOG_TAG, 'leftPlayer is landlord');
    } else if (RegionManager.inRightPlayerLandlordRegion(landlord, screenshotModel)) {
      curGameStatus = GameStatus.rightTurn;
      StrategyManager.currentTurn = RequestTurn.rightTurn;
      XLog.i(LOG_TAG, 'rightPlayer is landlord');
    }
    return curGameStatus;
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

  @override
  int getOutCardBuffLength(BuffWho who) {
    if (who == BuffWho.my) {
      return 3;
    } else if (who == BuffWho.left) {
      return 3;
    } else {
      return 3;
    }
  }

  @override
  GameStatus calculateNextGameStatus(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) {
    GameStatus nextStatus = curGameStatus;
    XLog.i(LOG_TAG, "startCalculateNextGameStatus, curGameStatus: $curGameStatus");
    switch (curGameStatus) {
      case GameStatus.myTurn:
        break;
      case GameStatus.iSkip:
        nextStatus = GameStatus.rightTurn;
        break;
      case GameStatus.iDone:
        nextStatus = GameStatus.rightTurn;
        break;
      case GameStatus.leftTurn:
        break;
      case GameStatus.leftSkip:
        nextStatus = GameStatus.myTurn;
        break;
      case GameStatus.leftDone:
        nextStatus = GameStatus.myTurn;
        break;
      case GameStatus.rightTurn:
        break;
      case GameStatus.rightSkip:
        nextStatus = GameStatus.leftTurn;
        break;
      case GameStatus.rightDone:
        nextStatus = GameStatus.leftTurn;
        break;
    }

    var rightOutCard = LandlordManager.getRightPlayerOutCard(detectList, screenshotModel);
    if ((rightOutCard?.isNotEmpty ?? false)) {
      rightEmptyBuffLength = 0;
      cacheRightOutCard(rightOutCard!);
      if (nextStatus == GameStatus.rightTurn) {
        nextStatus = GameStatus.rightDone;
      }
    } else {
      if (nextStatus == GameStatus.rightTurn) {
        var buchu = LandlordManager.getBuChu(detectList, screenshotModel);
        if (RegionManager.inRightBuchuRegion(buchu, screenshotModel)) {
          rightBuChu = true;
          GameStatusManager.notifyOverlayWindow(OverlayUpdateType.rightOutCard, showString: "不出");
          XLog.i(LOG_TAG, 'rightSkip, triggerNext');
          StrategyManager().triggerNext();
          nextStatus = GameStatus.rightSkip;
        }
      }
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
      cacheLeftOutCard(leftOutCard!);
      if (nextStatus == GameStatus.leftTurn) {
        nextStatus = GameStatus.leftDone;
      }
    } else {
      if (nextStatus == GameStatus.leftTurn) {
        var buchu = LandlordManager.getBuChu(detectList, screenshotModel);
        if (RegionManager.inLeftBuchuRegion(buchu, screenshotModel)) {
          leftBuChu = true;
          GameStatusManager.notifyOverlayWindow(OverlayUpdateType.leftOutCard, showString: "不出");
          XLog.i(LOG_TAG, 'leftSkip, triggerNext');
          StrategyManager().triggerNext();
          nextStatus = GameStatus.leftSkip;
        }
      }
      leftEmptyBuffLength++;
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
      cacheMyOutCard(myOutCard!);
      if (nextStatus == GameStatus.myTurn) {
        nextStatus = GameStatus.iDone;
      }
    } else {
      if (nextStatus == GameStatus.myTurn) {
        var buchu = LandlordManager.getBuChu(detectList, screenshotModel);
        if (RegionManager.inMyBuchuRegion(buchu, screenshotModel)) {
          myBuChu = true;
          XLog.i(LOG_TAG, 'iSkip, triggerNext');
          GameStatusManager.notifyOverlayWindow(OverlayUpdateType.myOutCard, showString: "不出");
          GameStatusManager.notifyOverlayWindow(OverlayUpdateType.suggestion, showString: '');
          StrategyManager().triggerNext();
          nextStatus = GameStatus.iSkip;
        }
      }
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

  void cacheMyOutCard(List<NcnnDetectModel>? myOutCard) {
    XLog.i(LOG_TAG, 'lastMyOutCard: ${LandlordManager.getCardsSorted(lastMyOutCard)}');
    XLog.i(LOG_TAG, 'myOutCardBuff: ${LandlordManager.getCardsSorted(myOutCardBuff)}');
    XLog.i(LOG_TAG, 'myOutCardBuffLength: $myOutCardBuffLength, cache myOutCards ${LandlordManager.getCardsSorted(myOutCard)}');
    if (lastMyOutCard != null) {
      if (compareList(myOutCard, lastMyOutCard) == true) {
        myOutCardBuff = null;
        myOutCardBuffLength = 0;
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
        if (myOutCardBuffLength == getOutCardBuffLength(BuffWho.my)) {
          lastMyOutCard = myOutCardBuff;
          myHistoryOutCard.addAll(lastMyOutCard!);
          GameStatusManager.notifyOverlayWindow(OverlayUpdateType.myOutCard, models: lastMyOutCard);
          GameStatusManager.notifyOverlayWindow(OverlayUpdateType.suggestion, showString: '');
          StrategyManager().triggerNext();
          myOutCardBuff = null;
          myOutCardBuffLength = 0;
        }
      }
    }
  }

  void cacheRightOutCard(List<NcnnDetectModel> rightOutCard) {
    XLog.i(LOG_TAG, 'lastRightOutCard: ${LandlordManager.getCardsSorted(lastRightOutCard)}');
    XLog.i(LOG_TAG, 'rightOutCardBuff: ${LandlordManager.getCardsSorted(rightOutCardBuff)}');
    XLog.i(LOG_TAG, 'rightOutCardBuffLength: $rightOutCardBuffLength, cache rightOutCards ${LandlordManager.getCardsSorted(rightOutCard)}');
    if (lastRightOutCard != null) {
      if (compareList(rightOutCard, lastRightOutCard) == true) {
        rightOutCardBuff = null;
        rightOutCardBuffLength = 0;
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
        if (rightOutCardBuffLength == getOutCardBuffLength(BuffWho.right)) {
          lastRightOutCard = rightOutCardBuff;
          rightHistoryOutCard.addAll(lastRightOutCard!);
          GameStatusManager.notifyOverlayWindow(OverlayUpdateType.rightOutCard, models: lastRightOutCard);
          LandlordRecorder.updateRecorder(lastRightOutCard);

          StrategyManager().triggerNext();
          rightOutCardBuffLength = 0;
          rightOutCardBuff = null;
        }
      }
    }
  }

  void cacheLeftOutCard(List<NcnnDetectModel>? leftOutCard) {
    XLog.i(LOG_TAG, 'lastLeftOutCard: ${LandlordManager.getCardsSorted(lastLeftOutCard)}');
    XLog.i(LOG_TAG, 'leftOutCardBuff: ${LandlordManager.getCardsSorted(leftOutCardBuff)}');
    XLog.i(LOG_TAG, 'leftOutCardBuffLength: $leftOutCardBuffLength, cache leftOutCards ${LandlordManager.getCardsSorted(leftOutCard)}');
    if (lastLeftOutCard != null) {
      if (compareList(leftOutCard, lastLeftOutCard) == true) {
        leftOutCardBuff = null;
        leftOutCardBuffLength = 0;
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
        if (leftOutCardBuffLength == getOutCardBuffLength(BuffWho.left)) {
          lastLeftOutCard = leftOutCardBuff;
          leftHistoryOutCard.addAll(lastLeftOutCard!);
          GameStatusManager.notifyOverlayWindow(OverlayUpdateType.leftOutCard, models: lastLeftOutCard);
          LandlordRecorder.updateRecorder(lastLeftOutCard);

          StrategyManager().triggerNext();
          leftOutCardBuffLength = 0;
          leftOutCardBuff = null;
        }
      }
    }
  }
}
