import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_xlog/flutter_xlog.dart';
import 'package:ncnn_plugin/export.dart';
import 'package:screenshot_plugin/export.dart';
import 'package:yolo_flutter/region/region_manager.dart';
import 'package:yolo_flutter/strategy_manager.dart';

import 'landlord/landlord_manager.dart';
import 'overlay_window_widget.dart';

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


///状态管理
class GameStatusManager {
  static String LOG_TAG = 'GameStatusManager';
  static GameStatus curGameStatus = GameStatus.gamePreparing;
  static List<String> gameStatusStr = ['准备中', '地主已分配', '我出牌中', '我不出', '我已出牌', '下家出牌中', '下家不出', '下家已出牌', '上家出牌中', '上家不出', '上家已出牌', '游戏结束'];
  static List<NcnnDetectModel>? myOutCardBuff;
  static List<NcnnDetectModel>? leftOutCardBuff;
  static List<NcnnDetectModel>? rightOutCardBuff;
  static bool myBuChu = false;

  ///是否打了不出
  static bool leftBuChu = false;
  static bool rightBuChu = false;
  static int myOutCardBuffLength = 0;

  ///出牌缓冲区长度，长度越长，准确率越高，相应的，实时性降低
  static int leftOutCardBuffLength = 0;

  ///出牌缓冲区长度，长度越长，准确率越高，相应的，实时性降低
  static int rightOutCardBuffLength = 0;

  ///出牌缓冲区长度，长度越长，准确率越高，相应的，实时性降低

  static GameStatus initGameStatus(NcnnDetectModel landlord, ScreenshotModel screenshotModel) {
    curGameStatus = GameStatus.gamePreparing;
    if (RegionManager.inMyLandlordRegion(landlord, screenshotModel)) {
      curGameStatus = GameStatus.myTurn;
      StrategyManager.currentTurn = RequestTurn.myTurn;
    } else if (RegionManager.inLeftPlayerLandlordRegion(landlord, screenshotModel)) {
      curGameStatus = GameStatus.leftTurn;
      StrategyManager.currentTurn = RequestTurn.leftTurn;
    } else if (RegionManager.inRightPlayerLandlordRegion(landlord, screenshotModel)) {
      curGameStatus = GameStatus.rightTurn;
      StrategyManager.currentTurn = RequestTurn.rightTurn;
    }
    return curGameStatus;
  }

  static String getGameStatusStr(GameStatus status) {
    return gameStatusStr[status.index];
  }

  static GameStatus calculateNextGameStatus(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) {
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
          XLog.i(LOG_TAG, 'iSkip, triggerNext');
          StrategyManager.triggerNext();
        } else {
          var myOutCard = LandlordManager.getMyOutCard(detectList, screenshotModel);
          if (myOutCard?.isNotEmpty ?? false) {
            nextStatus = GameStatus.iDone;
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
          XLog.i(LOG_TAG, 'rightSkip, triggerNext');
          StrategyManager.triggerNext();
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
          XLog.i(LOG_TAG, 'leftSkip, triggerNext');
          StrategyManager.triggerNext();
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

  static void cacheMyOutCard(List<NcnnDetectModel>? myOutCard) {
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
        XLog.i(LOG_TAG, 'iDone, triggerNext');
        StrategyManager.triggerNext();
        myOutCardBuffLength = 0;
      }
    }
  }

  static void cacheRightOutCard(List<NcnnDetectModel>? rightOutCard) {
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
        XLog.i(LOG_TAG, 'rightDone, triggerNext');
        StrategyManager.triggerNext();
        rightOutCardBuffLength = 0;
      }
    }
  }

  static void cacheLeftOutCard(List<NcnnDetectModel>? leftOutCard) {
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
        XLog.i(LOG_TAG, 'leftDone, triggerNext');
        StrategyManager.triggerNext();
        leftOutCardBuffLength = 0;
      }
    }
  }

  static void destroy() {
    curGameStatus = GameStatus.gamePreparing;
    myOutCardBuff = null;
    leftOutCardBuff = null;
    rightOutCardBuff = null;
    myOutCardBuffLength = 0;
    leftOutCardBuffLength = 0;
    rightOutCardBuffLength = 0;
    myBuChu = false;
    leftBuChu = false;
    rightBuChu = false;
    FlutterOverlayWindow.shareData([OverlayUpdateType.gameStatus.index, getGameStatusStr(GameStatus.gameOver)]);
  }
}
