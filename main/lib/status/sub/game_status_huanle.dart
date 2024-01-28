import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_xlog/flutter_xlog.dart';
import 'package:ncnn_plugin/export.dart';
import 'package:screenshot_plugin/export.dart';
import 'package:yolo_flutter/landlord_recorder.dart';
import 'package:yolo_flutter/region/region_manager.dart';
import 'package:yolo_flutter/strategy_manager.dart';

import '../../landlord/landlord_manager.dart';
import '../../overlay_window_widget.dart';
import '../game_status_manager.dart';

///状态管理
class GameStatusHuanle extends GameStatusManager {
  static String LOG_TAG = 'GameStatusHuanle';

  static final GameStatusHuanle _singleton = GameStatusHuanle._internal();

  factory GameStatusHuanle() {
    return _singleton;
  }

  GameStatusHuanle._internal();

  @override
  GameStatus initGameStatus(NcnnDetectModel landlord, ScreenshotModel screenshotModel, {List<NcnnDetectModel>? detectList}) {
    curGameStatus = GameStatus.gamePreparing;
    if (RegionManager.inMyLandlordRegion(landlord, screenshotModel)) {
      curGameStatus = GameStatus.myTurn;
      StrategyManager.currentTurn = RequestTurn.myTurn;
      XLog.i(LOG_TAG, 'I am landlord');
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

  @override
  GameStatus calculateNextGameStatus(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) {
    GameStatus nextStatus = curGameStatus;
    if (myOutCardBuff != null) {
      var myOutCard = LandlordManager.getMyOutCard(detectList, screenshotModel);
      cacheMyOutCard(myOutCard);
    }
    if (rightOutCardBuff != null) {
      var rightOutCard = LandlordManager.getRightPlayerOutCard(detectList, screenshotModel);
      cacheRightOutCard(rightOutCard);
    }
    if (leftOutCardBuff != null) {
      var leftOutCard = LandlordManager.getLeftPlayerOutCard(detectList, screenshotModel);
      cacheLeftOutCard(leftOutCard);
    }
    switch (curGameStatus) {
      case GameStatus.myTurn:
        var buchu = LandlordManager.getBuChu(detectList, screenshotModel);
        if (RegionManager.inMyBuchuRegion(buchu, screenshotModel)) {
          myBuChu = true;
          nextStatus = GameStatus.iSkip;
          GameStatusManager.notifyOverlayWindow(OverlayUpdateType.myOutCard, showString: "不出");
          GameStatusManager.notifyOverlayWindow(OverlayUpdateType.suggestion, showString: '');
          XLog.i(LOG_TAG, 'iSkip, triggerNext');
          StrategyManager().triggerNext();
        } else {
          var myOutCard = LandlordManager.getMyOutCard(detectList, screenshotModel);
          if (myOutCard?.isNotEmpty ?? false) {
            nextStatus = GameStatus.iDone;
            XLog.i(LOG_TAG, 'startCacheMyOutCard');
            cacheMyOutCard(myOutCard);
          }
        }
        break;
      case GameStatus.iSkip:
        nextStatus = GameStatus.rightTurn;
        break;
      case GameStatus.iDone:
        nextStatus = GameStatus.rightTurn;
        break;
      case GameStatus.rightTurn:
        var buchu = LandlordManager.getBuChu(detectList, screenshotModel);
        if (RegionManager.inRightBuchuRegion(buchu, screenshotModel)) {
          nextStatus = GameStatus.rightSkip;
          rightBuChu = true;
          GameStatusManager.notifyOverlayWindow(OverlayUpdateType.rightOutCard, showString: "不出");
          XLog.i(LOG_TAG, 'rightSkip, triggerNext');
          StrategyManager().triggerNext();
        } else {
          var rightOutCard = LandlordManager.getRightPlayerOutCard(detectList, screenshotModel);
          if ((rightOutCard?.isNotEmpty ?? false)) {
            nextStatus = GameStatus.rightDone;
            cacheRightOutCard(rightOutCard);
          }
        }
        break;
      case GameStatus.rightSkip:
        nextStatus = GameStatus.leftTurn;
        break;
      case GameStatus.rightDone:
        nextStatus = GameStatus.leftTurn;
        break;
      case GameStatus.leftTurn:
        var buchu = LandlordManager.getBuChu(detectList, screenshotModel);
        if (RegionManager.inLeftBuchuRegion(buchu, screenshotModel)) {
          nextStatus = GameStatus.leftSkip;
          leftBuChu = true;
          GameStatusManager.notifyOverlayWindow(OverlayUpdateType.leftOutCard, showString: "不出");
          XLog.i(LOG_TAG, 'leftSkip, triggerNext');
          StrategyManager().triggerNext();
        } else {
          var leftOutCard = LandlordManager.getLeftPlayerOutCard(detectList, screenshotModel);
          if (leftOutCard?.isNotEmpty ?? false) {
            nextStatus = GameStatus.leftDone;
            cacheLeftOutCard(leftOutCard);
          }
        }
        break;
      case GameStatus.leftSkip:
        nextStatus = GameStatus.myTurn;
        break;
      case GameStatus.leftDone:
        nextStatus = GameStatus.myTurn;
        break;
    }
    return nextStatus;
  }

  void cacheMyOutCard(List<NcnnDetectModel>? myOutCard) {
    XLog.i(LOG_TAG, 'myOutCardBuff: ${LandlordManager.getCardsSorted(myOutCardBuff)}');
    XLog.i(LOG_TAG, 'myOutCardBuffLength: $myOutCardBuffLength, cache myOutCards ${LandlordManager.getCardsSorted(myOutCard)}');

    ///缓存，判断哪个长度更长，就用哪个，排除动画的影响
    if (myOutCardBuff == null) {
      myOutCardBuff = myOutCard;
      myOutCardBuffLength++;
    } else {
      if ((myOutCard?.length ?? 0) >= (myOutCardBuff?.length ?? 0)) {
        myOutCardBuff = myOutCard;
      }
      myOutCardBuffLength++;
      if (myOutCardBuffLength == 3) {
        XLog.i(LOG_TAG, 'myOutCardBuff cache Done');
        myHistoryOutCard.addAll(myOutCardBuff!);
        XLog.i(LOG_TAG, 'show myOutCards ${LandlordManager.getCardsSorted(myOutCardBuff)}');
        GameStatusManager.notifyOverlayWindow(OverlayUpdateType.myOutCard, models: myOutCardBuff);
        GameStatusManager.notifyOverlayWindow(OverlayUpdateType.suggestion, showString: '');
        XLog.i(LOG_TAG, 'myOutCardBuff, triggerNext');
        StrategyManager().triggerNext();
        myOutCardBuffLength = 0;
        myOutCardBuff = null;
      }
    }
  }

  void cacheRightOutCard(List<NcnnDetectModel>? rightOutCard) {
    XLog.i(LOG_TAG, 'rightOutCardBuff: ${LandlordManager.getCardsSorted(rightOutCardBuff)}');
    XLog.i(LOG_TAG, 'rightOutCardBuffLength: $rightOutCardBuffLength, cache rightOutCards ${LandlordManager.getCardsSorted(rightOutCard)}');
    if (rightOutCardBuff == null) {
      rightOutCardBuff = rightOutCard;
      rightOutCardBuffLength++;
    } else {
      if ((rightOutCard?.length ?? 0) >= (rightOutCardBuff?.length ?? 0)) {
        rightOutCardBuff = rightOutCard;
      }
      rightOutCardBuffLength++;
      if (rightOutCardBuffLength == 4) {
        XLog.i(LOG_TAG, 'rightOutCardBuff cache done');
        rightHistoryOutCard.addAll(rightOutCardBuff!);
        XLog.i(LOG_TAG, 'updateRecorder');
        LandlordRecorder.updateRecorder(rightOutCardBuff);

        XLog.i(LOG_TAG, 'show rightOutCards ${LandlordManager.getCardsSorted(rightOutCardBuff)}');
        GameStatusManager.notifyOverlayWindow(OverlayUpdateType.rightOutCard, models: rightOutCardBuff);

        XLog.i(LOG_TAG, 'rightOutCardBuff, triggerNext');
        StrategyManager().triggerNext();
        rightOutCardBuffLength = 0;
        rightOutCardBuff = null;
      }
    }
  }

  void cacheLeftOutCard(List<NcnnDetectModel>? leftOutCard) {
    XLog.i(LOG_TAG, 'leftOutCardBuff: ${LandlordManager.getCardsSorted(leftOutCardBuff)}');
    XLog.i(LOG_TAG, 'leftOutCardBuffLength: $leftOutCardBuffLength, cache leftOutCards ${LandlordManager.getCardsSorted(leftOutCard)}');
    if (leftOutCardBuff == null) {
      leftOutCardBuff = leftOutCard;
      leftOutCardBuffLength++;
    } else {
      if ((leftOutCard?.length ?? 0) >= (leftOutCardBuff?.length ?? 0)) {
        leftOutCardBuff = leftOutCard;
      }
      leftOutCardBuffLength++;
      if (leftOutCardBuffLength == 4) {
        XLog.i(LOG_TAG, 'leftOutCardBuff cache done');
        leftHistoryOutCard.addAll(leftOutCardBuff!);
        XLog.i(LOG_TAG, 'updateRecorder');
        LandlordRecorder.updateRecorder(leftOutCardBuff);

        XLog.i(LOG_TAG, 'show leftOutCards ${LandlordManager.getCardsSorted(leftOutCardBuff)}');
        GameStatusManager.notifyOverlayWindow(OverlayUpdateType.leftOutCard, models: leftOutCardBuff);

        XLog.i(LOG_TAG, 'leftOutCardBuff, triggerNext');
        StrategyManager().triggerNext();
        leftOutCardBuffLength = 0;
        leftOutCardBuff = null;
      }
    }
  }
}
