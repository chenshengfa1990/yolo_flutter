import 'package:flutter_xlog/flutter_xlog.dart';
import 'package:ncnn_plugin/export.dart';
import 'package:screenshot_plugin/export.dart';
import 'package:yolo_flutter/region/region_manager.dart';
import 'package:yolo_flutter/status/game_status_manager.dart';

import '../../landlord/landlord_manager.dart';
import '../../landlord_recorder.dart';
import '../../overlay_window_widget.dart';

///状态管理
class GameStatusWeile extends GameStatusManager {
  static String LOG_TAG = 'GameStatusWeile';

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
  GameStatus calculateNextGameStatus(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) {
    GameStatus nextStatus = curGameStatus;

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

  GameStatus cacheMyOutCard(List<NcnnDetectModel>? myOutCard) {
    GameStatus nextStatus = curGameStatus;
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
          myHistoryOutCard.addAll(lastMyOutCard!);
          nextStatus = GameStatus.iDone;
          GameStatusManager.notifyOverlayWindow(OverlayUpdateType.gameStatus, showString: GameStatusManager.getGameStatusStr(nextStatus));
          GameStatusManager.notifyOverlayWindow(OverlayUpdateType.myOutCard, models: lastMyOutCard);
        }
      }
    }
    return nextStatus;
  }

  GameStatus cacheRightOutCard(List<NcnnDetectModel> rightOutCard) {
    GameStatus nextStatus = curGameStatus;
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
          rightHistoryOutCard.addAll(lastRightOutCard!);
          nextStatus = GameStatus.rightDone;
          GameStatusManager.notifyOverlayWindow(OverlayUpdateType.gameStatus, showString: GameStatusManager.getGameStatusStr(nextStatus));
          GameStatusManager.notifyOverlayWindow(OverlayUpdateType.rightOutCard, models: lastRightOutCard);
          LandlordRecorder.updateRecorder(lastRightOutCard);
        }
      }
    }
    return nextStatus;
  }

  GameStatus cacheLeftOutCard(List<NcnnDetectModel>? leftOutCard) {
    GameStatus nextStatus = curGameStatus;
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
          leftHistoryOutCard.addAll(lastLeftOutCard!);
          nextStatus = GameStatus.leftDone;
          GameStatusManager.notifyOverlayWindow(OverlayUpdateType.gameStatus, showString: GameStatusManager.getGameStatusStr(nextStatus));
          GameStatusManager.notifyOverlayWindow(OverlayUpdateType.leftOutCard, models: lastLeftOutCard);
          LandlordRecorder.updateRecorder(lastLeftOutCard);
        }
      }
    }
    return nextStatus;
  }
}
