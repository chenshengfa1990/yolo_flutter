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
class GameStatusWeile extends GameStatusManager {
  static String LOG_TAG = 'GameStatusWeile';

  static final GameStatusWeile _singleton = GameStatusWeile._internal();

  factory GameStatusWeile() {
    return _singleton;
  }

  GameStatusWeile._internal();

  @override
  GameStatus initGameStatus(NcnnDetectModel landlord, ScreenshotModel screenshotModel, {List<NcnnDetectModel>? detectList}) {
    curGameStatus = GameStatus.gamePreparing;
    if (RegionManager.inMyLandlordRegion(landlord, screenshotModel)) {
      var list = LandlordManager.getMyHandCard(detectList, screenshotModel);
      XLog.i(LOG_TAG, 'myHandCard length: ${list?.length}');
      if (list?.length == 20) {
        curGameStatus = GameStatus.myTurn;
      }
    } else if (RegionManager.inLeftPlayerLandlordRegion(landlord, screenshotModel)) {
      curGameStatus = GameStatus.leftTurn;
    } else if (RegionManager.inRightPlayerLandlordRegion(landlord, screenshotModel)) {
      curGameStatus = GameStatus.rightTurn;
    }
    return curGameStatus;
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
          GameStatusManager.notifyOverlayWindow(OverlayUpdateType.rightOutCard, showString: "不出");
          XLog.i(LOG_TAG, 'rightSkip');
          StrategyManager().calculateNextAction(GameStatus.rightSkip, null);
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
          GameStatusManager.notifyOverlayWindow(OverlayUpdateType.leftOutCard, showString: "不出");
          XLog.i(LOG_TAG, 'leftSkip');
          StrategyManager().calculateNextAction(GameStatus.leftSkip, null);
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
          XLog.i(LOG_TAG, 'iSkip');
          StrategyManager().calculateNextAction(GameStatus.iSkip, null);
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
      if (GameStatusManager.compareList(myOutCard, lastMyOutCard) == true) {
        XLog.i(LOG_TAG, 'same as lastMyOutCard, return');
        myOutCardBuff = null;
        myOutCardBuffLength = 0;
        return;
      }
    }
    if (myOutCardBuff == null) {
      myOutCardBuff = myOutCard;
      myOutCardBuffLength++;
    } else {
      if (GameStatusManager.compareList(myOutCard, myOutCardBuff) == false) {
        XLog.i(LOG_TAG, 'myOutCard not same as before, replace');
        myOutCardBuff = myOutCard;
        myOutCardBuffLength = 1;
      } else {
        myOutCardBuffLength++;
        if (myOutCardBuffLength == getOutCardBuffLength(BuffWho.my)) {
          XLog.i(LOG_TAG, 'cache myOutCard done, myOutCardBuffLength: $myOutCardBuffLength');
          myOutCardBuffLength = 0;
          myHistoryOutCardCount++;
          StrategyManager().calculateNextAction(GameStatus.iDone, myOutCardBuff);
          lastMyOutCard = myOutCardBuff;
          myOutCardBuff = null;
          myHistoryOutCard.addAll(lastMyOutCard!);
          GameStatusManager.notifyOverlayWindow(OverlayUpdateType.myOutCard, models: lastMyOutCard);
          GameStatusManager.notifyOverlayWindow(OverlayUpdateType.suggestion, showString: '');
        }
      }
    }
  }

  void cacheRightOutCard(List<NcnnDetectModel> rightOutCard) {
    XLog.i(LOG_TAG, 'lastRightOutCard: ${LandlordManager.getCardsSorted(lastRightOutCard)}');
    XLog.i(LOG_TAG, 'rightOutCardBuff: ${LandlordManager.getCardsSorted(rightOutCardBuff)}');
    XLog.i(LOG_TAG, 'rightOutCardBuffLength: $rightOutCardBuffLength, cache rightOutCards ${LandlordManager.getCardsSorted(rightOutCard)}');
    if (lastRightOutCard != null) {
      if (GameStatusManager.compareList(rightOutCard, lastRightOutCard) == true) {
        XLog.i(LOG_TAG, 'same as lastRightOutCard, return');
        rightOutCardBuff = null;
        rightOutCardBuffLength = 0;
        return;
      }
    }
    if (rightOutCardBuff == null) {
      rightOutCardBuff = rightOutCard;
      rightOutCardBuffLength++;
    } else {
      if (GameStatusManager.compareList(rightOutCard, rightOutCardBuff) == false) {
        XLog.i(LOG_TAG, 'rightOutCard not same as before, replace');
        rightOutCardBuff = rightOutCard;
        rightOutCardBuffLength = 1;
      } else {
        rightOutCardBuffLength++;
        if (rightOutCardBuffLength == getOutCardBuffLength(BuffWho.right)) {
          XLog.i(LOG_TAG, 'cache rightOutCard done, rightOutCardBuffLength: $rightOutCardBuffLength');
          rightOutCardBuffLength = 0;
          rightHistoryOutCardCount++;
          StrategyManager().calculateNextAction(GameStatus.rightDone, rightOutCardBuff);
          lastRightOutCard = rightOutCardBuff;
          rightOutCardBuff = null;
          rightHistoryOutCard.addAll(lastRightOutCard!);
          GameStatusManager.notifyOverlayWindow(OverlayUpdateType.rightOutCard, models: lastRightOutCard);
          LandlordRecorder.updateRecorder(lastRightOutCard);
        }
      }
    }
  }

  void cacheLeftOutCard(List<NcnnDetectModel>? leftOutCard) {
    XLog.i(LOG_TAG, 'lastLeftOutCard: ${LandlordManager.getCardsSorted(lastLeftOutCard)}');
    XLog.i(LOG_TAG, 'leftOutCardBuff: ${LandlordManager.getCardsSorted(leftOutCardBuff)}');
    XLog.i(LOG_TAG, 'leftOutCardBuffLength: $leftOutCardBuffLength, cache leftOutCards ${LandlordManager.getCardsSorted(leftOutCard)}');
    if (lastLeftOutCard != null) {
      if (GameStatusManager.compareList(leftOutCard, lastLeftOutCard) == true) {
        XLog.i(LOG_TAG, 'same as lastLeftOutCard, return');
        leftOutCardBuff = null;
        leftOutCardBuffLength = 0;
        return;
      }
    }
    if (leftOutCardBuff == null) {
      leftOutCardBuff = leftOutCard;
      leftOutCardBuffLength++;
    } else {
      if (GameStatusManager.compareList(leftOutCard, leftOutCardBuff) == false) {
        XLog.i(LOG_TAG, 'leftOutCard not same as before, replace');
        leftOutCardBuff = leftOutCard;
        leftOutCardBuffLength = 1;
      } else {
        leftOutCardBuffLength++;
        if (leftOutCardBuffLength == getOutCardBuffLength(BuffWho.left)) {
          XLog.i(LOG_TAG, 'cache leftOutCard done, leftOutCardBuffLength: $leftOutCardBuffLength');
          leftOutCardBuffLength = 0;
          leftHistoryOutCardCount++;
          StrategyManager().calculateNextAction(GameStatus.leftDone, leftOutCardBuff);
          lastLeftOutCard = leftOutCardBuff;
          leftOutCardBuff = null;
          leftHistoryOutCard.addAll(lastLeftOutCard!);
          GameStatusManager.notifyOverlayWindow(OverlayUpdateType.leftOutCard, models: lastLeftOutCard);
          LandlordRecorder.updateRecorder(lastLeftOutCard);
        }
      }
    }
  }
}
